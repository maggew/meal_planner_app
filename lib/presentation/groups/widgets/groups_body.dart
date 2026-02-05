import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/group.dart';
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
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black87, width: 1.5),
                ),
                child: (isLoading)
                    ? Center(child: CircularProgressIndicator())
                    : GroupsListviewWidget(
                        groups: groups!,
                        onLoadingChanged: (loading) {
                          setState(() => _joiningGroupIsLoading = loading);
                        }),
              ),
              if (_joiningGroupIsLoading) ...[
                Positioned.fill(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
