import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/presentation/create_group/widgets/create_group_create_button.dart';
import 'package:meal_planner/presentation/create_group/widgets/create_group_input_textfield.dart';
import 'package:meal_planner/presentation/create_group/widgets/create_group_pick_image.dart';

class CreateGroupBody extends StatelessWidget {
  final TextEditingController groupNameController;
  final TextEditingController imagePathController;
  final ValueChanged<bool> onLoadingChanged;
  const CreateGroupBody({
    super.key,
    required this.groupNameController,
    required this.imagePathController,
    required this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gap(50),
                CreateGroupInputTextfield(
                    groupNameController: groupNameController),
                Gap(20),
                Text(
                  "Bild:",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  "(optional)",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Gap(20),
                CreateGroupPickImage(imagePathController: imagePathController),
                SizedBox(height: 30),
                CreateGroupCreateButton(
                  groupNameController: groupNameController,
                  imagePathController: imagePathController,
                  onLoadingChanged: onLoadingChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
