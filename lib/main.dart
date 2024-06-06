import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Check List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<_CheckListItem> _items = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsString = prefs.getString('checklist_items');
    if (itemsString != null) {
      final List<dynamic> itemsJson = jsonDecode(itemsString);
      setState(() {
        _items.clear();
        _items.addAll(itemsJson.map((item) => _CheckListItem.fromJson(item)).toList());
      });
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String itemsString = jsonEncode(_items);
    await prefs.setString('checklist_items', itemsString);
  }

  void _addItem() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _items.add(_CheckListItem(text: _controller.text, isChecked: false));
        _controller.clear();
        _saveItems();
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _saveItems();
    });
  }

  void _toggleCheck(int index) {
    setState(() {
      _items[index].isChecked = !_items[index].isChecked;
      _saveItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter a text',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Add to List'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _items[index].text,
                      style: TextStyle(
                        decoration: _items[index].isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    leading: Checkbox(
                      value: _items[index].isChecked,
                      onChanged: (bool? value) {
                        _toggleCheck(index);
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckListItem {
  _CheckListItem({required this.text, this.isChecked = false});

  String text;
  bool isChecked;

  Map<String, dynamic> toJson() => {
    'text': text,
    'isChecked': isChecked,
  };

  static _CheckListItem fromJson(Map<String, dynamic> json) => _CheckListItem(
    text: json['text'],
    isChecked: json['isChecked'],
  );
}
