import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final IconData? iconData;
  final void Function(String)? onChanged;
  final String? hintText;
  final Function? onTap;
  final bool? enabled;
  final Color? color;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  const Input({
    Key? key,
    this.iconData,
    this.onChanged,
    this.hintText,
    this.onTap,
    this.enabled = false,
    this.color,
    this.controller,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconData, size: 19, color: color),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width / 1.4,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.grey[200],
            ),
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              onTap: () {},
              enabled: enabled,
              onChanged: onChanged,
              decoration: InputDecoration.collapsed(
                  hintText: hintText,
                  hintStyle: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        )
      ],
    );
  }
}