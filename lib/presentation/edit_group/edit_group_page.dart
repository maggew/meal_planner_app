import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/edit_group/widgets/edit_group_body.dart';

@RoutePage()
class EditGroupPage extends ConsumerStatefulWidget {
  final Group group;
  const EditGroupPage({super.key, required this.group});

  @override
  ConsumerState<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends ConsumerState<EditGroupPage> {
  late TextEditingController groupNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    groupNameController = TextEditingController(text: widget.group.name);
  }

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppBackground(
      scaffoldAppBar: AppBar(
        title: Text("Gruppe bearbeiten", style: textTheme.displaySmall),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.router.pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        leadingWidth: 65,
      ),
      scaffoldBody: Stack(
        children: [
          EditGroupBody(
            group: widget.group,
            groupNameController: groupNameController,
            onLoadingChanged: (loading) {
              setState(() {
                _isLoading = loading;
              });
            },
          ),
          if (_isLoading) ...[
            Container(
              color: Colors.black38,
              width: double.infinity,
              height: double.infinity,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ],
      ),
    );
  }
}
