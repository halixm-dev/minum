import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_event.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/main.dart'; // For logger

class DailyGoalSliderDialog extends StatefulWidget {
  final double initialGoal;
  final UserBloc userBloc;
  final UserModel? currentUser;
  final HydrationService hydrationService;

  const DailyGoalSliderDialog({
    super.key,
    required this.initialGoal,
    required this.userBloc,
    required this.currentUser,
    required this.hydrationService,
  });

  @override
  State<DailyGoalSliderDialog> createState() => _DailyGoalSliderDialogState();
}

class _DailyGoalSliderDialogState extends State<DailyGoalSliderDialog> {
  late double _currentGoal;
  double? _suggestedGoal;
  bool _isLoadingSuggestion = true;

  // Slider constants
  final double _minGoal = 1000;
  final double _maxGoal = 6000;
  final double _snapThreshold = 200; // Snap if within 200ml

  @override
  void initState() {
    super.initState();
    // Ensure initial goal is valid number
    double safeGoal = widget.initialGoal;
    if (safeGoal.isNaN || safeGoal.isInfinite) {
      safeGoal = 2000.0;
    }
    _currentGoal = safeGoal.clamp(_minGoal, _maxGoal);
    _calculateSuggestion();
  }

  Future<void> _calculateSuggestion() async {
    final user = widget.currentUser;
    if (user != null) {
      try {
        final suggestion = await widget.hydrationService
            .calculateRecommendedDailyIntake(user: user);
        if (mounted) {
          setState(() {
            _suggestedGoal = suggestion;
            _isLoadingSuggestion = false;
          });
        }
      } catch (e) {
        logger.e("Error calculating suggestion for slider: $e");
        if (mounted) {
          setState(() {
            _isLoadingSuggestion = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingSuggestion = false;
        });
      }
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _currentGoal = value;
    });
  }

  void _onSliderChangeEnd(double value) {
    if (_suggestedGoal != null) {
      if ((value - _suggestedGoal!).abs() < _snapThreshold) {
        setState(() {
          _currentGoal = _suggestedGoal!;
        });
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOz = widget.currentUser?.preferredUnit == MeasurementUnit.oz;

    // Display values
    final displayGoal =
        isOz ? (_currentGoal / 29.5735).round() : _currentGoal.round();
    final unitString = isOz ? AppStrings.oz : AppStrings.ml;

    return AlertDialog(
      title: const Text(AppStrings.dailyWaterGoal),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$displayGoal $unitString",
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          if (_isLoadingSuggestion)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: LinearProgressIndicator(),
            )
          else
            SizedBox(
              width: double.maxFinite,
              height: 50.0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sliderWidth = constraints.maxWidth;
                  // Slider standard padding is roughly 24.0 on each side (total 48)
                  // We need to account for this to align the dot with the track.
                  const double padding = 24.0;
                  // Ensure trackWidth is positive
                  final double trackWidth =
                      (sliderWidth - (padding * 2)).clamp(0.0, double.infinity);

                  double? markerPosition;
                  if (_suggestedGoal != null) {
                    final double t =
                        (_suggestedGoal! - _minGoal) / (_maxGoal - _minGoal);
                    // Clamp t between 0 and 1 just in case
                    final double clampedT = t.clamp(0.0, 1.0);
                    markerPosition = padding + (clampedT * trackWidth);
                  }

                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Layer 1: The Track (Visual only)
                      // We use an IgnorePointer + SliderTheme to hide the thumb/overlay
                      IgnorePointer(
                        child: SliderTheme(
                          data: theme.sliderTheme.copyWith(
                            thumbShape: SliderComponentShape.noThumb,
                            overlayShape: SliderComponentShape.noThumb,
                            // Maintain track visual properties
                            trackHeight: 4.0,
                          ),
                          child: SizedBox(
                            height: 48.0,
                            width: double.maxFinite,
                            child: Slider(
                              value: _currentGoal,
                              min: _minGoal,
                              max: _maxGoal,
                              divisions: ((_maxGoal - _minGoal) / 50).round(),
                              onChanged: (_) {}, // Dummy
                            ),
                          ),
                        ),
                      ),

                      // Layer 2: Visual Marker (Dot)
                      if (markerPosition != null)
                        Positioned(
                          left: markerPosition - 6.0, // Center the 12.0 dot
                          // Align vertically to center of stack.
                          top:
                              19.0, // 50.0 height container -> center 25. Dot is 12. Top = 25 - 6 = 19.
                          child: Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width:
                                      2.0 // Add a small border to separate from track visually if needed?
                                  // User just said "front of slider line".
                                  // Solid color is fine.
                                  ),
                            ),
                          ),
                        ),

                      // Layer 3: The Thumb & Interaction
                      // Use SliderTheme to hide the track
                      SliderTheme(
                        data: theme.sliderTheme.copyWith(
                          activeTrackColor: Colors.transparent,
                          inactiveTrackColor: Colors.transparent,
                          trackHeight:
                              4.0, // Match the track height to align thumb correctly
                          // Keep thumb and overlay visible
                        ),
                        child: SizedBox(
                          height: 48.0,
                          width: double.maxFinite,
                          child: Slider(
                            value: _currentGoal,
                            min: _minGoal,
                            max: _maxGoal,
                            divisions: ((_maxGoal - _minGoal) / 50).round(),
                            label: "$displayGoal",
                            onChanged: _onSliderChanged,
                            onChangeEnd: _onSliderChangeEnd,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (!_isLoadingSuggestion && _suggestedGoal != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _currentGoal = _suggestedGoal!;
                  });
                  HapticFeedback.mediumImpact();
                },
                icon: Icon(Symbols.auto_awesome, size: 18.sp),
                label: Text(
                    "Set to Suggested (${_suggestedGoal!.toInt()} $unitString)"),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.tertiary,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () async {
            if (widget.currentUser != null) {
              final updatedUser =
                  widget.currentUser!.copyWith(dailyGoalMl: _currentGoal);
              widget.userBloc.add(UpdateUserProfile(updatedUser));
            }
            if (context.mounted) {
              Navigator.of(context).pop();
              AppUtils.showSnackBar(context, "Daily goal updated!");
            }
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}
