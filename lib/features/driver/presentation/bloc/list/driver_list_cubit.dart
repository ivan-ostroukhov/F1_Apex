import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/i_driver_repository.dart';
import 'driver_list_state.dart';

class DriverListCubit extends Cubit<DriverListState> {
  final IDriverRepository _repository;
  String _lastQuery = '';
  String _currentSeason = '2026';

  String get currentSeason => _currentSeason;

  DriverListCubit(this._repository) : super(const DriverListLoading());

  Future<void> loadDrivers({String? season}) async {
    if (season != null && season.isNotEmpty) {
      _currentSeason = season;
    }
    await search(_lastQuery);
  }

  Future<void> search(String query) async {
    _lastQuery = query;
    emit(const DriverListLoading());
    try {
      final result = await _repository.getDrivers(query: query, season: _currentSeason);
      if (isClosed) return;

      if (result.isEmpty) {
        emit(DriverListNotFound(query));
      } else {
        emit(DriverListLoaded(drivers: result, query: query));
      }
    } catch (_) {
      if (isClosed) return;
      emit(const DriverListError());
    }
  }
}