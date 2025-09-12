// lib/src/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger
import 'package:minum/src/core/utils/unit_converter.dart' as unit_converter;
import 'package:minum/src/data/repositories/local/local_hydration_repository.dart'
    show guestUserId;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController; // Added for email field
  late TextEditingController _dailyGoalController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _dateOfBirthController; // Added for date picker

  // FocusNodes for CustomTextFields
  late FocusNode _displayNameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _heightFocusNode;
  late FocusNode _weightFocusNode;
  late FocusNode _dailyGoalFocusNode;

  DateTime? _selectedDateOfBirth;
  Gender? _selectedGender;
  ActivityLevel? _selectedActivityLevel;
  List<HealthCondition> _selectedHealthConditions = [HealthCondition.none];
  WeatherCondition _selectedWeatherCondition = WeatherCondition.temperate;

  bool _isLoading = false;
  bool _isDirty = false;
  UserModel? _lastProcessedUserProfile; // New state variable

  // Helper function for user-friendly enum display
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
    _emailController = TextEditingController(); // Initialize email controller
    _dailyGoalController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _dateOfBirthController =
        TextEditingController(); // Initialize date controller

    // Initialize FocusNodes
    _displayNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _heightFocusNode = FocusNode();
    _weightFocusNode = FocusNode();
    _dailyGoalFocusNode = FocusNode();

    _setupControllerListeners(); // Moved here
  }

  void _loadInitialProfileData() {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? userProfile =
        userProvider.userProfile; // Get the current profile from provider

    // Populate controllers and state variables from userProfile
    if (userProfile != null) {
      _displayNameController.text = userProfile.displayName ?? '';
      _emailController.text = userProfile.email ?? 'Not available';

      if (userProfile.preferredUnit == MeasurementUnit.oz) {
        _dailyGoalController.text = unit_converter
            .convertMlToOz(userProfile.dailyGoalMl)
            .toStringAsFixed(1);
      } else {
        _dailyGoalController.text = userProfile.dailyGoalMl.toInt().toString();
      }
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
      // Set default template data if no profile
      _displayNameController.text = '';
      _emailController.text = 'Not available';
      _dailyGoalController.text = '2000'; // Assuming default unit is mL
      _weightController.text = '';
      _heightController.text = '';
      _selectedActivityLevel = null;
      _selectedDateOfBirth = null;
      _dateOfBirthController.text = '';
      _selectedGender = null;
      _selectedHealthConditions = [HealthCondition.none];
      _selectedWeatherCondition = WeatherCondition.temperate;
    }

    _lastProcessedUserProfile =
        userProfile; // Store the user profile instance that was just used to set the data
    _isDirty = false;
  }

  void _setupControllerListeners() {
    _displayNameController.addListener(_setIsDirty);
    _dailyGoalController.addListener(_setIsDirty);
    _weightController.addListener(_setIsDirty);
    _heightController.addListener(_setIsDirty);
    // Email controller is read-only, no need for a listener to _setIsDirty
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
    _emailController.dispose(); // Dispose email controller
    _dailyGoalController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _dateOfBirthController.dispose(); // Dispose date controller

    // Dispose FocusNodes
    _displayNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    _dailyGoalFocusNode.dispose();

    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateOfBirth ??
            DateTime.now().subtract(const Duration(days: 365 * 25)),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        helpText: "Select Date of Birth");
    // Removed custom builder to allow default M3 styling
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

  Future<void> _calculateAndSuggestGoal() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final hydrationService =
        Provider.of<HydrationService>(context, listen: false);

    List<HealthCondition> conditionsForCalc = _selectedHealthConditions;
    if (_selectedHealthConditions.contains(HealthCondition.none) &&
        _selectedHealthConditions.length > 1) {
      conditionsForCalc = _selectedHealthConditions
          .where((c) => c != HealthCondition.none)
          .toList();
    }
    if (conditionsForCalc.isEmpty) conditionsForCalc = [HealthCondition.none];

    final tempUserForCalc = UserModel(
      id: userProvider.userProfile?.id ?? guestUserId,
      createdAt: userProvider.userProfile?.createdAt ?? DateTime.now(),
      displayName: _displayNameController.text.trim(),
      weightKg: double.tryParse(_weightController.text.trim()),
      heightCm: double.tryParse(_heightController.text.trim()),
      dateOfBirth: _selectedDateOfBirth,
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
      healthConditions: conditionsForCalc,
      selectedWeatherCondition: _selectedWeatherCondition,
      preferredUnit:
          userProvider.userProfile?.preferredUnit ?? MeasurementUnit.ml,
      dailyGoalMl: double.tryParse(_dailyGoalController.text.trim()) ?? 2000.0,
      favoriteIntakeVolumes: userProvider.userProfile?.favoriteIntakeVolumes ??
          const ['250', '500', '750'],
    );

    if (tempUserForCalc.weightKg == null ||
        tempUserForCalc.weightKg! <= 0 ||
        tempUserForCalc.age == null ||
        tempUserForCalc.gender == null ||
        tempUserForCalc.activityLevel == null) {
      if (mounted) {
        AppUtils.showSnackBar(context,
            "Please fill in Weight, Date of Birth, Gender, and Activity Level to calculate a suggestion.",
            isError: true);
      }
      return;
    }

    final mainScreenContext = context;
    AppUtils.showLoadingDialog(mainScreenContext, message: "Calculating...");

    double suggestedGoal = 0;
    bool calculationSuccess = false;
    try {
      suggestedGoal = await hydrationService.calculateRecommendedDailyIntake(
          user: tempUserForCalc);
      calculationSuccess = true;
    } catch (e) {
      logger.e("Error calculating suggested goal: $e");
    }

    if (!mainScreenContext.mounted) return;
    AppUtils.hideLoadingDialog(mainScreenContext);

    if (!calculationSuccess) {
      if (mainScreenContext.mounted) {
        AppUtils.showSnackBar(mainScreenContext,
            "Could not calculate suggested goal. Please try again.",
            isError: true);
      }
      return;
    }

    final confirmationDialogContext = mainScreenContext;
    final bool? apply = await AppUtils.showConfirmationDialog(
        confirmationDialogContext,
        title: "Suggested Goal",
        content:
            "Based on your profile, we suggest a daily goal of ${suggestedGoal.toInt()} mL. Would you like to apply this to your daily goal field?",
        confirmText: "Apply to Field",
        cancelText: "Not Now");

    if (apply == true) {
      // Ensure context captured before await is still valid
      if (!confirmationDialogContext.mounted) {
        return; // Added check for captured context
      }
      if (mounted) {
        // Check for the State's mounted status
        setState(() {
          _dailyGoalController.text = suggestedGoal.toInt().toString();
          _isDirty = true;
        });
        // confirmationDialogContext is used here, its mounted status was checked above.
        AppUtils.showSnackBar(confirmationDialogContext,
            "Suggested goal applied to form. Remember to save your profile.");
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
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
    // final double newDailyGoal = double.tryParse(_dailyGoalController.text.trim()) ?? currentUser.dailyGoalMl;
    double newDailyGoal;
    final String goalText = _dailyGoalController.text.trim();
    double? enteredGoal = double.tryParse(goalText);

    if (enteredGoal != null) {
      if (currentUser.preferredUnit == MeasurementUnit.oz) {
        newDailyGoal = unit_converter.convertOzToMl(enteredGoal);
      } else {
        newDailyGoal = enteredGoal;
      }
    } else {
      newDailyGoal =
          currentUser.dailyGoalMl; // Fallback to current if input is invalid
    }
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

    UserModel updatedUser = currentUser.copyWith(
        displayName: newDisplayName,
        dailyGoalMl: newDailyGoal,
        preferredUnit: currentUser.preferredUnit,
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

    try {
      await userProvider.updateUserProfile(updatedUser);
      // ... (inside the try block, after await userProvider.updateUserProfile(updatedUser);)
      if (mounted) {
        String messageToShow =
            "Profile updated successfully!"; // Default success message
        bool isPresentationError =
            false; // Determines if the snackbar should be styled as an error

        // Check provider status and potential message
        if (userProvider.status == UserProfileStatus.loaded) {
          if (userProvider.errorMessage != null &&
              userProvider.errorMessage ==
                  "Profile saved locally. Will sync when online.") {
            messageToShow = userProvider.errorMessage!;
            // For this specific informational message, it's not an error presentation.
            isPresentationError = false;
          } else if (userProvider.errorMessage != null) {
            // If status is loaded but there's an unexpected error message from the provider.
            messageToShow = userProvider.errorMessage!;
            isPresentationError = true;
          }
          // If errorMessage is null, messageToShow remains "Profile updated successfully!"
        } else if (userProvider.status == UserProfileStatus.error) {
          // This case handles if updateUserProfile resolves but ended in an error state internally.
          messageToShow =
              userProvider.errorMessage ?? "Failed to update profile.";
          isPresentationError = true;
        }
        // Default case: if status is neither loaded nor error (e.g. idle), it might imply an issue.
        // However, updateUserProfile should ideally always transition to loaded or error.
        // For simplicity, we'll rely on the above conditions.

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
    // final userProvider = Provider.of<UserProvider>(context); // Will be obtained from Consumer
    // final UserModel? user = userProvider.userProfile; // Will be obtained from Consumer

    // Removed initial null checks as Consumer will handle loading/error states.

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
          // Handles error or unexpected null user after loading attempt
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.profile)),
            body: Center(
                child: Text(
                    userProvider.errorMessage ?? "User data unavailable.")),
          );
        }

        // Conditional call to _loadInitialProfileData based on object instance change
        if (userProvider.status == UserProfileStatus.loaded &&
            user != _lastProcessedUserProfile) {
          // This condition is true if:
          // 1. Initially _lastProcessedUserProfile is null and user is not (first load).
          // 2. User logs out (user becomes null, _lastProcessedUserProfile was not).
          // 3. User logs in (user is new user, _lastProcessedUserProfile was null or guest).
          // 4. User data is updated in UserProvider, resulting in a new UserModel instance.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadInitialProfileData(); // This will set controllers and also update _lastProcessedUserProfile
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary)) // Use primary for TextButton loader
                        : Text("SAVE",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.fontWeight)), // M3 TextButton uses labelLarge
                  ),
                )
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildPersonalInformationSection(
                      context, user, userProvider, Theme.of(context)),
                  SizedBox(height: 24.h), // Maintain spacing between sections
                  _buildLifestyleEnvironmentSection(
                      context, user, userProvider, Theme.of(context)),
                  SizedBox(height: 24.h), // Maintain spacing between sections
                  _buildHydrationGoalSection(
                      context, user, userProvider, Theme.of(context)),
                  SizedBox(height: 40.h), // Maintain bottom spacing
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalInformationSection(BuildContext context, UserModel user,
      UserProvider userProvider, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information'),
        TextFormField(
          controller: _displayNameController,
          focusNode: _displayNameFocusNode,
          decoration: InputDecoration(
            labelText: 'Display Name',
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
          decoration: InputDecoration(
            labelText: AppStrings.email,
            prefixIcon: Icon(Symbols.email),
          ),
          readOnly: true,
          enabled: false,
        ), // Email is not editable
        SizedBox(height: 16.h),
        _buildDatePickerField(context, "Date of Birth", _selectedDateOfBirth,
            (date) {
          if (mounted) {
            setState(() {
              _selectedDateOfBirth = date;
              _isDirty = true;
            });
          }
        }),
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
        TextFormField(
          controller: _heightController,
          focusNode: _heightFocusNode,
          decoration: InputDecoration(
            labelText: 'Height (cm)',
            prefixIcon: Icon(Symbols.height),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
          ],
          validator: (val) => (val == null || val.isEmpty)
              ? null
              : AppUtils.validateNumber(val, allowDecimal: true),
          onChanged: (_) => _setIsDirty(),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _weightController,
          focusNode: _weightFocusNode,
          decoration: InputDecoration(
            labelText: '${AppStrings.weight} (${AppStrings.kg})',
            prefixIcon: Icon(Symbols.monitor_weight),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) => (value == null || value.isEmpty)
              ? null
              : AppUtils.validateNumber(value, allowDecimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
          ],
          onChanged: (_) => _setIsDirty(),
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildLifestyleEnvironmentSection(BuildContext context, UserModel user,
      UserProvider userProvider, ThemeData theme) {
    List<HealthCondition> availableHealthConditions =
        List.from(HealthCondition.values);
    if (_selectedGender != Gender.female) {
      availableHealthConditions.removeWhere((c) =>
          c == HealthCondition.pregnancy || c == HealthCondition.breastfeeding);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Lifestyle & Environment'),
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
    );
  }

  Widget _buildHydrationGoalSection(BuildContext context, UserModel user,
      UserProvider userProvider, ThemeData theme) {
    bool isOz = user.preferredUnit == MeasurementUnit.oz;
    TextInputType goalKeyboardType = isOz
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.number;
    List<TextInputFormatter> goalInputFormatters = isOz
        ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
        : [FilteringTextInputFormatter.digitsOnly];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hydration Goal'),
        TextFormField(
          controller: _dailyGoalController,
          focusNode: _dailyGoalFocusNode,
          decoration: InputDecoration(
            labelText: 'Daily Goal (${user.preferredUnit.displayName})',
            prefixIcon: const Icon(Symbols.flag),
          ),
          keyboardType: goalKeyboardType,
          inputFormatters: goalInputFormatters,
          validator: (val) => AppUtils.validateNumber(val, allowDecimal: isOz),
          onChanged: (_) => _setIsDirty(),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _saveProfile(),
        ),
        SizedBox(height: 12.h),
        FilledButton.tonal(
          onPressed: _calculateAndSuggestGoal,
          child: const Text("Calculate Suggested Goal"),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h), // Standardized padding
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.secondary, // Changed to secondary color
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label,
      DateTime? selectedDate, Function(DateTime) onDateSelected) {
    // final theme = Theme.of(context); // Not strictly needed if relying on InputDecorationTheme
    // final inputTheme = theme.inputDecorationTheme; // Not strictly needed

    return TextFormField(
      controller: _dateOfBirthController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Symbols.calendar_today),
        // The rest of the styling (border, fillColor, filled, contentPadding)
        // should come from the app's InputDecorationTheme.
      ),
      onTap: () => _selectDateOfBirth(context),
      // The validator is removed as the field is read-only and date is picked.
      // If validation is needed (e.g. required field), it can be added here.
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
    final theme = Theme.of(context); // Keep theme for icon color if needed
    return DropdownMenu<T>(
      initialSelection: value,
      label: Text(label),
      leadingIcon: prefixIcon != null
          ? Icon(prefixIcon,
              size: 20.sp, color: theme.colorScheme.onSurfaceVariant)
          : null,
      dropdownMenuEntries: items.map((T item) {
        return DropdownMenuEntry<T>(
          value: item,
          label: itemAsString(item),
          // Style for menu items can be themed globally via DropdownMenuThemeData.
          // If specific styling is needed here, it can be applied to the label Text widget.
          // style: MenuItemButton.styleFrom( ... )
        );
      }).toList(),
      onSelected: onChanged,
      // DropdownMenu expands by default to fit its parent or the widest item.
      // To ensure it fills the width like DropdownButtonFormField with isExpanded:true:
      width: MediaQuery.of(context).size.width -
          (40.w), // Screen width minus padding
      // Alternatively, wrap in a SizedBox(width: double.infinity) if parent allows for it,
      // or rely on Expanded if in a Row.
      // The menuStyle can be used for extensive customization (e.g., background color)
      // but ideally, this is handled by the global DropdownMenuThemeData.
      // menuStyle: MenuStyle(
      //   backgroundColor: MaterialStateProperty.all(theme.colorScheme.surfaceContainerHighest),
      // ),
    );
  }

  Widget _buildMultiSelectChipGroup<T extends Enum>({
    required String label,
    required List<T> allOptions,
    required List<T> selectedOptions,
    required String Function(T item) optionAsString,
    required Function(List<T> selected) onSelectionChanged,
  }) {
    final theme = Theme.of(context);
    // final chipTheme = theme.chipTheme; // Unused local variable removed

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelLarge?.copyWith(
                color: theme
                    .colorScheme.onSurfaceVariant)), // Use onSurfaceVariant
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h, // Changed from 0.h to 8.h for M3 compliance
          children: allOptions.map((option) {
            final bool isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(
                  optionAsString(option)), // Style from chipTheme.labelStyle
              selected: isSelected,
              onSelected: (bool selected) {
                List<T> newSelection = List.from(selectedOptions);
                if (selected) {
                  if (option == HealthCondition.none) {
                    newSelection = [option];
                  } else {
                    newSelection
                        .removeWhere((item) => item == HealthCondition.none);
                    if (!newSelection.contains(option)) {
                      newSelection.add(option);
                    }
                  }
                } else {
                  if (option != HealthCondition.none) {
                    newSelection.remove(option);
                    if (newSelection.isEmpty) {
                      newSelection.add(HealthCondition.none as T);
                    }
                  }
                }
                onSelectionChanged(newSelection);
              },
              // Styling from chipTheme in AppTheme:
              // backgroundColor (unselected), selectedColor, checkmarkColor, labelStyle, shape, side
              // are expected to be defined in the global ChipThemeData for M3 compliance.
            );
          }).toList(),
        ),
      ],
    );
  }
}
