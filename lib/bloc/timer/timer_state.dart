part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  const TimerState(this.duration, this.pastDuration, bool? enabledFirstAlert)
      : enabledFirstAlert = enabledFirstAlert ?? true;
  final int duration;
  final int pastDuration;
  final bool enabledFirstAlert;

  @override
  List<Object> get props => [duration, pastDuration, enabledFirstAlert];
}

class TimerInitial extends TimerState {
  const TimerInitial(
      super.duration, super.pastDuration, super.enabledFirstAlert);

  @override
  String toString() => 'TimerInitial { duration: $duration }';
}

class TimerRunPause extends TimerState {
  const TimerRunPause(
    super.duration,
    super.pastDuration,
    super.enabledFirstAlert,
  );

  @override
  String toString() => 'TimerRunPause { duration: $duration }';
}

class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(
      super.duration, super.pastDuration, super.enabledFirstAlert);

  @override
  String toString() => 'TimerRunInProgress { duration: $duration }';
}

class TimerRunComplete extends TimerState {
  const TimerRunComplete() : super(0, 0, false);
}
