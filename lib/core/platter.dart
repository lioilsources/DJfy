import 'dart:math' as math;

enum PlatterMode {
  /// The motor drives the platter towards [Platter.targetRate].
  motor,

  /// A finger holds the platter: it moves only as the finger does.
  touched,

  /// Coasting to a stop after [Platter.brake].
  braking,
}

/// A turntable platter: 33⅓ rpm, stopped by a touch, dragged by the finger,
/// spun back up by the motor on release.
///
/// Pure model, driven by [tick]; [rate] is the signed playback rate the audio
/// should follow (1 = normal, 0 = still, < 0 = backwards).
class Platter {
  static const rpm = 100 / 3;
  static const nominalRadPerSec = 2 * math.pi * rpm / 60;

  /// One revolution of the record = 1.8 s of track.
  static const secondsPerRevolution = 60 / rpm;

  /// Motor time constant: ~95 % of the target speed after 3 × [spinUpTau].
  static const spinUpTau = 0.1;

  /// A finger held still for this long stops the record.
  static const holdStill = 0.05;

  /// Pitch bend of the nudge buttons.
  static const nudgeAmount = 0.04;

  PlatterMode mode = PlatterMode.motor;

  /// Whether the motor runs (play) or not (pause).
  bool motorOn = false;

  /// Pitch slider, multiplies the nominal speed.
  double speed = 1;

  /// −1, 0 or +1 while a nudge button is held.
  int nudge = 0;

  double _velocity = 0; // rad/s, signed
  double _sinceDrag = 0;
  double _brakeTime = 1;
  double _brakeFrom = 0;

  double get angularVelocity => _velocity;
  double get rate => _velocity / nominalRadPerSec;

  /// The rate the motor is heading for.
  double get targetRate => motorOn ? speed * (1 + nudge * nudgeAmount) : 0;

  /// Nothing left to animate: the audio can stay at [rate] without ticks.
  bool get settled => mode == PlatterMode.motor && (rate - targetRate).abs() < 1e-3;

  /// Track time covered by [radians] of rotation.
  static Duration trackTime(double radians) =>
      Duration(microseconds: (radians / (2 * math.pi) * secondsPerRevolution * 1e6).round());

  /// Play and pause act at once, like a CDJ, not like a turntable motor.
  void setMotor(bool on) {
    motorOn = on;
    if (mode == PlatterMode.braking) mode = PlatterMode.motor;
    if (mode == PlatterMode.motor) _velocity = targetRate * nominalRadPerSec;
  }

  void touch() {
    mode = PlatterMode.touched;
    _velocity = 0;
    _sinceDrag = 0;
  }

  /// The finger turned the record by [radians] over [seconds].
  void drag(double radians, double seconds) {
    if (mode != PlatterMode.touched) return;
    final instant = radians / math.max(seconds, 1e-3);
    // Low-pass: touch events are noisy and unevenly spaced.
    _velocity = _velocity * 0.4 + instant * 0.6;
    _sinceDrag = 0;
  }

  void release() {
    if (mode != PlatterMode.touched) return;
    mode = PlatterMode.motor;
    if (!motorOn) _velocity = 0; // no motor: the record stays where it was let go
  }

  /// Backspin: thrown backwards at [strength]× normal speed, coasting to a
  /// stop over [seconds]; the motor is off afterwards.
  void backspin(double strength, double seconds) {
    if (mode == PlatterMode.touched) return;
    mode = PlatterMode.braking;
    _brakeTime = math.max(seconds, 0.05);
    _velocity = _brakeFrom = -strength * nominalRadPerSec;
  }

  /// Motor back on from wherever the record is: it spins up, no jump.
  void spinUp() {
    motorOn = true;
    mode = PlatterMode.motor;
  }

  /// Coast to a stop over [seconds]; the motor is off afterwards.
  void brake(double seconds) {
    if (!motorOn || mode == PlatterMode.touched) return;
    mode = PlatterMode.braking;
    _brakeTime = math.max(seconds, 0.05);
    _brakeFrom = _velocity;
  }

  void tick(double seconds) {
    switch (mode) {
      case PlatterMode.touched:
        _sinceDrag += seconds;
        if (_sinceDrag >= holdStill) _velocity = 0;
      case PlatterMode.motor:
        final target = targetRate * nominalRadPerSec;
        _velocity += (target - _velocity) * (1 - math.exp(-seconds / spinUpTau));
        if ((_velocity - target).abs() < 1e-3 * nominalRadPerSec) _velocity = target;
      case PlatterMode.braking:
        _velocity -= _brakeFrom * seconds / _brakeTime;
        if (_brakeFrom >= 0 ? _velocity <= 0 : _velocity >= 0) {
          _velocity = 0;
          motorOn = false;
          mode = PlatterMode.motor;
        }
    }
  }
}
