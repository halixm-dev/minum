// lib/src/presentation/screens/home/add_water_log_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart'; // For HydrationEntry
import 'package:minum/src/data/models/user_model.dart'; // For MeasurementUnit
import 'package:minum/src/presentation/providers/hydration_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger

class AddWaterLogScreen extends StatefulWidget {
  final HydrationEntry? entryToEdit; // Optional entry for editing

  const AddWaterLogScreen({super.key, this.entryToEdit});

  @override
  State<AddWaterLogScreen> createState() => _AddWaterLogScreenState();
}

class _AddWaterLogScreenState extends State<AddWaterLogScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late TextEditingController _dateTimeController;

  DateTime _selectedDateTime = DateTime.now();
  MeasurementUnit _currentUnit = MeasurementUnit.ml;
  bool _isEditMode = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _dateTimeController = TextEditingController();
    _isEditMode = widget.entryToEdit != null;
    final userProfile =
        Provider.of<UserProvider>(context, listen: false).userProfile;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    if (userProfile != null) {
      _currentUnit = userProfile.preferredUnit;
    }

    if (_isEditMode) {
      final entry = widget.entryToEdit!;
      double displayAmount = entry.amountMl;
      if (_currentUnit == MeasurementUnit.oz) {
        displayAmount =
            AppUtils.convertToPreferredUnit(entry.amountMl, MeasurementUnit.oz);
      }
      _amountController.text = AppUtils.formatAmount(displayAmount,
          decimalDigits: _currentUnit == MeasurementUnit.oz ? 1 : 0);
      _notesController.text = entry.notes ?? '';
      _selectedDateTime = entry.timestamp;
    }
    _dateTimeController.text =
        DateFormat('EEE, MMM d, hh:mm a').format(_selectedDateTime);

    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _dateTimeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateTimeController.text =
              DateFormat('EEE, MMM d, hh:mm a').format(_selectedDateTime);
        });
      }
    }
  }

  Future<void> _saveOrUpdateLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hydrationProvider =
        Provider.of<HydrationProvider>(context, listen: false);

    double amountMl;
    final double enteredAmount =
        double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (_currentUnit == MeasurementUnit.oz) {
      amountMl = enteredAmount * 29.5735;
    } else {
      amountMl = enteredAmount;
    }

    if (amountMl <= 0) {
      AppUtils.showSnackBar(context, "Please enter a valid amount.",
          isError: true);
      return;
    }

    AppUtils.showLoadingDialog(context,
        message: _isEditMode ? "Updating log..." : "Logging water...");

    try {
      if (_isEditMode) {
        final updatedEntry = widget.entryToEdit!.copyWith(
            amountMl: amountMl,
            timestamp: _selectedDateTime,
            notes: _notesController.text.trim(),
            source: widget.entryToEdit!.source?.contains("manual") ?? true
                ? (widget.entryToEdit!.source ?? "manual_edit")
                : "manual_edit");
        await hydrationProvider.updateHydrationEntry(updatedEntry);
      } else {
        await hydrationProvider.addHydrationEntry(
          amountMl,
          entryTime: _selectedDateTime,
          notes: _notesController.text.trim(),
          source: 'manual_add',
        );
      }
      AppUtils.hideLoadingDialog(context);
      Navigator.of(context).pop();
    } catch (e) {
      logger.e("Error saving/updating water log: $e");
      AppUtils.hideLoadingDialog(context);
    }
  }

  String get _unitString => _currentUnit == MeasurementUnit.ml ? 'mL' : 'oz';

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Edit Water Log" : AppStrings.logWaterTitle),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
              tooltip: "Delete Log",
              onPressed: () async {
                final bool? confirmed = await AppUtils.showConfirmationDialog(
                  context,
                  title: "Delete Log",
                  content: "Are you sure you want to delete this log entry?",
                  confirmText: "Delete",
                );
                if (confirmed == true && widget.entryToEdit != null) {
                  AppUtils.showLoadingDialog(context,
                      message: "Deleting log...");
                  try {
                    await hydrationProvider
                        .deleteHydrationEntry(widget.entryToEdit!);
                    AppUtils.hideLoadingDialog(context);
                    Navigator.of(context).pop();
                  } catch (e) {
                    logger.e("Error deleting log from AddWaterLogScreen: $e");
                    AppUtils.hideLoadingDialog(context);
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _AnimatedSlideFade(
                animation: _animationController,
                order: 1,
                child: Text('Amount ($_unitString)',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.primary)),
              ),
              SizedBox(height: 12.h),
              _AnimatedSlideFade(
                animation: _animationController,
                order: 2,
                child: TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.enterAmount,
                    hintText: 'e.g., 250 or 8',
                    prefixIcon: Icon(Icons.local_drink),
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
              ),
              SizedBox(height: 24.h),
              _AnimatedSlideFade(
                animation: _animationController,
                order: 3,
                child: TextFormField(
                  controller: _dateTimeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date & Time',
                    prefixIcon: Icon(Icons.edit_calendar),
                  ),
                  onTap: () => _selectDateTime(context),
                ),
              ),
              SizedBox(height: 24.h),
              _AnimatedSlideFade(
                animation: _animationController,
                order: 4,
                child: Text('Notes (Optional)',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.primary)),
              ),
              SizedBox(height: 12.h),
              _AnimatedSlideFade(
                animation: _animationController,
                order: 5,
                child: TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Add a note',
                    hintText: 'e.g., After workout',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveOrUpdateLog(),
                ),
              ),
              SizedBox(height: 40.h),
              _AnimatedSlideFade(
                animation: _animationController,
                order: 6,
                child: FilledButton(
                  onPressed: hydrationProvider.actionStatus ==
                          HydrationActionStatus.processing
                      ? null
                      : _saveOrUpdateLog,
                  child: hydrationProvider.actionStatus ==
                          HydrationActionStatus.processing
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: theme.colorScheme.onPrimary))
                      : Text(_isEditMode
                          ? "Update Log"
                          : AppStrings.logWaterTitle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSlideFade extends StatelessWidget {
  final Animation<double> animation;
  final int order;
  final Widget child;

  const _AnimatedSlideFade({
    required this.animation,
    required this.order,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Interval(0.1 * order, 0.5 + 0.1 * order,
            curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(0.1 * order, 0.5 + 0.1 * order,
              curve: Curves.easeOut),
        )),
        child: child,
      ),
    );
  }
}
