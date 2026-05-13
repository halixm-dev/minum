import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:minum/src/presentation/providers/theme_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Appearance",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Mode",
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 12.h),
          _buildThemeModeSelector(context, themeProvider, theme),
          SizedBox(height: 24.h),
          Text(
            "Color Scheme",
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 12.h),
          _buildThemeSourceSelector(context, themeProvider, theme),
          SizedBox(height: 24.h),
          Text(
            "Contrast",
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 12.h),
          _buildContrastSelector(context, themeProvider, theme),
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector(
      BuildContext context, ThemeProvider provider, ThemeData theme) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Symbols.settings_brightness),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Symbols.light_mode),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Symbols.dark_mode),
        ),
      ],
      selected: <ThemeMode>{provider.themeMode},
      onSelectionChanged: (Set<ThemeMode> newSelection) {
        provider.setThemeMode(newSelection.first);
      },
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        side: WidgetStateProperty.all(
          BorderSide(color: theme.colorScheme.outline),
        ),
      ),
    );
  }

  Widget _buildContrastSelector(
      BuildContext context, ThemeProvider provider, ThemeData theme) {
    return SegmentedButton<ContrastLevel>(
      segments: const [
        ButtonSegment<ContrastLevel>(
          value: ContrastLevel.normal,
          label: Text('Normal'),
          icon: Icon(Symbols.contrast),
        ),
        ButtonSegment<ContrastLevel>(
          value: ContrastLevel.medium,
          label: Text('Medium'),
          icon: Icon(Symbols.contrast_rtl_off),
        ),
        ButtonSegment<ContrastLevel>(
          value: ContrastLevel.high,
          label: Text('High'),
          icon: Icon(Symbols.contrast_rtl_off),
        ),
      ],
      selected: <ContrastLevel>{provider.contrastLevel},
      onSelectionChanged: (Set<ContrastLevel> newSelection) {
        provider.setContrastLevel(newSelection.first);
      },
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        side: WidgetStateProperty.all(
          BorderSide(color: theme.colorScheme.outline),
        ),
      ),
    );
  }

  Widget _buildThemeSourceSelector(
      BuildContext context, ThemeProvider provider, ThemeData theme) {
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          // Calculate item width based on available width and desired columns (3)
          // Subtract spacing (12.w * 2 for 2 gaps)
          final double itemWidth = (constraints.maxWidth - 24.w) / 3;

          return Wrap(
            spacing: 12.w,
            runSpacing: 12.w,
            children: [
              _buildSourceOption(
                context,
                provider,
                ThemeSource.baseline,
                "Default",
                theme.colorScheme.primary, // Or a specific brand color
                width: itemWidth,
              ),
              _buildSourceOption(
                context,
                provider,
                ThemeSource.dynamicSystem,
                "Dynamic",
                Colors.teal, // Representation for dynamic
                isDynamic: true,
                width: itemWidth,
              ),
              _buildSourceOption(
                context,
                provider,
                ThemeSource.customSeed,
                "Custom",
                provider.customSeedColor ?? Colors.blue,
                isCustom: true,
                width: itemWidth,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSourceOption(
    BuildContext context,
    ThemeProvider provider,
    ThemeSource source,
    String label,
    Color color, {
    bool isCustom = false,
    bool isDynamic = false,
    required double width,
  }) {
    final bool isSelected = provider.themeSource == source;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (isCustom) {
            Color newColor =
                provider.customSeedColor ?? const Color(0xFF2196F3);
            final bool confirmed = await ColorPicker(
              color: newColor,
              onColorChanged: (Color color) {
                newColor = color;
              },
              width: 40.w,
              height: 40.w,
              borderRadius: 20.r,
              spacing: 10.w,
              runSpacing: 10.w,
              wheelDiameter: 165.w,
              heading: Text(
                'Select color',
                style: theme.textTheme.titleMedium,
              ),
              subheading: Text(
                'Select color shade',
                style: theme.textTheme.titleSmall,
              ),
              wheelSubheading: Text(
                'Selected color and its shades',
                style: theme.textTheme.titleSmall,
              ),
              showMaterialName: true,
              showColorName: true,
              showColorCode: true,
              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                longPressMenu: true,
              ),
              materialNameTextStyle: theme.textTheme.bodySmall,
              colorNameTextStyle: theme.textTheme.bodySmall,
              colorCodeTextStyle: theme.textTheme.bodySmall,
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.both: false,
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
                ColorPickerType.bw: false,
                ColorPickerType.custom: false,
                ColorPickerType.wheel: true,
              },
            ).showPickerDialog(
              context,
              constraints: const BoxConstraints(
                  minHeight: 480, minWidth: 320, maxWidth: 320),
            );

            if (confirmed) {
              provider.setCustomSeedColor(newColor);
              provider.setThemeSource(ThemeSource.customSeed);
            } else {
              if (provider.themeSource != ThemeSource.customSeed &&
                  provider.customSeedColor != null) {
                provider.setThemeSource(ThemeSource.customSeed);
              }
            }
          } else {
            provider.setThemeSource(source);
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12.r),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: isCustom && isSelected
                    ? Icon(Symbols.edit,
                        size: 16.sp,
                        color:
                            Colors.white) // Show edit icon if custom is active
                    : isDynamic
                        ? Icon(Symbols.wallpaper,
                            size: 16.sp, color: Colors.white)
                        : null,
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
