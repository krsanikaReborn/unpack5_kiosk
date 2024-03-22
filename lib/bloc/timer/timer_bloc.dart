import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/defined_code.dart';
import '../../utils/time_ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc({required TimeTicker ticker})
      : _ticker = ticker,
        super(const TimerInitial(0, 0, false)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerOffAlert>(_onOffAlert);
    on<_TimerTicked>(_onTicked);
  }

  final TimeTicker _ticker;

  StreamSubscription<int>? _tickerSubscription;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration, state.pastDuration, true));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(
          state.duration, state.pastDuration, state.enabledFirstAlert));
    }
  }

  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) async {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      await Future.delayed(const Duration(seconds: 1));
      emit(
        TimerRunInProgress(state.duration - 1, state.pastDuration + 1,
            state.enabledFirstAlert),
      );
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(0, 0, false));
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(
              event.duration, state.pastDuration + 1, state.enabledFirstAlert)
          : const TimerRunComplete(),
    );
  }

  void _onOffAlert(TimerOffAlert event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress &&
        state.pastDuration <= gTimeisTickingTimer) {
      emit(TimerRunInProgress(state.duration, state.pastDuration, false));
    }
  }
}
