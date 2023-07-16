import 'package:flutter/material.dart';

class CollapsibleList extends StatefulWidget {
  final List<Item> items;

  const CollapsibleList({super.key, required this.items});

  @override
  // ignore: library_private_types_in_public_api
  _CollapsibleListState createState() => _CollapsibleListState();
}

class _CollapsibleListState extends State<CollapsibleList> {
  List<Item> get items => widget.items;
  List<bool> expandedList = [];

  @override
  void initState() {
    super.initState();
    expandedList = List<bool>.filled(items.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: EdgeInsets.zero,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          expandedList[index] = !isExpanded;
        });
      },
      children: items.map<ExpansionPanel>((Item item) {
        final int index = items.indexOf(item);
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                item.headerValue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
          body: Column(
            children: [
              ListTile(
                title: buildImage(item.expandedValue),
              ),
              if (index == 0) ...[
                const SizedBox(height: 10),
                const Text(
                  'Kyle Anthony Nierras',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
          isExpanded: expandedList[index],
        );
      }).toList(),
    );
  }

  Widget buildImage(String imagePath) {
    return Image.asset(imagePath);
  }
}

class Item {
  final String headerValue;
  final String expandedValue;

  Item({required this.headerValue, required this.expandedValue});
}
