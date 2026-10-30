import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants.dart';

/// One frame from the relay's server-sent event stream.
class RelayEvent {
  final String type;
  final Map<String, dynamic> data;
  const RelayEvent(this.type, this.data);
}

/// Host side of the DJfy relay (services/djfy). The relay only forwards:
/// guest messages come in on [hostEvents], party state goes out through
/// [publishSnapshot].
class RelayClient {
  final String baseUrl;
  final Dio _dio;

  RelayClient({String? baseUrl, Dio? dio})
      : baseUrl = baseUrl ?? kRelayUrl,
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              // SSE heartbeats arrive every 20 s; anything longer is a dead link.
              receiveTimeout: const Duration(seconds: 45),
            ));

  String joinUrl(String code) => '$baseUrl/j/$code';

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<({String code, String token})> createSession() async {
    final res = await _dio.post('$baseUrl/api/sessions');
    final data = res.data as Map<String, dynamic>;
    return (code: data['code'] as String, token: data['hostToken'] as String);
  }

  Future<void> publishSnapshot(
      String code, String token, Map<String, dynamic> snapshot) async {
    await _dio.post('$baseUrl/api/sessions/$code/host/snapshot',
        data: snapshot, options: _auth(token));
  }

  Future<void> sendToGuest(String code, String token, String guestId,
      Map<String, dynamic> data) async {
    await _dio.post('$baseUrl/api/sessions/$code/host/send',
        data: {'guestId': guestId, 'data': data}, options: _auth(token));
  }

  Future<void> ban(String code, String token, String guestId) async {
    await _dio.post('$baseUrl/api/sessions/$code/host/ban',
        data: {'guestId': guestId}, options: _auth(token));
  }

  Future<void> endSession(String code, String token) async {
    await _dio.delete('$baseUrl/api/sessions/$code', options: _auth(token));
  }

  /// Guest messages for this session. Reconnects with backoff until the
  /// subscription is cancelled; [onConnection] reports link state for the UI.
  /// Messages sent while we're disconnected are queued by the relay.
  Stream<RelayEvent> hostEvents(String code, String token,
      {void Function(bool connected)? onConnection}) {
    late StreamController<RelayEvent> ctrl;
    CancelToken? cancel;
    var closed = false;

    Future<void> loop() async {
      var backoff = 1;
      while (!closed) {
        cancel = CancelToken();
        try {
          final res = await _dio.get<ResponseBody>(
            '$baseUrl/api/sessions/$code/host/events',
            options: _auth(token).copyWith(responseType: ResponseType.stream),
            cancelToken: cancel,
          );
          onConnection?.call(true);
          backoff = 1;
          await for (final ev in parseSse(res.data!.stream)) {
            ctrl.add(ev);
          }
        } on DioException catch (e) {
          if (CancelToken.isCancel(e)) break;
          // 401/404: the session is gone (expired or ended elsewhere).
          final status = e.response?.statusCode;
          if (status == 401 || status == 404) {
            ctrl.addError(StateError('Session $code už neexistuje'));
            break;
          }
          debugPrint('[Relay] stream error: ${e.message}');
        } catch (e) {
          debugPrint('[Relay] stream error: $e');
        }
        onConnection?.call(false);
        if (closed) break;
        await Future.delayed(Duration(seconds: backoff));
        backoff = (backoff * 2).clamp(1, 30);
      }
      if (!ctrl.isClosed) await ctrl.close();
    }

    ctrl = StreamController<RelayEvent>(
      onListen: loop,
      onCancel: () {
        closed = true;
        cancel?.cancel();
      },
    );
    return ctrl.stream;
  }

  /// Minimal SSE parser: `event:` + single-line `data:` frames, `:` comments.
  @visibleForTesting
  static Stream<RelayEvent> parseSse(Stream<List<int>> bytes) async* {
    var type = 'message';
    final data = StringBuffer();
    await for (final line in bytes
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (data.isNotEmpty) {
          final decoded = jsonDecode(data.toString());
          yield RelayEvent(
              type, decoded is Map<String, dynamic> ? decoded : {'value': decoded});
        }
        type = 'message';
        data.clear();
      } else if (line.startsWith('event:')) {
        type = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        if (data.isNotEmpty) data.write('\n');
        data.write(line.substring(5).trimLeft());
      }
    }
  }
}
