import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/employee_controller.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/task_controller.dart';
import 'admin_base_page.dart';

class AdminGlobalSearchPage extends StatefulWidget {
  const AdminGlobalSearchPage({super.key});

  @override
  State<AdminGlobalSearchPage> createState() => _AdminGlobalSearchPageState();
}

class _AdminGlobalSearchPageState extends State<AdminGlobalSearchPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/search',
      title: 'Поиск',
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Поиск сотрудников, задач, магазинов...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          if (_searchCtrl.text.trim().length >= 2)
            Expanded(child: _buildResults(_searchCtrl.text.trim()))
          else
            const Expanded(
              child: Center(
                child: Text('Введите минимум 2 символа для поиска'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults(String query) {
    final lowerQuery = query.toLowerCase();

    final employees = context.read<EmployeeController>().employees.where((e) {
      return e.fullName.toLowerCase().contains(lowerQuery) ||
          e.login.toLowerCase().contains(lowerQuery);
    }).toList();

    final tasks = context.read<TaskController>().tasks.where((t) {
      return t.title.toLowerCase().contains(lowerQuery) ||
          (t.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    final stores = context.read<StoreController>().stores.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
          s.address.toLowerCase().contains(lowerQuery);
    }).toList();

    return ListView(
      children: [
        if (employees.isNotEmpty) ...[
          _buildSectionHeader('Сотрудники', employees.length),
          ...employees.map(
            (e) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(e.fullName),
              subtitle: Text(e.login),
              dense: true,
            ),
          ),
        ],
        if (tasks.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionHeader('Задачи', tasks.length),
          ...tasks.map(
            (t) => ListTile(
              leading: const Icon(Icons.task),
              title: Text(t.title),
              subtitle: Text(t.category ?? 'Без категории'),
              dense: true,
            ),
          ),
        ],
        if (stores.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionHeader('Магазины', stores.length),
          ...stores.map(
            (s) => ListTile(
              leading: const Icon(Icons.store),
              title: Text(s.name),
              subtitle: Text(s.address),
              dense: true,
            ),
          ),
        ],
        if (employees.isEmpty && tasks.isEmpty && stores.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('Ничего не найдено')),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
