// lib/src/features/hydration/presentation/pages/home/add_water_log_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/features/hydration/data/models/hydration_entry_model.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_bloc.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_event.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_state.dart';
import 'package:minum/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_state.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger

/// A screen for adding a new hydration entry or editing an existing one.
class AddWaterLogScreen extends StatefulWidget {
  /// An optional entry to edit. If this is provided, the screen will be in
  /// edit mode.
  final HydrationEntry? entryToEdit;

  /// Creates an `AddWaterLogScreen`.
  const AddWaterLogScreen({super.key, this.entryToEdit});

  @override
  State<AddWaterLogScreen> createState() => _AddWaterLogScreenState();
}

class _AddWaterLogScreenState extends State<AddWaterLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late TextEditingController _dateTimeController;

  DateTime _selectedDateTime = DateTime.now();
  MeasurementUnit _currentUnit = MeasurementUnit.ml;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _dateTimeController = TextEditingController();
    _isEditMode = widget.entryToEdit != null;
  }

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final userState = context.read<UserBloc>().state;
      final userProfile = userState is UserLoaded ? userState.user : null;

      if (userProfile != null) {
        _currentUnit = userProfile.preferredUnit;
      }

      if (_isEditMode) {
        final entry = widget.entryToEdit!;
        double displayAmount = entry.amountMl;
        if (_currentUnit == MeasurementUnit.oz) {
          displayAmount = AppUtils.convertToPreferredUnit(
              entry.amountMl, MeasurementUnit.oz);
        }
        _amountController.text = AppUtils.formatAmount(displayAmount,
            decimalDigits: _currentUnit == MeasurementUnit.oz ? 1 : 0);
        _notesController.text = entry.notes ?? '';
        _selectedDateTime = entry.timestamp;
      }
      _dateTimeController.text =
          "${DateFormat('EEE, MMM d').format(_selectedDateTime)}, ${TimeOfDay.fromDateTime(_selectedDateTime).format(context)}";
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  /// Shows date and time pickers to select the timestamp for the entry.
  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate == null) {
      return;
    }

    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _dateTimeController.text =
          "${DateFormat('EEE, MMM d').format(_selectedDateTime)}, ${TimeOfDay.fromDateTime(_selectedDateTime).format(context)}";
    });
  }

  /// Saves a new entry or updates an existing one.
  Future<void> _saveOrUpdateLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hydrationBloc = context.read<HydrationBloc>();

    double amountMl;
    final double enteredAmount =
        double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (_currentUnit == MeasurementUnit.oz) {
      amountMl = enteredAmount * 29.5735;
    } else {
      amountMl = enteredAmount;
    }

    if (amountMl <= 0) {
      if (mounted) {
        AppUtils.showSnackBar(context, "Please enter a valid amount.",
            isError: true);
      }
      return;
    }

    if (mounted) {
      AppUtils.showLoadingDialog(context,
          message: _isEditMode ? "Updating log..." : "Logging water...");
    }

    try {
      if (_isEditMode) {
        final updatedEntry = widget.entryToEdit!.copyWith(
            amountMl: amountMl,
            timestamp: _selectedDateTime,
            notes: _notesController.text.trim(),
            source: widget.entryToEdit!.source?.contains("manual") ?? true
                ? (widget.entryToEdit!.source ?? "manual_edit")
                : "manual_edit");
        hydrationBloc.add(UpdateHydrationEntryEvent(updatedEntry));
      } else {
        hydrationBloc.add(AddHydrationEntryEvent(
          amountMl: amountMl,
          entryTime: _selectedDateTime,
          notes: _notesController.text.trim(),
          source: 'manual_add',
        ));
      }
    } catch (e) {
      logger.e("Error triggering save/update water log: $e");
      if (!mounted) return;
      AppUtils.hideLoadingDialog(context);
    }
  }

  String get _unitString => _currentUnit == MeasurementUnit.ml ? 'mL' : 'oz';

  Future<void> _deleteLog() async {
    final hydrationBloc = context.read<HydrationBloc>();

    final confirmed = await AppUtils.showConfirmationDialog(
      context,
      title: "Delete Log",
      content: "Are you sure you want to delete this log entry?",
      confirmText: "Delete",
    );

    if (confirmed != true || widget.entryToEdit == null) {
      return;
    }

    if (!mounted) return;

    AppUtils.showLoadingDialog(context, message: "Deleting log...");

    try {
      hydrationBloc.add(DeleteHydrationEntryEvent(widget.entryToEdit!));
    } catch (e) {
      logger.e("Error triggering delete log from AddWaterLogScreen: $e");
      if (mounted) {
        AppUtils.hideLoadingDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hydrationState = context.watch<HydrationBloc>().state;
    final userState = context.watch<UserBloc>().state;
    final userProfile = userState is UserLoaded ? userState.user : null;

    if (userProfile != null && _currentUnit != userProfile.preferredUnit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentUnit = userProfile.preferredUnit;
          });
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          (hydrationState.actionStatus == HydrationActionStatus.success ||
              hydrationState.actionStatus == HydrationActionStatus.error)) {
        AppUtils.hideLoadingDialog(context);

        if (hydrationState.actionStatus == HydrationActionStatus.error &&
            hydrationState.errorMessage != null) {
          AppUtils.showSnackBar(context, hydrationState.errorMessage!,
              isError: true);
        } else if (hydrationState.actionStatus ==
            HydrationActionStatus.success) {
          Navigator.of(context).pop();
        }
        context.read<HydrationBloc>().add(ResetActionStatus());
      }
    });

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Edit Water Log" : AppStrings.logWaterTitle),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: Icon(Symbols.delete, color: theme.colorScheme.error),
              tooltip: "Delete Log",
              onPressed: _deleteLog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Amount ($_unitString)',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: AppStrings.enterAmount,
                  hintText: 'e.g., 250 or 8',
                  prefixIcon: Icon(Symbols.water_full_rounded),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    AppUtils.validateNumber(value, allowDecimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _dateTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date & Time', // Label integrated here
                  prefixIcon: Icon(Symbols.edit_calendar),
                ),
                onTap: _selectDateTime,
              ),
              SizedBox(height: 20.h),
              Text('Notes (Optional)',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Add a note',
                  hintText: 'e.g., After workout',
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _saveOrUpdateLog(),
              ),
              SizedBox(height: 32.h),
              FilledButton(
                onPressed: hydrationState.actionStatus ==
                        HydrationActionStatus.processing
                    ? null
                    : _saveOrUpdateLog,
                child: hydrationState.actionStatus ==
                        HydrationActionStatus.processing
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.onPrimary))
                    : Text(
                        _isEditMode ? "Update Log" : AppStrings.logWaterTitle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
