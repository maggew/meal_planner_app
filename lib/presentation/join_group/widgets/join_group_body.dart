import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class JoinGroupBody extends ConsumerWidget {
  final TextEditingController groupIdController;
  const JoinGroupBody({
    super.key,
    required this.groupIdController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Gruppen-ID eingeben:",
            style: textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 100,
            width: 270,
            child: TextFormField(
              controller: groupIdController,
              autovalidateMode: AutovalidateMode.disabled,
              //validator: _validateGroupID,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueGrey,
                    width: 1.5,
                  ),
                ),
                hintText: "Gruppen-ID",
                labelText: "Gruppen-ID",
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(150, 40),
            ),
            child: Text("beitreten"),
            onPressed: () async {
              final groupId = groupIdController.text.trim();
              if (groupId.isEmpty) return;

              try {
                await ref.read(sessionProvider.notifier).joinGroup(groupId);
                context.router.replace(const CookbookRoute());
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gruppe nicht gefunden')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
