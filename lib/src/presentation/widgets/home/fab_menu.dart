import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/hydration_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class FabMenu extends StatefulWidget {
  const FabMenu({super.key});

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildTapToCloseLayer(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          color: Theme.of(context).scrim.withOpacity(0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final quickAddVolumes = userProvider.userProfile?.quickAddVolumes ?? [];

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isOpen) _buildTapToCloseLayer(context),
        Positioned(
          bottom: 0,
          right: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ..._buildMenuItems(context, quickAddVolumes),
              SizedBox(height: 16.h),
              FloatingActionButton(
                onPressed: _toggleMenu,
                heroTag: 'main_fab',
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(child: child, scale: animation);
                  },
                  child: _isOpen
                      ? const Icon(Symbols.close,
                          key: ValueKey('close'),
                          weight: 600,
                          fontFamily: MaterialSymbols.rounded)
                      : const Icon(Symbols.add,
                          key: ValueKey('add'),
                          weight: 600,
                          fontFamily: MaterialSymbols.rounded),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems(
      BuildContext context, List<int> quickAddVolumes) {
    final List<Widget> menuItems = [];
    final reversedVolumes = quickAddVolumes.reversed.toList();

    // Manual Entry Button
    final manualEntryItem = _FabMenuItem(
      animation: _animationController,
      label: 'Manual Entry',
      icon: Symbols.edit,
      onPressed: () {
        _toggleMenu();
        Navigator.of(context).pushNamed(AppRoutes.addWaterLog);
      },
    );
    menuItems.add(manualEntryItem);

    // Quick Add Volume Buttons
    for (final volume in reversedVolumes) {
      final item = _FabMenuItem(
        animation: _animationController,
        label: '${volume}ml',
        icon: Symbols.water_drop,
        onPressed: () {
          _toggleMenu();
          context.read<HydrationProvider>().addWater(volume.toDouble());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${volume}ml'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      );
      menuItems.add(item);
    }

    return menuItems;
  }
}

class _FabMenuItem extends StatelessWidget {
  final Animation<double> animation;
  final String label;
  final int icon;
  final VoidCallback onPressed;

  const _FabMenuItem({
    required this.animation,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h, right: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              _PressableFab(
                onPressed: onPressed,
                icon: icon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PressableFab extends StatefulWidget {
  final VoidCallback onPressed;
  final int icon;

  const _PressableFab({required this.onPressed, required this.icon});

  @override
  State<_PressableFab> createState() => __PressableFabState();
}

class __PressableFabState extends State<_PressableFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        // Delay helps visualize the press effect before the menu closes
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() => _isPressed = false);
          }
        });
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: FloatingActionButton.small(
        onPressed: () {}, // NOP; handled by GestureDetector
        heroTag: null, // Needed for multiple FABs on one screen
        child: Icon(
          IconData(widget.icon, fontFamily: MaterialSymbols.rounded),
          weight: 600,
          fill: _isPressed ? 1.0 : 0.0,
        ),
      ),
    );
  }
}
