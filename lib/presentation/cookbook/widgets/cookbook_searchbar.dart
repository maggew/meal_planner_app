import 'package:flutter/material.dart';

class CookbookSearchbar extends StatelessWidget {
  const CookbookSearchbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      height: 40,
      child: Stack(
        children: [
          TextFormField(
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
