import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/race_model.dart';
import '../../data/repositories/schedule_repository.dart';

abstract class ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final RaceModel? currentRace;
  final List<RaceModel> pastRaces;
  final List<RaceModel> upcomingRaces;

  ScheduleLoaded({
    required this.currentRace,
    required this.pastRaces,
    required this.upcomingRaces,
  });
}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleCubit(this._repository) : super(ScheduleLoading());

  Future<void> loadSchedule() async {
    try {
      emit(ScheduleLoading());
      final races = await _repository.getSeasonSchedule();

      final past = races.where((r) => r.isCompleted).toList();
      final upcoming = races.where((r) => !r.isCompleted).toList();

      final currentRace = upcoming.isNotEmpty ? upcoming.first : (past.isNotEmpty ? past.last : null);

      final remainingUpcoming = upcoming.isNotEmpty ? upcoming.skip(1).toList() : <RaceModel>[];

      final reversedPast = past.reversed.toList();

      emit(ScheduleLoaded(
        currentRace: currentRace,
        pastRaces: reversedPast,
        upcomingRaces: remainingUpcoming,
      ));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}