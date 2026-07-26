import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';

class AdminSidebar extends StatefulWidget {
  final String selectedRoute;

  const AdminSidebar({super.key, required this.selectedRoute});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  final Set<String> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    // Auto-expand groups based on selected route
    if (_isInGroup('stores', widget.selectedRoute)) {
      _expandedGroups.add('stores');
    }
    if (_isInGroup('tasks', widget.selectedRoute)) {
      _expandedGroups.add('tasks');
    }
    if (_isInGroup('settings', widget.selectedRoute)) {
      _expandedGroups.add('settings');
    }
  }

  bool _isInGroup(String group, String route) {
    switch (group) {
      case 'stores':
        return route == AppRoutes.adminEmployees ||
            route == AppRoutes.adminStores ||
            route == AppRoutes.adminShifts;
      case 'tasks':
        return route == AppRoutes.adminTasks ||
            route == AppRoutes.adminDailyTasks ||
            route == AppRoutes.adminTasksStats ||
            route == AppRoutes.adminStatistics;
      case 'settings':
        return route == AppRoutes.adminNotifications ||
            route == AppRoutes.adminHistory ||
            route == AppRoutes.adminSearch ||
            route == AppRoutes.settings;
      default:
        return false;
    }
  }

  void _toggleGroup(String group) {
    setState(() {
      if (_expandedGroups.contains(group)) {
        _expandedGroups.remove(group);
      } else {
        _expandedGroups.add(group);
      }
    });
  }

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
                // Главная
                _SidebarItem(
                  icon: Icons.home,
                  label: 'Главная',
                  route: AppRoutes.admin,
                  selectedRoute: widget.selectedRoute,
                ),
                const Divider(height: 1, indent: 12, endIndent: 12),

                // Магазины > Сотрудники > Смены
                _SidebarGroup(
                  icon: Icons.store,
                  label: 'Магазины',
                  groupKey: 'stores',
                  isExpanded: _expandedGroups.contains('stores'),
                  onToggle: () => _toggleGroup('stores'),
                  children: [
                    _SidebarItem(
                      icon: Icons.people,
                      label: 'Сотрудники',
                      route: AppRoutes.adminEmployees,
                      selectedRoute: widget.selectedRoute,
                    ),
                    _SidebarItem(
                      icon: Icons.store,
                      label: 'Магазины',
                      route: AppRoutes.adminStores,
                      selectedRoute: widget.selectedRoute,
                    ),
                    _SidebarItem(
                      icon: Icons.access_time,
                      label: 'Смены',
                      route: AppRoutes.adminShifts,
                      selectedRoute: widget.selectedRoute,
                    ),
                  ],
                ),
                const Divider(height: 1, indent: 12, endIndent: 12),

                // Задачи > Ежедневные задачи > Статистика
                _SidebarGroup(
                  icon: Icons.task,
                  label: 'Задачи',
                  groupKey: 'tasks',
                  isExpanded: _expandedGroups.contains('tasks'),
                  onToggle: () => _toggleGroup('tasks'),
                  children: [
                    _SidebarItem(
                      icon: Icons.task,
                      label: 'Задачи',
                      route: AppRoutes.adminTasks,
                      selectedRoute: widget.selectedRoute,
                    ),
                    _SidebarItem(
                      icon: Icons.repeat,
                      label: 'Ежедневные задачи',
                      route: AppRoutes.adminDailyTasks,
                      selectedRoute: widget.selectedRoute,
                    ),
                    _SidebarItem(
                      icon: Icons.bar_chart,
                      label: 'Статистика',
                      route: AppRoutes.adminStatistics,
                      selectedRoute: widget.selectedRoute,
                    ),
                  ],
                ),
                const Divider(height: 1, indent: 12, endIndent: 12),

                // Настройки > Уведомления > История > Поиск
                _SidebarGroup(
                  icon: Icons.settings,
                  label: 'Настройки',
                  groupKey: 'settings',
                  isExpanded: _expandedGroups.contains('settings'),
                  onToggle: () => _toggleGroup('settings'),
                  children: [
                    _SidebarItem(
                      icon: Icons.notifications,
                      label: 'Уведомления',
                      route: AppRoutes.adminNotifications,
                      selectedRoute: widget.selectedRoute,
                    ),
                    _SidebarItem(
                      icon: Icons.history,
                      label: 'История',
                      route: AppRoutes.adminHistory,
                      selectedRoute: widget.selectedRoute,
                    ),
                    _SidebarItem(
                      icon: Icons.search,
                      label: 'Поиск',
                      route: AppRoutes.adminSearch,
                      selectedRoute: widget.selectedRoute,
                    ),
                    _SidebarItem(
                      icon: Icons.info_outline,
                      label: 'О программе',
                      route: AppRoutes.settings,
                      selectedRoute: widget.selectedRoute,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarGroup extends StatelessWidget {
  final IconData icon;
  final String label;
  final String groupKey;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _SidebarGroup({
    required this.icon,
    required this.label,
    required this.groupKey,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: scheme.onSurfaceVariant, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: scheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
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
            padding: const EdgeInsets.only(
              left: 36,
              right: 12,
              top: 8,
              bottom: 8,
            ),
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
                    size: 18,
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
                      fontSize: 13,
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
