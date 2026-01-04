import 'package:flutter/material.dart';

class CookbookSearchbar extends StatelessWidget {
  final TextEditingController searchbarController;
  const CookbookSearchbar({
    super.key,
    required this.searchbarController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 40,
      child: Stack(
        children: [
          TextFormField(
            controller: searchbarController,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.bottom,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              hintText: "Suche",
              fillColor: Colors.white70,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
