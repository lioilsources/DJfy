import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// A decoded track: interleaved 16-bit samples in native memory, freed when
/// [samples] is garbage collected.
class DecodedPcm {
  final Int16List samples;
  final int channels;
  final int sampleRate;

  /// Address of [samples], for reading them from another isolate while this
  /// object is alive.
  final int address;

  DecodedPcm._(this.samples, this.channels, this.sampleRate, this.address);

  int get frames => samples.length ~/ channels;
  Duration get duration => Duration(microseconds: frames * 1000000 ~/ sampleRate);

  /// A view of the same memory, for use inside another isolate.
  static Int16List view(int address, int length) => Pointer<Int16>.fromAddress(address).asTypedList(length);
}

/// Decodes a whole MP3 file off the main isolate. Null when it isn't one.
Future<DecodedPcm?> decodeMp3(Uint8List bytes) async {
  final transfer = TransferableTypedData.fromList([bytes]);
  final result = await Isolate.run(() => _decode(transfer.materialize().asUint8List()));
  if (result == null) return null;
  final (:address, :channels, :sampleRate, :frames) = result;
  final samples = Pointer<Int16>.fromAddress(address).asTypedList(frames * channels, finalizer: _free.cast());
  return DecodedPcm._(samples, channels, sampleRate, address);
}

typedef _Decoded = ({int address, int channels, int sampleRate, int frames});

_Decoded? _decode(Uint8List bytes) {
  final data = malloc<Uint8>(bytes.length);
  final channels = malloc<Uint32>();
  final rate = malloc<Uint32>();
  final frames = malloc<Uint64>();
  try {
    data.asTypedList(bytes.length).setAll(0, bytes);
    final pcm = _decodeMp3(data, bytes.length, channels, rate, frames);
    if (pcm == nullptr) return null;
    return (address: pcm.address, channels: channels.value, sampleRate: rate.value, frames: frames.value);
  } finally {
    malloc
      ..free(data)
      ..free(channels)
      ..free(rate)
      ..free(frames);
  }
}

final DynamicLibrary _lib = () {
  if (Platform.isMacOS || Platform.isIOS) return DynamicLibrary.open('djfy_decoder.framework/djfy_decoder');
  if (Platform.isAndroid || Platform.isLinux) return DynamicLibrary.open('libdjfy_decoder.so');
  throw UnsupportedError('djfy_decoder: ${Platform.operatingSystem}');
}();

final _decodeMp3 = _lib.lookupFunction<
    Pointer<Int16> Function(Pointer<Uint8>, Size, Pointer<Uint32>, Pointer<Uint32>, Pointer<Uint64>),
    Pointer<Int16> Function(Pointer<Uint8>, int, Pointer<Uint32>, Pointer<Uint32>, Pointer<Uint64>)>('djfy_decode_mp3');

final _free = _lib.lookup<NativeFunction<Void Function(Pointer<Void>)>>('djfy_free');
