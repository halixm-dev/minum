// lib/src/presentation/screens/home/add_water_log_screen.dart
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
import 'package:minum/src/presentation/widgets/common/custom_button.dart';
import 'package:minum/src/presentation/widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger

class AddWaterLogScreen extends StatefulWidget {
  final HydrationEntry? entryToEdit; // Optional entry for editing

  const AddWaterLogScreen({super.key, this.entryToEdit});

  @override
  State<AddWaterLogScreen> createState() => _AddWaterLogScreenState();
}

class _AddWaterLogScreenState extends State<AddWaterLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  MeasurementUnit _currentUnit = MeasurementUnit.ml;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.entryToEdit != null;
    final userProfile = Provider.of<UserProvider>(context, listen: false).userProfile;

    if (userProfile != null) {
      _currentUnit = userProfile.preferredUnit;
    }

    if (_isEditMode) {
      final entry = widget.entryToEdit!;
      double displayAmount = entry.amountMl;
      if (_currentUnit == MeasurementUnit.oz) {
        displayAmount = AppUtils.convertToPreferredUnit(entry.amountMl, MeasurementUnit.oz);
      }
      _amountController.text = AppUtils.formatAmount(displayAmount, decimalDigits: _currentUnit == MeasurementUnit.oz ? 1 : 0);
      _notesController.text = entry.notes ?? '';
      _selectedDateTime = entry.timestamp;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    if (!mounted) return;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        if (!mounted) return;
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveOrUpdateLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hydrationProvider = Provider.of<HydrationProvider>(context, listen: false);

    double amountMl;
    final double enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (_currentUnit == MeasurementUnit.oz) {
      amountMl = enteredAmount * 29.5735;
    } else {
      amountMl = enteredAmount;
    }

    if (amountMl <= 0) {
      if (mounted) {
        AppUtils.showSnackBar(context, "Please enter a valid amount.", isError: true);
      }
      return;
    }

    if (mounted) {
      AppUtils.showLoadingDialog(context, message: _isEditMode ? "Updating log..." : "Logging water...");
    }

    try {
      if (_isEditMode) {
        final updatedEntry = widget.entryToEdit!.copyWith(
            amountMl: amountMl,
            timestamp: _selectedDateTime,
            notes: _notesController.text.trim(),
            source: widget.entryToEdit!.source?.contains("manual") ?? true ? (widget.entryToEdit!.source ?? "manual_edit") : "manual_edit"
        );
        await hydrationProvider.updateHydrationEntry(updatedEntry);
      } else {
        await hydrationProvider.addHydrationEntry(
          amountMl,
          entryTime: _selectedDateTime,
          notes: _notesController.text.trim(),
          source: 'manual_add',
        );
      }

      if (!mounted) return;
      AppUtils.hideLoadingDialog(context);
      if (!mounted) return;
      Navigator.of(context).pop();

    } catch (e) {
      logger.e("Error saving/updating water log: $e");
      if (!mounted) return;
      AppUtils.hideLoadingDialog(context);
    }
  }

  String get _unitString => _currentUnit == MeasurementUnit.ml ? 'mL' : 'oz';

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);
    final userProfile = Provider.of<UserProvider>(context, listen: false).userProfile;

    if (userProfile != null && _currentUnit != userProfile.preferredUnit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) {
          setState(() {
            _currentUnit = userProfile.preferredUnit;
          });
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (hydrationProvider.actionStatus == HydrationActionStatus.success || hydrationProvider.actionStatus == HydrationActionStatus.error)) {
        if (hydrationProvider.actionStatus == HydrationActionStatus.success && ModalRoute.of(context)?.isCurrent == true) {
        } else if (hydrationProvider.actionStatus == HydrationActionStatus.error && hydrationProvider.errorMessage != null) {
          AppUtils.showSnackBar(context, hydrationProvider.errorMessage!, isError: true);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Edit Water Log" : AppStrings.logWaterTitle),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "Delete Log",
              onPressed: () async {
                if (!mounted) return;
                final bool? confirmed = await AppUtils.showConfirmationDialog(
                  context,
                  title: "Delete Log",
                  content: "Are you sure you want to delete this log entry?",
                  confirmText: "Delete",
                );
                if (confirmed == true && widget.entryToEdit != null) {
                  if (!mounted) return;
                  AppUtils.showLoadingDialog(context, message: "Deleting log...");
                  try {
                    await hydrationProvider.deleteHydrationEntry(widget.entryToEdit!);
                    if (!mounted) return;
                    AppUtils.hideLoadingDialog(context);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  } catch (e) {
                    logger.e("Error deleting log from AddWaterLogScreen: $e");
                    if (!mounted) return; // Added check for catch block
                    AppUtils.hideLoadingDialog(context);
                  }
                }
              },
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
              Text('Amount ($_unitString)', style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _amountController,
                labelText: AppStrings.enterAmount,
                hintText: 'e.g., 250 or 8',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.local_drink_outlined,
                validator: (value) => AppUtils.validateNumber(value, allowDecimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              SizedBox(height: 20.h),

              Text('Date & Time', style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () => _selectDateTime(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.grey),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEE, MMM d, hh:mm a').format(_selectedDateTime),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15.sp),
                      ),
                      Icon(Icons.calendar_today_outlined, size: 20.sp, color: Theme.of(context).hintColor),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              Text('Notes (Optional)', style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _notesController,
                labelText: 'Add a note',
                hintText: 'e.g., After workout',
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 32.h),

              CustomButton(
                text: _isEditMode ? "Update Log" : AppStrings.logWaterTitle,
                isLoading: hydrationProvider.actionStatus == HydrationActionStatus.processing,
                onPressed: _saveOrUpdateLog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}