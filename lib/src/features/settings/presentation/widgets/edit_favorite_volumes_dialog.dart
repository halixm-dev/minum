import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_event.dart';

class EditFavoriteVolumesDialogContent extends StatefulWidget {
  final UserModel? currentUser;
  final UserBloc userBloc;

  const EditFavoriteVolumesDialogContent({
    super.key,
    required this.currentUser,
    required this.userBloc,
  });

  @override
  State<EditFavoriteVolumesDialogContent> createState() =>
      _EditFavoriteVolumesDialogContentState();
}

class _EditFavoriteVolumesDialogContentState
    extends State<EditFavoriteVolumesDialogContent> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final favorites = widget.currentUser?.favoriteIntakeVolumes ?? [];
    if (favorites.isNotEmpty) {
      _controllers =
          favorites.map((vol) => TextEditingController(text: vol)).toList();
    } else {
      // Default values if empty
      _controllers = [
        TextEditingController(text: '100'),
        TextEditingController(text: '250'),
        TextEditingController(text: '500'),
      ];
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addVolume() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeVolume(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: "Volume ${index + 1}",
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.delete),
                        tooltip: AppStrings.delete,
                        onPressed: () => _removeVolume(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: _addVolume,
            icon: const Icon(Symbols.add),
            label: const Text(AppStrings.add),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () async {
                  final List<String> newVolumes = _controllers
                      .map((c) => c.text)
                      .where((text) =>
                          text.isNotEmpty && double.tryParse(text) != null)
                      .toList();

                  if (newVolumes.isNotEmpty) {
                    if (widget.currentUser != null) {
                      final updatedUser = widget.currentUser!
                          .copyWith(favoriteIntakeVolumes: newVolumes);
                      widget.userBloc.add(UpdateUserProfile(updatedUser));
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  } else {
                    AppUtils.showSnackBar(
                        context, "Please add at least one volume.",
                        isError: true);
                  }
                },
                child: const Text(AppStrings.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
