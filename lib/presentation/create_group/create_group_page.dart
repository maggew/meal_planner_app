import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/create_group/widgets/create_group_body.dart';

@RoutePage()
class CreateGroupPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  late TextEditingController groupNameController;
  late TextEditingController imagePathController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    groupNameController = TextEditingController();
    imagePathController = TextEditingController();
  }

  @override
  void dispose() {
    groupNameController.dispose();
    imagePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        AppBackground(
          scaffoldAppBar: AppBar(
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                context.router.pop();
              },
              icon: Icon(Icons.chevron_left),
            ),
            leadingWidth: 85,
            title: Text("Gruppe erstellen", style: textTheme.displaySmall),
            centerTitle: true,
          ),
          scaffoldBody: CreateGroupBody(
            groupNameController: groupNameController,
            imagePathController: imagePathController,
            onLoadingChanged: (loading) {
              setState(() => _isLoading = loading);
            },
          ),
        ),
        if (_isLoading) ...[
          Container(
            color: Colors.black26,
            child: Center(child: CircularProgressIndicator()),
          )
        ]
      ],
    );
  }
}
