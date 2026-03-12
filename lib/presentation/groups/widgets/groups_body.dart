import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/groups/widgets/groups_listview_widget.dart';

class GroupsBody extends StatefulWidget {
  final bool isLoading;
  final List<Group>? groups;
  const GroupsBody({super.key, required this.isLoading, required this.groups});

  @override
  State<GroupsBody> createState() => _GroupsBodyState();
}

class _GroupsBodyState extends State<GroupsBody> {
  bool _joiningGroupIsLoading = false;

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.isLoading;
    final groups = widget.groups;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 200,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  width: 1.5),
            ),
            child: LoadingOverlay(
              isLoading: _joiningGroupIsLoading,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: (isLoading)
                    ? Center(child: CircularProgressIndicator())
                    : GroupsListviewWidget(
                        groups: groups!,
                        onLoadingChanged: (loading) {
                          setState(() => _joiningGroupIsLoading = loading);
                        }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
