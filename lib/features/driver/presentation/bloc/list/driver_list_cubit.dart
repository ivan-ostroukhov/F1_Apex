import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/i_driver_repository.dart';
import '../../../../../common/network/load_exception.dart';
import 'driver_list_state.dart';

class DriverListCubit extends Cubit<DriverListState> {
  final IDriverRepository _repository;
  String _lastQuery = '';

  DriverListCubit(this._repository) : super(const DriverListLoading());

  Future<void> loadDrivers() async {
    await search(_lastQuery);
  }

  Future<void> search(String query) async {
    _lastQuery = query;
    emit(const DriverListLoading());
    try {
      final result = await _repository.getDrivers(query: query);
      if (isClosed) return;

      if (result.isEmpty) {
        emit(DriverListNotFound(query));
      } else {
        emit(DriverListLoaded(drivers: result, query: query));
      }
    } on LoadException {
      if (isClosed) return;
      emit(const DriverListError());
    } catch (_) {
      if (isClosed) return;
      emit(const DriverListError());
    }
  }
}