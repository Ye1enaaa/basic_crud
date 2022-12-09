import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? edit;
  const AddTodoPage({super.key, this.edit});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage > {
  
  //Controllers
  TextEditingController nameVar = TextEditingController();
  TextEditingController timeVar = TextEditingController();
  var formKey = GlobalKey<FormState>();
  
  //Variable editpage, bool
  var boolEdit = false;

  @override
  void initState() {
    super.initState();
    final edit = widget.edit;
    if (edit != null) {
      boolEdit = true;
      final title = edit['title'];
      final description = edit['description'];
      nameVar.text = title;
      timeVar.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Text(boolEdit ? 'Edit Data' : 'Add Visitor'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: nameVar,
                decoration: const InputDecoration(
                    labelText: 'Name', hintText: 'Example: Erickson Dela Cruz'),
                validator: (value){
                  if(value!.isEmpty){
                    return 'Please enter your name';
                  }
                  else{
                    return null;
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: timeVar,
                keyboardType: TextInputType.text,   
                decoration: const InputDecoration(
                    labelText: 'Time In', hintText: 'Example: 9:30 pm'),
                 validator: (value){
                  if(value!.isEmpty){
                    return 'Please enter your name';
                  }
                  else{
                    return null;
                  }
                 }
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    if(formKey.currentState!.validate()){
                    boolEdit ? modifyData() : postData();
                    }
                  },
                  child: Text(boolEdit ? 'MODIFY' : 'SUBMIT')),
            )
          ],
        ),
      ),
    );
  }

  Future<void> modifyData() async {
    final edit = widget.edit;

    final id = edit!['_id'];

    final title = nameVar.text;
    final description = timeVar.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final uri = Uri.parse('https://api.nstack.in/v1/todos/$id');
    await http.put(uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'} //Require for get method
        );
    showSuccessEdit();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  //POST method
  void postData() async {
    final title = nameVar.text;
    final description = timeVar.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    //Call API
    final uri = Uri.parse('https://api.nstack.in/v1/todos');
    await http.post(uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'} //Require for get method
        );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    showSuccessPost();
  }

  //Functions for pop up snackbar
  void showSuccessEdit() {
    var snackBar = const SnackBar(
        content: Text('Modified Successfully, please reload the page!'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showSuccessPost() {
    var snackBar = const SnackBar(content: Text('Log Created'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
