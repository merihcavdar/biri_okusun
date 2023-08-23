import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class DropList extends StatefulWidget {
  const DropList(
      {super.key,
      required this.titleText,
      required this.hintText,
      required this.items,
      required this.selectedItem});
  final String titleText;
  final String hintText;
  final List<String> items;
  final String selectedItem;

  @override
  State<DropList> createState() => _DropListState();
}

class _DropListState extends State<DropList> {
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.titleText,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text(
              widget.hintText,
              style: TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).hintColor,
              ),
            ),
            items: widget.items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ))
                .toList(),
            value: selectedValue,
            onChanged: (String? value) {
              setState(() {
                selectedValue = value!;
              });
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 60,
              width: 250,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
          ),
        ),
      ],
    );
  }
}
