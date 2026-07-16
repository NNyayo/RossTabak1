import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/shift.dart';
import '../repositories/shift_employee_repository.dart';
import '../repositories/shift_repository.dart';
import '../repositories/store_repository.dart';
import '../repositories/system_log_repository.dart';
import '../constants/app_shifts.dart';

class ShiftController extends ChangeNotifier {
  final ShiftRepository shiftRepository;
  final StoreRepository storeRepository;
  final ShiftEmployeeRepository shiftEmployeeRepository;
  final SystemLogRepository logRepository;

  bool isLoading = false;
  List<Shift> allShifts = [];

  ShiftController({
    ShiftRepository? shiftRepository,
    StoreRepository? storeRepository,
    ShiftEmployeeRepository? shiftEmployeeRepository,
    SystemLogRepository? logRepository,
  }) : shiftRepository = shiftRepository ?? ShiftRepository(),
       storeRepository = storeRepository ?? StoreRepository(),
       shiftEmployeeRepository =
           shiftEmployeeRepository ?? ShiftEmployeeRepository(),
       logRepository = logRepository ?? SystemLogRepository();

  Future<void> loadShifts() async {
    allShifts = await shiftRepository.getShifts();
    notifyListeners();
  }

  int get activeShiftsCount {
    final now = DateTime.now();
    final today = formattedDate(now);
    return allShifts.where((s) {
      if (s.date != today) return false;
      try {
        final startParts = s.startTime.split(':');
        final endParts = s.endTime.split(':');
        final startHour = int.parse(startParts[0]);
        final endHour = int.parse(endParts[0]);
        final currentHour = now.hour;

        if (startHour < endHour) {
          return currentHour >= startHour && currentHour < endHour;
        } else {
          return currentHour >= startHour || currentHour < endHour;
        }
      } catch (_) {
        return false;
      }
    }).length;
  }

  int get todayShiftsCount {
    final today = formattedDate(DateTime.now());
    return allShifts.where((s) => s.date == today).length;
  }

  String getCurrentShiftType(DateTime now) {
    final hour = now.hour;
    if (hour >= 10 && hour < 22) {
      return AppShifts.day;
    }
    return AppShifts.night;
  }

  String formattedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<Shift?> getCurrentShift(DateTime now) async {
    final date = formattedDate(now);
    final shiftType = getCurrentShiftType(now);
    final shifts = await shiftRepository.getShiftsByDateAndType(
      date,
      shiftType,
    );
    return shifts.isEmpty ? null : shifts.first;
  }

  Future<int> createShift(Shift shift, int operatorId) async {
    final id = await shiftRepository.addShift(shift);
    await logRepository.createLog(
      employeeId: operatorId,
      action: 'CREATE_SHIFT',
      description:
          'Создана смена ${shift.shiftType} для точки ${shift.storeId} на ${shift.date}',
    );
    return id;
  }

  Future<void> ensureShiftsForDate(DateTime date, int operatorId) async {
    final stores = await storeRepository.getStores();
    final dateString = formattedDate(date);
    for (final store in stores) {
      final dayShifts = await shiftRepository.getShiftsByStoreDateAndType(
        store.id!,
        dateString,
        AppShifts.day,
      );
      if (dayShifts.isEmpty) {
        await createShift(
          Shift(
            storeId: store.id!,
            date: dateString,
            shiftType: AppShifts.day,
            startTime: '10:00',
            endTime: '22:00',
          ),
          operatorId,
        );
      }

      final nightShifts = await shiftRepository.getShiftsByStoreDateAndType(
        store.id!,
        dateString,
        AppShifts.night,
      );
      if (nightShifts.isEmpty) {
        await createShift(
          Shift(
            storeId: store.id!,
            date: dateString,
            shiftType: AppShifts.night,
            startTime: '22:00',
            endTime: '10:00',
          ),
          operatorId,
        );
      }
    }
  }

  Future<void> assignEmployees(
    int shiftId,
    List<int> employeeIds,
    int operatorId,
  ) async {
    await shiftEmployeeRepository.assignEmployeesToShift(shiftId, employeeIds);
    await logRepository.createLog(
      employeeId: operatorId,
      action: 'ASSIGN_SHIFT_EMPLOYEES',
      description: 'Назначены сотрудники на смену id=$shiftId',
    );
  }
}
