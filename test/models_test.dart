import 'package:flutter_test/flutter_test.dart';
import 'package:rosstabak_manager/models/employee.dart';
import 'package:rosstabak_manager/models/store.dart';
import 'package:rosstabak_manager/models/task.dart';
import 'package:rosstabak_manager/models/shift.dart';
import 'package:rosstabak_manager/models/task_category.dart';
import 'package:rosstabak_manager/models/notification.dart';
import 'package:rosstabak_manager/constants/app_roles.dart';
import 'package:rosstabak_manager/constants/app_task_status.dart';

void main() {
  group('Employee Model Tests', () {
    test('should create Employee with all fields', () {
      final employee = Employee(
        id: 1,
        lastName: 'Иванов',
        firstName: 'Иван',
        middleName: 'Иванович',
        login: 'ivanov',
        password: 'hashed',
        storeIds: [1, 2],
        role: AppRoles.admin,
        isActive: true,
      );

      expect(employee.id, 1);
      expect(employee.fullName, 'Иванов Иван Иванович');
      expect(employee.login, 'ivanov');
      expect(employee.role, AppRoles.admin);
      expect(employee.isActive, true);
      expect(employee.storeIds, [1, 2]);
    });

    test('should create Employee from map', () {
      final map = {
        'id': 1,
        'last_name': 'Петров',
        'first_name': 'Петр',
        'middle_name': 'Петрович',
        'login': 'petrov',
        'password': 'hashed',
        'role': AppRoles.employee,
        'is_active': 1,
        'storeIds': [3, 4],
      };

      final employee = Employee.fromMap(map);

      expect(employee.fullName, 'Петров Петр Петрович');
      expect(employee.role, AppRoles.employee);
      expect(employee.storeIds, [3, 4]);
      expect(employee.isActive, true);
    });

    test('should convert Employee to map', () {
      final employee = Employee(
        id: 1,
        lastName: 'Сидоров',
        firstName: 'Сидор',
        middleName: 'Сидорович',
        login: 'sidorov',
        password: 'pass',
        storeIds: [1],
        role: AppRoles.manager,
        isActive: true,
      );

      final map = employee.toMap();

      expect(map['id'], 1);
      expect(map['last_name'], 'Сидоров');
      expect(map['role'], AppRoles.manager);
      expect(map['is_active'], 1);
    });

    test('should copy Employee with changed fields', () {
      final original = Employee(
        id: 1,
        lastName: 'Иванов',
        firstName: 'Иван',
        middleName: '',
        login: 'ivanov',
        password: 'pass',
        storeIds: [1],
        role: AppRoles.employee,
        isActive: true,
      );

      final copied = original.copyWith(role: AppRoles.admin, isActive: false);

      expect(copied.role, AppRoles.admin);
      expect(copied.isActive, false);
      expect(copied.lastName, original.lastName); // Unchanged
    });

    test('fullName should handle empty middle name', () {
      final employee = Employee(
        id: 1,
        lastName: 'Иванов',
        firstName: 'Иван',
        middleName: '',
        login: 'ivanov',
        password: 'pass',
        storeIds: [],
      );

      expect(employee.fullName, 'Иванов Иван ');
    });
  });

  group('Store Model Tests', () {
    test('should create Store with all fields', () {
      final store = Store(
        id: 1,
        name: 'Магазин №1',
        address: 'ул. Ленина, 1',
        metro: 'Площадь Ленина',
        markerColor: 'Красный',
        isActive: true,
      );

      expect(store.name, 'Магазин №1');
      expect(store.address, 'ул. Ленина, 1');
      expect(store.metro, 'Площадь Ленина');
      expect(store.markerColor, 'Красный');
      expect(store.isActive, true);
    });

    test('should create Store from map', () {
      final map = {
        'id': 1,
        'name': 'Точка №2',
        'address': 'ул. Мира, 5',
        'metro': 'Мира',
        'marker_color': 'Синий',
        'is_active': 1,
      };

      final store = Store.fromMap(map);

      expect(store.name, 'Точка №2');
      expect(store.markerColor, 'Синий');
      expect(store.isActive, true);
    });

    test('should convert Store to map', () {
      final store = Store(
        id: 1,
        name: 'Test',
        address: 'Test addr',
        metro: 'Test metro',
        markerColor: 'Зелёный',
        isActive: true,
      );

      final map = store.toMap();

      expect(map['name'], 'Test');
      expect(map['address'], 'Test addr');
      expect(map['is_active'], 1);
    });
  });

  group('Task Model Tests', () {
    test('should create Task with all fields', () {
      final task = Task(
        id: 1,
        title: 'Уборка',
        description: 'Убрать помещение',
        status: AppTaskStatus.newTask,
        category: 'Уборка',
        priority: 'HIGH',
        createdBy: 1,
        isActive: true,
      );

      expect(task.title, 'Уборка');
      expect(task.status, AppTaskStatus.newTask);
      expect(task.category, 'Уборка');
      expect(task.priority, 'HIGH');
    });

    test('should convert Task to map', () {
      final task = Task(
        id: 1,
        title: 'Тест',
        description: 'Описание',
        status: AppTaskStatus.completed,
        category: 'Тест',
        priority: 'NORMAL',
        createdBy: 1,
        isActive: true,
      );

      final map = task.toMap();

      expect(map['title'], 'Тест');
      expect(map['status'], AppTaskStatus.completed);
      expect(map['is_active'], 1);
    });

    test('should create Task from map', () {
      final map = {
        'id': 1,
        'title': 'Задача',
        'description': 'Описание задачи',
        'status': AppTaskStatus.inProgress,
        'category': 'Касса',
        'priority': 'LOW',
        'created_by': 1,
        'is_active': 1,
      };

      final task = Task.fromMap(map);

      expect(task.title, 'Задача');
      expect(task.status, AppTaskStatus.inProgress);
      expect(task.category, 'Касса');
    });
  });

  group('Shift Model Tests', () {
    test('should create Shift with all fields', () {
      final shift = Shift(
        id: 1,
        storeId: 1,
        date: '2024-01-15',
        shiftType: 'Дневная',
        startTime: '10:00',
        endTime: '22:00',
      );

      expect(shift.storeId, 1);
      expect(shift.date, '2024-01-15');
      expect(shift.shiftType, 'Дневная');
      expect(shift.startTime, '10:00');
      expect(shift.endTime, '22:00');
    });

    test('should create Shift from map', () {
      final map = {
        'id': 1,
        'store_id': 1,
        'date': '2024-01-15',
        'shift_type': 'Ночная',
        'start_time': '22:00',
        'end_time': '10:00',
      };

      final shift = Shift.fromMap(map);

      expect(shift.shiftType, 'Ночная');
      expect(shift.startTime, '22:00');
    });

    test('should convert Shift to map', () {
      final shift = Shift(
        id: 1,
        storeId: 1,
        date: '2024-01-15',
        shiftType: 'Дневная',
        startTime: '10:00',
        endTime: '22:00',
      );

      final map = shift.toMap();

      expect(map['shift_type'], 'Дневная');
      expect(map['store_id'], 1);
    });
  });

  group('TaskCategory Model Tests', () {
    test('should create TaskCategory', () {
      final category = TaskCategory(
        id: 1,
        name: 'Уборка',
        description: 'Задачи по уборке',
        isActive: true,
      );

      expect(category.name, 'Уборка');
      expect(category.description, 'Задачи по уборке');
      expect(category.isActive, true);
    });

    test('should create TaskCategory from map', () {
      final map = {
        'id': 1,
        'name': 'Склад',
        'description': 'Работа со складом',
        'is_active': 1,
      };

      final category = TaskCategory.fromMap(map);

      expect(category.name, 'Склад');
      expect(category.isActive, true);
    });
  });

  group('Notification Model Tests', () {
    test('should create AppNotification', () {
      final notification = AppNotification(
        id: 1,
        employeeId: 1,
        title: 'Просрочена задача',
        message: 'Задача "Уборка" просрочена',
        isRead: false,
        type: 'OVERDUE_TASK',
      );

      expect(notification.title, 'Просрочена задача');
      expect(notification.isRead, false);
      expect(notification.type, 'OVERDUE_TASK');
    });

    test('should create AppNotification from map', () {
      final map = {
        'id': 1,
        'employee_id': 1,
        'title': 'Новая задача',
        'message': 'Вам назначена задача',
        'is_read': 0,
        'type': 'NEW_TASK',
      };

      final notification = AppNotification.fromMap(map);

      expect(notification.title, 'Новая задача');
      expect(notification.isRead, false);
    });
  });

  group('AppRoles Tests', () {
    test('should have correct role values', () {
      expect(AppRoles.admin, 'ADMIN');
      expect(AppRoles.manager, 'MANAGER');
      expect(AppRoles.employee, 'EMPLOYEE');
    });
  });

  group('AppTaskStatus Tests', () {
    test('should have correct status values', () {
      expect(AppTaskStatus.newTask, 'NEW');
      expect(AppTaskStatus.inProgress, 'IN_PROGRESS');
      expect(AppTaskStatus.completed, 'COMPLETED');
      expect(AppTaskStatus.failed, 'FAILED');
    });
  });

  group('Employee equality tests', () {
    test('two employees with same id and login should be equal', () {
      final e1 = Employee(
        id: 1,
        lastName: 'Иванов',
        firstName: 'Иван',
        middleName: '',
        login: 'ivanov',
        password: 'pass',
        storeIds: [],
      );

      final e2 = Employee(
        id: 1,
        lastName: 'Петров',
        firstName: 'Петр',
        middleName: '',
        login: 'ivanov',
        password: 'pass2',
        storeIds: [1],
      );

      expect(e1, e2);
    });

    test('employees with different ids should not be equal', () {
      final e1 = Employee(
        id: 1,
        lastName: 'Иванов',
        firstName: 'Иван',
        middleName: '',
        login: 'ivanov',
        password: 'pass',
        storeIds: [],
      );

      final e2 = Employee(
        id: 2,
        lastName: 'Иванов',
        firstName: 'Иван',
        middleName: '',
        login: 'ivanov',
        password: 'pass',
        storeIds: [],
      );

      expect(e1 != e2, true);
    });
  });
}
