import 'dart:math' as math;

import 'package:dj_deckify/core/platter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Runs the platter for [seconds] at 60 Hz.
  void run(Platter p, double seconds) {
    for (var t = 0.0; t < seconds; t += 1 / 60) {
      p.tick(1 / 60);
    }
  }

  test('one revolution is 1.8 s of track at 33⅓ rpm', () {
    expect(Platter.secondsPerRevolution, closeTo(1.8, 1e-9));
    expect(Platter.trackTime(2 * math.pi), const Duration(milliseconds: 1800));
    expect(Platter.trackTime(-math.pi), const Duration(milliseconds: -900));
  });

  test('play and pause act at once and follow the pitch slider', () {
    final p = Platter()..speed = 1.1;
    p.setMotor(true);
    expect(p.rate, closeTo(1.1, 1e-9));
    expect(p.settled, isTrue);
    p.setMotor(false);
    expect(p.rate, 0);
  });

  test('a touch stops the record, a still finger keeps it stopped', () {
    final p = Platter()..setMotor(true);
    p.touch();
    expect(p.rate, 0);
    p.drag(Platter.nominalRadPerSec * 0.01, 0.01); // finger at normal speed
    expect(p.rate, closeTo(0.6, 1e-6)); // low-passed towards it
    p.drag(Platter.nominalRadPerSec * 0.01, 0.01);
    expect(p.rate, closeTo(0.84, 1e-6));
    run(p, 0.1); // finger held still
    expect(p.rate, 0);
  });

  test('dragging backwards gives a negative rate', () {
    final p = Platter()..setMotor(true)..touch();
    for (var i = 0; i < 5; i++) {
      p.drag(-Platter.nominalRadPerSec * 0.016, 0.016);
    }
    expect(p.rate, lessThan(-0.9));
  });

  test('release spins the record back up to speed within ~0.3 s', () {
    final p = Platter()..setMotor(true)..touch();
    p.release();
    expect(p.settled, isFalse);
    run(p, 0.1);
    expect(p.rate, inInclusiveRange(0.5, 0.75));
    run(p, 0.25);
    expect(p.rate, greaterThan(0.95));
    run(p, 0.5);
    expect(p.settled, isTrue);
    expect(p.rate, 1);
  });

  test('brake coasts to a stop in the given time, then the motor is off', () {
    final p = Platter()..setMotor(true);
    p.brake(1);
    run(p, 0.5);
    expect(p.rate, closeTo(0.5, 0.03));
    run(p, 0.55);
    expect(p.rate, 0);
    expect(p.motorOn, isFalse);
    expect(p.mode, PlatterMode.motor);
  });

  test('nudge bends the pitch a few percent and lets go', () {
    final p = Platter()..setMotor(true);
    p.nudge = 1;
    run(p, 0.5);
    expect(p.rate, closeTo(1 + Platter.nudgeAmount, 1e-3));
    p.nudge = 0;
    run(p, 0.5);
    expect(p.rate, closeTo(1, 1e-3));
  });

  test('a paused record stays still after release', () {
    final p = Platter()..touch();
    p.drag(1, 0.1);
    p.release();
    run(p, 0.5);
    expect(p.rate, 0);
  });

  test('backspin throws the record backwards, it coasts to a stop and spins up again', () {
    final p = Platter()..setMotor(true);
    p.backspin(3, 1);
    expect(p.rate, closeTo(-3, 1e-9));
    run(p, 0.5);
    expect(p.rate, closeTo(-1.5, 0.1));
    run(p, 0.55);
    expect(p.rate, 0);
    expect(p.motorOn, isFalse);
    p.spinUp();
    run(p, 0.05);
    expect(p.rate, inExclusiveRange(0, 1));
    run(p, 1);
    expect(p.rate, 1);
  });
}
