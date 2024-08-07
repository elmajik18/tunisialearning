import 'package:flutter/material.dart';

class CustomDropdownSearch extends StatefulWidget {
  final List<String> items;
  final String hintText;
  final Function(String?) onChanged;

  CustomDropdownSearch({
    required this.items,
    required this.hintText,
    required this.onChanged,
  });

  @override
  _CustomDropdownSearchState createState() => _CustomDropdownSearchState();
}

class _CustomDropdownSearchState extends State<CustomDropdownSearch> {
  TextEditingController searchController = TextEditingController();
  List<String> filteredItems = [];
  String? selectedItem;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = widget.items.where((item) {
        return item.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8.0),
        DropdownButton<String>(
          hint: Text(widget.hintText),
          value: selectedItem,
          onChanged: (newValue) {
            setState(() {
              selectedItem = newValue;
              searchController.text = newValue ?? '';
            });
            widget.onChanged(newValue);
          },
          items: filteredItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          isExpanded: true,
        ),
      ],
    );
  }
}
