import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';

class AdminSidebar extends StatelessWidget {
  final String selectedRoute;

  const AdminSidebar({super.key, required this.selectedRoute});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 220,
      color: scheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Меню',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _SidebarItem(
                  icon: Icons.home,
                  label: 'Главная',
                  route: AppRoutes.admin,
                  selectedRoute: selectedRoute,
                ),
                _SidebarItem(
                  icon: Icons.people,
                  label: 'Сотрудники',
                  route: AppRoutes.adminEmployees,
                  selectedRoute: selectedRoute,
                ),
                _SidebarItem(
                  icon: Icons.store,
                  label: 'Магазины',
                  route: AppRoutes.adminStores,
                  selectedRoute: selectedRoute,
                ),
                _SidebarItem(
                  icon: Icons.access_time,
                  label: 'Смены',
                  route: AppRoutes.adminShifts,
                  selectedRoute: selectedRoute,
                ),
                _SidebarItem(
                  icon: Icons.task,
                  label: 'Задачи',
                  route: AppRoutes.adminTasks,
                  selectedRoute: selectedRoute,
                ),
                _SidebarItem(
                  icon: Icons.bar_chart,
                  label: 'Статистика',
                  route: AppRoutes.adminStatistics,
                  selectedRoute: selectedRoute,
                ),
                _SidebarItem(
                  icon: Icons.search,
                  label: 'Поиск',
                  route: AppRoutes.adminSearch,
                  selectedRoute: selectedRoute,
                ),
                _SidebarItem(
                  icon: Icons.notifications,
                  label: 'Уведомления',
                  route: AppRoutes.adminNotifications,
                  selectedRoute: selectedRoute,
                ),
                _SidebarItem(
                  icon: Icons.history,
                  label: 'История',
                  route: AppRoutes.adminHistory,
                  selectedRoute: selectedRoute,
                ),
                _SidebarItem(
                  icon: Icons.settings,
                  label: 'Настройки',
                  route: AppRoutes.settings,
                  selectedRoute: selectedRoute,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final String selectedRoute;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.selectedRoute,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedRoute == widget.route;
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) {
        if (!selected) {
          setState(() => _isHovering = true);
          _controller.forward();
        }
      },
      onExit: (_) {
        if (!selected) {
          setState(() => _isHovering = false);
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Material(
            color: Colors.transparent,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          );
        },
        child: InkWell(
          onTap: () => context.go(widget.route),
          borderRadius: BorderRadius.circular(0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primaryContainer
                  : _isHovering
                  ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: selected
                  ? Border.all(color: scheme.primary, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                AnimatedScale(
                  scale: selected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.icon,
                    color: selected
                        ? scheme.primary
                        : _isHovering
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: selected
                          ? scheme.primary
                          : _isHovering
                          ? scheme.onSurface
                          : scheme.onSurface,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
