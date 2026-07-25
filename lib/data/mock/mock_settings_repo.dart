import 'dart:async';

import '../models/guardrails.dart';
import '../repositories/settings_repo.dart';

/// Marina Café settings seed — §2 S05 frame values: band 26–70%, quiet
/// hours on, Nudge ±10%, Gentle, Managers + floor, default hours 7am–11pm
/// with the S05-10 Fri & Sat 7am–1am exception. Alert defaults are not
/// pinned (open_questions).
class MockSettingsRepo implements SettingsRepo {
  var _guardrails = const Guardrails();
  var _hours = const OpenHours(
    exceptions: [
      HoursException(days: {4, 5}, openHour: 7, closeHour: 1),
    ],
  );

  final _guardrailsController = StreamController<Guardrails>.broadcast();
  final _hoursController = StreamController<OpenHours>.broadcast();

  @override
  Stream<Guardrails> watchGuardrails() async* {
    yield _guardrails;
    yield* _guardrailsController.stream;
  }

  @override
  Future<void> updateGuardrails(Guardrails next) async {
    _guardrails = next;
    _guardrailsController.add(next);
  }

  @override
  Stream<OpenHours> watchOpenHours() async* {
    yield _hours;
    yield* _hoursController.stream;
  }

  void _emitHours(OpenHours next) {
    _hours = next;
    _hoursController.add(next);
  }

  @override
  Future<void> setEverydayHours(
      {required int openHour, required int closeHour}) async {
    _emitHours(_hours.copyWith(openHour: openHour, closeHour: closeHour));
  }

  @override
  Future<void> addException(HoursException exception) async {
    _emitHours(
        _hours.copyWith(exceptions: [..._hours.exceptions, exception]));
  }

  void dispose() {
    _guardrailsController.close();
    _hoursController.close();
  }
}
