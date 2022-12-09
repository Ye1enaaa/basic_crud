import 'dart:convert' as convert;
import 'package:assignment/add_todo_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoad = true;
  List items = <dynamic>[];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.browse_gallery))
        ]),
      ),
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.question_answer))
        ],
        centerTitle: true,
        title: const Text('Electronic Log Book'),
      ),
      body: Visibility(
        visible: isLoad,
        replacement: RefreshIndicator(
          onRefresh: getData,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                var ind = index + 1;
                var nameValue = item['title'];
                var timeValue = item['description'];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    color: Colors.red,
                  ),
                  secondaryBackground: Container(
                    color: Colors.green,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text('${item['title'][0].toUpperCase()}',
                      style:  const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                      ),
                    ),
                    trailing: Text('$ind'),
                    title: Text('Name: $nameValue'),
                    subtitle: Text('Time in: $timeValue'),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      setState(() {
                        deleteData(id);
                        items.removeAt(index);
                      });
                    } else if (direction == DismissDirection.endToStart) {
                      setState(() {
                        editPage(item);
                      });
                    }
                  },
                );
              }),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddTodoPage()));
            setState(() {
              isLoad = true;
            });
            getData();
          },
          child: const Icon(Icons.add)),
    );
  }

  //Functions
  Future<void> getData() async {
    final uri = Uri.parse('https://api.nstack.in/v1/todos?page=1&limit=10');
    final response = await http.get(uri);
    setState(() {
      isLoad = false;
    });
    if (response.statusCode == 200) {
      final decode = convert.jsonDecode(response.body) as Map;
      final result = decode['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoad = false;
    });
  }

  Future<void> editPage(Map item) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddTodoPage(edit: item)));
  }

//DELETE Method
  Future<void> deleteData(String id) async {
    final uri = Uri.parse('https://api.nstack.in/v1/todos/$id');
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      showSuccessDelete();
    }
  }

  void showSuccessDelete() {
    var snackBar = const SnackBar(content: Text('Successfully Deleted'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }
}
