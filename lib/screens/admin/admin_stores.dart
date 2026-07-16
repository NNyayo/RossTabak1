import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/store_controller.dart';
import '../../models/store.dart';
import '../../utils/marker_color.dart';
import '../../widgets/store_card.dart';
import 'admin_base_page.dart';

class AdminStoresPage extends StatefulWidget {
  const AdminStoresPage({super.key});

  @override
  State<AdminStoresPage> createState() => _AdminStoresPageState();
}

class _AdminStoresPageState extends State<AdminStoresPage> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/stores',
      title: 'Торговые точки',
      child: Column(
        children: [
          _buildSearch(),
          const SizedBox(height: 12),
          Expanded(child: _buildStoreList()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Поиск по названию или адресу',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _addStore(context),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildStoreList() {
    return Consumer<StoreController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var stores = controller.stores;

        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          stores = stores.where((s) {
            final name = s.name.toLowerCase();
            final address = s.address.toLowerCase();
            return name.contains(query) || address.contains(query);
          }).toList();
        }

        if (stores.isEmpty) {
          return const Center(child: Text('Торговые точки не найдены'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: stores.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final store = stores[index];
            return InkWell(
              onTap: () => _showStoreDetails(context, store),
              borderRadius: BorderRadius.circular(16),
              child: StoreCard(store: store),
            );
          },
        );
      },
    );
  }

  Future<void> _addStore(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddStoreDialog(),
    );

    if (result != null && mounted) {
      final controller = context.read<StoreController>();
      await controller.createStore(
        Store(
          name: result['name']!,
          address: result['address']!,
          metro: result['metro']!,
          markerColor: result['color']!,
          isActive: true,
        ),
      );
    }
  }

  void _showStoreDetails(BuildContext context, Store store) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(store.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 ${store.address}'),
            const SizedBox(height: 8),
            Text('🚇 ${store.metro}'),
            const SizedBox(height: 8),
            Text(
              store.isActive ? 'Статус: Активна' : 'Статус: Архив',
              style: TextStyle(
                color: store.isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editStore(context, store);
            },
            child: const Text('Редактировать'),
          ),
        ],
      ),
    );
  }

  Future<void> _editStore(BuildContext context, Store store) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditStoreDialog(store: store),
    );

    if (result != null && mounted) {
      final controller = context.read<StoreController>();
      await controller.updateStore(
        Store(
          id: store.id,
          name: result['name']!,
          address: result['address']!,
          metro: result['metro']!,
          markerColor: result['color']!,
          isActive: store.isActive,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Точка обновлена')));
      }
    }
  }
}

class AddStoreDialog extends StatefulWidget {
  const AddStoreDialog({super.key});

  @override
  State<AddStoreDialog> createState() => _AddStoreDialogState();
}

class _AddStoreDialogState extends State<AddStoreDialog> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _metro = 'Василеостровская';
  String _color = 'Белый';

  final List<String> _metros = [
    'Автово',
    'Адмиралтейская',
    'Академическая',
    'Балтийская',
    'Бухарестская',
    'Василеостровская',
    'Владимирская',
    'Волковская',
    'Выборгская',
    'Гостиный двор',
    'Гражданский проспект',
    'Девяткино',
    'Достоевская',
    'Дыбенко',
    'Елизаровская',
    'Звенигородская',
    'ЗиП',
    'Кировский завод',
    'Комендантский проспект',
    'Купчино',
    'Ладожская',
    'Ленинский проспект',
    'Лесная',
    'Лиговский проспект',
    'Маяковская',
    'Международная',
    'Московская',
    'Московские ворота',
    'Нарвская',
    'Невский проспект',
    'Новочеркасская',
    'Обухово',
    'Озерки',
    'Парк Победы',
    'Парнас',
    'Петроградская',
    'Пионерская',
    'Площадь Александра Невского',
    'Площадь Восстания',
    'Площадь Мужества',
    'Проспект Большевиков',
    'Проспект Ветеранов',
    'Проспект Просвещения',
    'Пулковская',
    'Пушкинская',
    'Рыбацкое',
    'Садовая',
    'Сенная площадь',
    'Славянка',
    'Средняя',
    'Спасская',
    'Спортивная',
    'Старая Деревня',
    'Технологический институт',
    'Удельная',
    'Улица Дыбенко',
    'Чернышевская',
    'Чкаловская',
    'Электросила',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = const [
      'Белый',
      'Красный',
      'Синий',
      'Зелёный',
      'Оранжевый',
      'Фиолетовый',
      'Коричневый',
    ];

    return AlertDialog(
      title: const Text('Добавить точку'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Название *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Адрес *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _metro,
                decoration: const InputDecoration(
                  labelText: 'Метро',
                  border: OutlineInputBorder(),
                ),
                items: _metros.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (v) => setState(() => _metro = v!),
              ),
              const SizedBox(height: 12),
              const Text(
                'Цвет:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colors.map((c) {
                  final selected = _color == c;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _getColor(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.blue : Colors.grey,
                          width: selected ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty ||
                _addressCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Заполните все поля')),
              );
              return;
            }
            Navigator.pop(context, {
              'name': _nameCtrl.text.trim(),
              'address': _addressCtrl.text.trim(),
              'metro': _metro,
              'color': _color,
            });
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }

  Color _getColor(String name) {
    return getMarkerColorForDot(name);
  }
}

class EditStoreDialog extends StatefulWidget {
  final Store store;

  const EditStoreDialog({super.key, required this.store});

  @override
  State<EditStoreDialog> createState() => _EditStoreDialogState();
}

class _EditStoreDialogState extends State<EditStoreDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late String _metro;
  late String _color;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.store.name);
    _addressCtrl = TextEditingController(text: widget.store.address);
    _metro = widget.store.metro;
    _color = widget.store.markerColor;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = const [
      'Белый',
      'Красный',
      'Синий',
      'Зелёный',
      'Оранжевый',
      'Фиолетовый',
      'Коричневый',
    ];

    return AlertDialog(
      title: const Text('Редактировать точку'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Название *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Адрес *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _metro,
                decoration: const InputDecoration(
                  labelText: 'Метро',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Автово', child: Text('Автово')),
                  DropdownMenuItem(
                    value: 'Адмиралтейская',
                    child: Text('Адмиралтейская'),
                  ),
                  DropdownMenuItem(
                    value: 'Василеостровская',
                    child: Text('Василеостровская'),
                  ),
                  DropdownMenuItem(
                    value: 'Площадь Восстания',
                    child: Text('Площадь Восстания'),
                  ),
                  DropdownMenuItem(
                    value: 'Маяковская',
                    child: Text('Маяковская'),
                  ),
                  DropdownMenuItem(
                    value: 'Парк Победы',
                    child: Text('Парк Победы'),
                  ),
                  DropdownMenuItem(
                    value: 'Девяткино',
                    child: Text('Девяткино'),
                  ),
                  DropdownMenuItem(
                    value: 'Проспект Ветеранов',
                    child: Text('Проспект Ветеранов'),
                  ),
                  DropdownMenuItem(value: 'Лесная', child: Text('Лесная')),
                  DropdownMenuItem(
                    value: 'Выборгская',
                    child: Text('Выборгская'),
                  ),
                  DropdownMenuItem(
                    value: 'Проспект Просвещения',
                    child: Text('Проспект Просвещения'),
                  ),
                  DropdownMenuItem(value: 'Удельная', child: Text('Удельная')),
                  DropdownMenuItem(
                    value: 'Площадь Мужества',
                    child: Text('Площадь Мужества'),
                  ),
                  DropdownMenuItem(value: 'Рыбацкое', child: Text('Рыбацкое')),
                  DropdownMenuItem(
                    value: 'Ломоносовская',
                    child: Text('Ломоносовская'),
                  ),
                  DropdownMenuItem(
                    value: 'Пулковская',
                    child: Text('Пулковская'),
                  ),
                  DropdownMenuItem(value: 'Зенит', child: Text('Зенит')),
                ],
                onChanged: (v) => setState(() => _metro = v!),
              ),
              const SizedBox(height: 12),
              const Text(
                'Цвет:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colors.map((c) {
                  final selected = _color == c;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _getColor(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.blue : Colors.grey,
                          width: selected ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty ||
                _addressCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Заполните все поля')),
              );
              return;
            }
            Navigator.pop(context, {
              'name': _nameCtrl.text.trim(),
              'address': _addressCtrl.text.trim(),
              'metro': _metro,
              'color': _color,
            });
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  Color _getColor(String name) {
    return getMarkerColorForDot(name);
  }
}
