import 'package:dj_deckify/services/audio_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FxParamMapper hi-lo', () {
    test('LP cutoff sweeps 16 kHz → 60 Hz towards the left edge', () {
      expect(FxParamMapper.hiLoLpFrequency(0.45), closeTo(16000, 1));
      expect(FxParamMapper.hiLoLpFrequency(0.0), closeTo(60, 1));
    });

    test('HP cutoff sweeps 20 Hz → 8 kHz towards the right edge', () {
      expect(FxParamMapper.hiLoHpFrequency(0.55), closeTo(20, 1));
      expect(FxParamMapper.hiLoHpFrequency(1.0), closeTo(8000, 1));
    });

    test('resonance maps y ∈ [0,1] to [1,8]', () {
      expect(FxParamMapper.hiLoResonance(0), 1);
      expect(FxParamMapper.hiLoResonance(1), 8);
    });
  });

  group('FxParamMapper buckets', () {
    test('echo buckets quarter to full beat', () {
      expect(FxParamMapper.echoBeats(0.1), 0.25);
      expect(FxParamMapper.echoBeats(0.3), 0.5);
      expect(FxParamMapper.echoBeats(0.6), 0.75);
      expect(FxParamMapper.echoBeats(0.9), 1.0);
      expect(FxParamMapper.echoBeats(1.0), 1.0); // edge stays in last bucket
    });

    test('roll buckets half to sixteenth', () {
      expect(FxParamMapper.rollBeats(0.1), 0.5);
      expect(FxParamMapper.rollBeats(0.3), 0.25);
      expect(FxParamMapper.rollBeats(0.6), 0.125);
      expect(FxParamMapper.rollBeats(0.9), 0.0625);
    });

    test('beatskip buckets -4 … +4', () {
      expect(FxParamMapper.beatskipBeats(0.05), -4);
      expect(FxParamMapper.beatskipBeats(0.2), -2);
      expect(FxParamMapper.beatskipBeats(0.4), -1);
      expect(FxParamMapper.beatskipBeats(0.6), 1);
      expect(FxParamMapper.beatskipBeats(0.75), 2);
      expect(FxParamMapper.beatskipBeats(0.95), 4);
      expect(FxParamMapper.beatskipBeats(1.0), 4);
    });
  });

  group('FxParamMapper 8-bit', () {
    test('samplerate sweeps 22 kHz → 800 Hz', () {
      expect(FxParamMapper.eightBitSamplerate(0), closeTo(22000, 1));
      expect(FxParamMapper.eightBitSamplerate(1), closeTo(800, 1));
    });
  });
}
