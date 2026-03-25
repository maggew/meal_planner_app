import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/placeholder_image.dart';
import 'package:meal_planner/presentation/edit_group/widgets/edit_group_image.dart';
import 'package:meal_planner/presentation/edit_group/widgets/edit_group_select_image_buttons.dart';
import 'package:meal_planner/presentation/edit_group/widgets/edit_groups_button.dart';

class EditGroupBody extends StatelessWidget {
  final Group group;
  final TextEditingController groupNameController;
  final ValueChanged<bool> onLoadingChanged;
  const EditGroupBody({
    super.key,
    required this.group,
    required this.groupNameController,
    required this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final hasValidImage = group.imageUrl.isNotEmpty;
    final Widget image = hasValidImage
        ? CachedNetworkImage(
            imageUrl: group.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Center(child: const CircularProgressIndicator()),
            errorWidget: (_, __, ___) => const PlaceholderImage(),
          )
        : const PlaceholderImage();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 20,
        children: [
          Text("Gruppenname", style: textTheme.headlineMedium),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: TextField(
              controller: groupNameController,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
          ),
          EditGroupImage(image: image),
          EditGroupSelectImageButtons(),
          EditGroupsButton(
            group: group,
            groupNameController: groupNameController,
            onLoadingChanged: onLoadingChanged,
          ),
        ],
      ),
    );
  }
}
