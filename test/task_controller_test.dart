import 'package:flutter_test/flutter_test.dart';
import 'package:rosstabak_manager/controllers/task_controller.dart';
import 'package:rosstabak_manager/models/task.dart';
import 'package:rosstabak_manager/constants/app_task_status.dart';

void main() {
  late TaskController controller;

  setUp(() {
    controller = TaskController();
  });

  test('should initialize with empty tasks', () {
    expect(controller.tasks, isEmpty);
    expect(controller.isLoading, false);
  });

  test('completionRate should be 0 when no tasks', () {
    expect(controller.completionRate, 0);
  });

  test('activeTasksCount should be 0 when no tasks', () {
    expect(controller.activeTasksCount, 0);
  });

  test('completedTasksCount should be 0 when no tasks', () {
    expect(controller.completedTasksCount, 0);
  });

  test('todayTasksCount should be 0 when no tasks', () {
    expect(controller.todayTasksCount, 0);
  });

  test('overdueTasksCount should be 0 when no tasks', () {
    expect(controller.overdueTasksCount, 0);
  });

  test('completionRate should be 100 when all tasks completed', () {
    controller.tasks = [
      Task(
        id: 1,
        title: 'Task 1',
        status: AppTaskStatus.completed,
        createdBy: 1,
        isActive: true,
      ),
      Task(
        id: 2,
        title: 'Task 2',
        status: AppTaskStatus.completed,
        createdBy: 1,
        isActive: true,
      ),
    ];

    expect(controller.completionRate, 100);
    expect(controller.completedTasksCount, 2);
    expect(controller.activeTasksCount, 0);
  });

  test('completionRate should be 50 when half tasks completed', () {
    controller.tasks = [
      Task(
        id: 1,
        title: 'Task 1',
        status: AppTaskStatus.completed,
        createdBy: 1,
        isActive: true,
      ),
      Task(
        id: 2,
        title: 'Task 2',
        status: AppTaskStatus.newTask,
        createdBy: 1,
        isActive: true,
      ),
    ];

    expect(controller.completionRate, 50);
    expect(controller.completedTasksCount, 1);
    expect(controller.activeTasksCount, 1);
  });

  test('completionRate should be 0 when no tasks completed', () {
    controller.tasks = [
      Task(
        id: 1,
        title: 'Task 1',
        status: AppTaskStatus.newTask,
        createdBy: 1,
        isActive: true,
      ),
      Task(
        id: 2,
        title: 'Task 2',
        status: AppTaskStatus.inProgress,
        createdBy: 1,
        isActive: true,
      ),
    ];

    expect(controller.completionRate, 0);
    expect(controller.completedTasksCount, 0);
    expect(controller.activeTasksCount, 2);
  });

  test('activeTasksCount should count non-completed tasks', () {
    controller.tasks = [
      Task(
        id: 1,
        title: 'T1',
        status: AppTaskStatus.newTask,
        createdBy: 1,
        isActive: true,
      ),
      Task(
        id: 2,
        title: 'T2',
        status: AppTaskStatus.inProgress,
        createdBy: 1,
        isActive: true,
      ),
      Task(
        id: 3,
        title: 'T3',
        status: AppTaskStatus.completed,
        createdBy: 1,
        isActive: true,
      ),
    ];

    expect(controller.activeTasksCount, 2);
  });

  test('completedTasksCount should count completed tasks only', () {
    controller.tasks = [
      Task(
        id: 1,
        title: 'T1',
        status: AppTaskStatus.completed,
        createdBy: 1,
        isActive: true,
      ),
      Task(
        id: 2,
        title: 'T2',
        status: AppTaskStatus.completed,
        createdBy: 1,
        isActive: true,
      ),
      Task(
        id: 3,
        title: 'T3',
        status: AppTaskStatus.newTask,
        createdBy: 1,
        isActive: true,
      ),
    ];

    expect(controller.completedTasksCount, 2);
  });
}
