// lib/src/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger

/// A screen where users can view and edit their profile information.
class ProfileScreen extends StatefulWidget {
  /// Creates a `ProfileScreen`.
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _dateOfBirthController;

  late FocusNode _displayNameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _heightFocusNode;
  late FocusNode _weightFocusNode;

  DateTime? _selectedDateOfBirth;
  Gender? _selectedGender;
  ActivityLevel? _selectedActivityLevel;
  List<HealthCondition> _selectedHealthConditions = [HealthCondition.none];
  WeatherCondition _selectedWeatherCondition = WeatherCondition.temperate;

  bool _isLoading = false;
  bool _isDirty = false;
  UserModel? _lastProcessedUserProfile;

  String _getGenderDisplayString(Gender? gender) {
    if (gender == null) return "Prefer not to say";
    switch (gender) {
      case Gender.male:
        return "Male";
      case Gender.female:
        return "Female";
    }
  }

  String _getActivityLevelDisplayString(ActivityLevel? level) {
    if (level == null) return "Not Set";
    switch (level) {
      case ActivityLevel.sedentary:
        return "Sedentary (little or no exercise)";
      case ActivityLevel.light:
        return "Light (exercise 1-3 days/week)";
      case ActivityLevel.moderate:
        return "Moderate (exercise 3-5 days/week)";
      case ActivityLevel.active:
        return "Active (exercise 6-7 days/week)";
      case ActivityLevel.extraActive:
        return "Extra Active (exercise 1+ times/day)";
    }
  }

  String _getHealthConditionDisplayString(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.none:
        return "None";
      case HealthCondition.pregnancy:
        return "Pregnancy";
      case HealthCondition.breastfeeding:
        return "Breastfeeding";
      case HealthCondition.kidneyIssues:
        return "Kidney Issues";
      case HealthCondition.heartConditions:
        return "Heart Conditions";
    }
  }

  String _getWeatherConditionDisplayString(WeatherCondition weather) {
    switch (weather) {
      case WeatherCondition.temperate:
        return "Temperate";
      case WeatherCondition.hot:
        return "Hot";
      case WeatherCondition.hotAndHumid:
        return "Hot & Humid";
      case WeatherCondition.cold:
        return "Cold";
    }
  }

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _dateOfBirthController = TextEditingController();

    _displayNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _heightFocusNode = FocusNode();
    _weightFocusNode = FocusNode();

    _setupControllerListeners();
  }

  /// Populates the form fields with the user's current profile data.
  void _loadInitialProfileData() {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? userProfile = userProvider.userProfile;

    if (userProfile != null) {
      _displayNameController.text = userProfile.displayName ?? '';
      _emailController.text = userProfile.email ?? 'Not available';

      _weightController.text = userProfile.weightKg?.toString() ?? '';
      _heightController.text = userProfile.heightCm?.toString() ?? '';

      _selectedActivityLevel = userProfile.activityLevel;
      _selectedDateOfBirth = userProfile.dateOfBirth;
      _dateOfBirthController.text = _selectedDateOfBirth != null
          ? DateFormat.yMMMd().format(_selectedDateOfBirth!)
          : '';
      _selectedGender = userProfile.gender;

      List<HealthCondition> initialHealthConditions =
          List.from(userProfile.healthConditions ?? [HealthCondition.none]);
      if (initialHealthConditions.isEmpty) {
        initialHealthConditions = [HealthCondition.none];
      }
      if (_selectedGender != Gender.female) {
        initialHealthConditions.removeWhere((c) =>
            c == HealthCondition.pregnancy ||
            c == HealthCondition.breastfeeding);
        if (initialHealthConditions.isEmpty) {
          initialHealthConditions = [HealthCondition.none];
        }
      }
      _selectedHealthConditions = initialHealthConditions;
      _selectedWeatherCondition =
          userProfile.selectedWeatherCondition ?? WeatherCondition.temperate;
    } else {
      _displayNameController.text = '';
      _emailController.text = 'Not available';
      _weightController.text = '';
      _heightController.text = '';
      _selectedActivityLevel = null;
      _selectedDateOfBirth = null;
      _dateOfBirthController.text = '';
      _selectedGender = null;
      _selectedHealthConditions = [HealthCondition.none];
      _selectedWeatherCondition = WeatherCondition.temperate;
    }

    _lastProcessedUserProfile = userProfile;
    _isDirty = false;
  }

  void _setupControllerListeners() {
    _displayNameController.addListener(_setIsDirty);
    _weightController.addListener(_setIsDirty);
    _heightController.addListener(_setIsDirty);
  }

  void _setIsDirty() {
    if (!mounted) return;
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _dateOfBirthController.dispose();

    _displayNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();

    super.dispose();
  }

  /// Shows a date picker to select the user's date of birth.
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateOfBirth ??
            DateTime.now().subtract(const Duration(days: 365 * 25)),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        helpText: "Select Date of Birth");
    if (picked != null && picked != _selectedDateOfBirth) {
      if (mounted) {
        setState(() {
          _selectedDateOfBirth = picked;
          _dateOfBirthController.text = DateFormat.yMMMd().format(picked);
          _isDirty = true;
        });
      }
    }
  }

  /// Saves the updated profile information.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final hydrationService =
        Provider.of<HydrationService>(context, listen: false);
    final currentUser = userProvider.userProfile;

    if (currentUser == null) {
      if (mounted) {
        AppUtils.showSnackBar(context, "User not found. Cannot save profile.",
            isError: true);
      }
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final String newDisplayName = _displayNameController.text.trim();
    final double? newWeight = _weightController.text.trim().isEmpty
        ? null
        : double.tryParse(_weightController.text.trim());
    final double? newHeight = _heightController.text.trim().isEmpty
        ? null
        : double.tryParse(_heightController.text.trim());

    List<HealthCondition> finalHealthConditions = _selectedHealthConditions;
    if (finalHealthConditions.contains(HealthCondition.none) &&
        finalHealthConditions.length > 1) {
      finalHealthConditions = finalHealthConditions
          .where((c) => c != HealthCondition.none)
          .toList();
    }
    if (finalHealthConditions.isEmpty) {
      finalHealthConditions = [HealthCondition.none];
    }
    if (_selectedGender != Gender.female) {
      finalHealthConditions.removeWhere((c) =>
          c == HealthCondition.pregnancy || c == HealthCondition.breastfeeding);
      if (finalHealthConditions.isEmpty) {
        finalHealthConditions = [HealthCondition.none];
      }
    }

    // Create a temporary user object with the new profile data for calculation
    UserModel updatedUser = currentUser.copyWith(
        displayName: newDisplayName,
        weightKg: newWeight,
        clearWeightKg: _weightController.text.trim().isEmpty,
        heightCm: newHeight,
        clearHeightCm: _heightController.text.trim().isEmpty,
        dateOfBirth: _selectedDateOfBirth,
        clearDateOfBirth:
            _selectedDateOfBirth == null && currentUser.dateOfBirth != null,
        gender: _selectedGender,
        clearGender: _selectedGender == null && currentUser.gender != null,
        activityLevel: _selectedActivityLevel,
        clearActivityLevel:
            _selectedActivityLevel == null && currentUser.activityLevel != null,
        healthConditions: finalHealthConditions,
        selectedWeatherCondition: _selectedWeatherCondition,
        favoriteIntakeVolumes: currentUser.favoriteIntakeVolumes);

    // Calculate new goal
    double newDailyGoal = 2000.0;
    try {
      newDailyGoal = await hydrationService.calculateRecommendedDailyIntake(
          user: updatedUser);
      logger.i("Auto-calculated new goal: $newDailyGoal");
    } catch (e) {
      logger.e("Error auto-calculating goal: $e");
      // Fallback to existing goal if calculation fails completely, though
      // calculateRecommendedDailyIntake usually returns a fallback.
      newDailyGoal = currentUser.dailyGoalMl;
    }

    // Update the user object with the new goal
    updatedUser = updatedUser.copyWith(dailyGoalMl: newDailyGoal);

    try {
      await userProvider.updateUserProfile(updatedUser);
      if (mounted) {
        String messageToShow =
            "Profile updated! Daily goal adjusted to ${newDailyGoal.toInt()} mL.";
        bool isPresentationError = false;

        if (userProvider.status == UserProfileStatus.loaded) {
          if (userProvider.errorMessage != null &&
              userProvider.errorMessage ==
                  "Profile saved locally. Will sync when online.") {
            messageToShow = userProvider.errorMessage!;
            isPresentationError = false;
          } else if (userProvider.errorMessage != null) {
            messageToShow = userProvider.errorMessage!;
            isPresentationError = true;
          }
        } else if (userProvider.status == UserProfileStatus.error) {
          messageToShow =
              userProvider.errorMessage ?? "Failed to update profile.";
          isPresentationError = true;
        }

        AppUtils.showSnackBar(context, messageToShow,
            isError: isPresentationError);

        if (!isPresentationError) {
          setState(() {
            _isDirty = false;
          });
        }
      }
    } catch (e) {
      logger.e("Error updating profile: $e");
      if (mounted) {
        AppUtils.showSnackBar(
            context, userProvider.errorMessage ?? "Failed to update profile.",
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final UserModel? user = userProvider.userProfile;
        final UserProfileStatus status = userProvider.status;

        if (status == UserProfileStatus.loading ||
            (status == UserProfileStatus.idle && user == null)) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.profile)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.profile)),
            body: Center(
                child: Text(
                    userProvider.errorMessage ?? "User data unavailable.")),
          );
        }

        if (userProvider.status == UserProfileStatus.loaded &&
            user != _lastProcessedUserProfile) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadInitialProfileData();
            }
          });
        }

        List<HealthCondition> availableHealthConditions =
            List.from(HealthCondition.values);
        if (_selectedGender != Gender.female) {
          availableHealthConditions.removeWhere((c) =>
              c == HealthCondition.pregnancy ||
              c == HealthCondition.breastfeeding);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.profile),
            centerTitle: true,
            actions: [
              if (_isDirty)
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: TextButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary))
                        : Text("SAVE",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.fontWeight)),
                  ),
                )
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildPersonalInformationCard(context),
                  SizedBox(height: 16.h),
                  _buildLifestyleEnvironmentCard(context),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalInformationCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Personal Information', Symbols.person),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _displayNameController,
              focusNode: _displayNameFocusNode,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Symbols.person),
              ),
              validator: (value) =>
                  AppUtils.validateNotEmpty(value, fieldName: "Display name"),
              textInputAction: TextInputAction.next,
              onChanged: (_) => _setIsDirty(),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: const InputDecoration(
                labelText: AppStrings.email,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Symbols.email),
              ),
              readOnly: true,
              enabled: false,
            ),
            SizedBox(height: 16.h),
            _buildDatePickerField(
                context, "Date of Birth", _selectedDateOfBirth),
            SizedBox(height: 16.h),
            _buildDropdown<Gender?>(
              label: "Gender",
              value: _selectedGender,
              items: [null, Gender.male, Gender.female],
              onChanged: (Gender? newValue) {
                if (mounted) {
                  setState(() {
                    _selectedGender = newValue;
                    _isDirty = true;
                    if (newValue != Gender.female) {
                      _selectedHealthConditions.removeWhere((c) =>
                          c == HealthCondition.pregnancy ||
                          c == HealthCondition.breastfeeding);
                      if (_selectedHealthConditions.isEmpty) {
                        _selectedHealthConditions = [HealthCondition.none];
                      }
                    }
                  });
                }
              },
              itemAsString: _getGenderDisplayString,
              prefixIcon: Symbols.wc,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    focusNode: _heightFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Symbols.height),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                    ],
                    validator: (val) => (val == null || val.isEmpty)
                        ? null
                        : AppUtils.validateNumber(val, allowDecimal: true),
                    onChanged: (_) => _setIsDirty(),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    focusNode: _weightFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Symbols.monitor_weight),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => (value == null || value.isEmpty)
                        ? null
                        : AppUtils.validateNumber(value, allowDecimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                    ],
                    onChanged: (_) => _setIsDirty(),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleEnvironmentCard(BuildContext context) {
    List<HealthCondition> availableHealthConditions =
        List.from(HealthCondition.values);
    if (_selectedGender != Gender.female) {
      availableHealthConditions.removeWhere((c) =>
          c == HealthCondition.pregnancy || c == HealthCondition.breastfeeding);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
                context, 'Lifestyle & Environment', Symbols.nature_people),
            SizedBox(height: 16.h),
            _buildDropdown<ActivityLevel?>(
              label: AppStrings.activityLevel,
              value: _selectedActivityLevel,
              items: [null, ...ActivityLevel.values],
              onChanged: (ActivityLevel? newValue) {
                if (mounted) {
                  setState(() {
                    _selectedActivityLevel = newValue;
                    _isDirty = true;
                  });
                }
              },
              itemAsString: _getActivityLevelDisplayString,
              prefixIcon: Symbols.directions_run,
            ),
            SizedBox(height: 16.h),
            _buildMultiSelectChipGroup<HealthCondition>(
              label: "Health Conditions (Optional)",
              allOptions: availableHealthConditions,
              selectedOptions: _selectedHealthConditions,
              optionAsString: _getHealthConditionDisplayString,
              onSelectionChanged: (selected) {
                if (mounted) {
                  setState(() {
                    _selectedHealthConditions = selected;
                    _isDirty = true;
                  });
                }
              },
            ),
            SizedBox(height: 16.h),
            _buildDropdown<WeatherCondition>(
              label: "Typical Weather",
              value: _selectedWeatherCondition,
              items: WeatherCondition.values,
              onChanged: (WeatherCondition? newValue) {
                if (newValue != null && mounted) {
                  setState(() {
                    _selectedWeatherCondition = newValue;
                    _isDirty = true;
                  });
                }
              },
              itemAsString: _getWeatherConditionDisplayString,
              prefixIcon: Symbols.thermostat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
      BuildContext context, String label, DateTime? selectedDate) {
    return TextFormField(
      controller: _dateOfBirthController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Symbols.calendar_today),
      ),
      onTap: () => _selectDateOfBirth(context),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T item) itemAsString,
    IconData? prefixIcon,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      return DropdownMenu<T>(
        initialSelection: value,
        width: constraints.maxWidth,
        label: Text(label),
        leadingIcon: prefixIcon != null ? Icon(prefixIcon, size: 24.sp) : null,
        dropdownMenuEntries: items.map((T item) {
          return DropdownMenuEntry<T>(
            value: item,
            label: itemAsString(item),
          );
        }).toList(),
        onSelected: onChanged,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
      );
    });
  }

  Widget _buildMultiSelectChipGroup<T>({
    required String label,
    required List<T> allOptions,
    required List<T> selectedOptions,
    required String Function(T) optionAsString,
    required ValueChanged<List<T>> onSelectionChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: allOptions.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(optionAsString(option)),
              selected: isSelected,
              onSelected: (bool selected) {
                List<T> newSelectedList = List.from(selectedOptions);
                if (selected) {
                  // If "None" is selected, clear others. If other is selected, clear "None".
                  if (option.toString().toLowerCase().contains('none')) {
                    newSelectedList = [option];
                  } else {
                    newSelectedList.removeWhere((item) =>
                        item.toString().toLowerCase().contains('none'));
                    newSelectedList.add(option);
                  }
                } else {
                  newSelectedList.remove(option);
                  if (newSelectedList.isEmpty) {
                    // Start looking for the 'none' option cleanly
                    try {
                      final noneOption = allOptions.firstWhere((item) =>
                          item.toString().toLowerCase().contains('none'));
                      newSelectedList.add(noneOption);
                    } catch (_) {}
                  }
                }
                onSelectionChanged(newSelectedList);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
