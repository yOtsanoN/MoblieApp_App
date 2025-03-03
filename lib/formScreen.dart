import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moblieapp_app/model/moblieappitem.dart';
import 'package:moblieapp_app/model/cateitem.dart';
import 'package:moblieapp_app/provider/moblieappitemprovider.dart';
import 'package:moblieapp_app/provider/cateprovider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final scoreController = TextEditingController();
  Cateitem? selectedCategory;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มแอปพลิเคชัน'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        // Add SingleChildScrollView here
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'ชื่อแอป'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาป้อนชื่อแอป';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'คะแนนแอป'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาป้อนคะแนน';
                  }
                  if (int.tryParse(value) == null) {
                    return 'กรุณาป้อนเป็นตัวเลข';
                  }
                  int score = int.parse(value);
                  if (score < 0 || score > 5) {
                    return 'คะแนนต้องอยู่ในช่วง 0 ถึง 5';
                  }
                  return null;
                },
              ),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  List<Cateitem> categories = categoryProvider.categories;
                  return DropdownButtonFormField<Cateitem>(
                    value: selectedCategory,
                    decoration:
                        const InputDecoration(labelText: 'เลือกหมวดหมู่'),
                    onChanged: (Cateitem? newCategory) {
                      setState(() {
                        selectedCategory = newCategory;
                      });
                    },
                    items: categories.map((Cateitem category) {
                      return DropdownMenuItem<Cateitem>(
                        value: category,
                        child: Text(category.title),
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? 'กรุณาเลือกหมวดหมู่' : null,
                  );
                },
              ),
              Row(
                children: [
                  Text("วันที่เพิ่ม: ${selectedDate.toLocal()}".split(' ')[0]),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate() &&
                      selectedCategory != null) {
                    var provider = Provider.of<MoblieAppItemProvider>(context,
                        listen: false);
                    Moblieappitem newItem = Moblieappitem(
                      title: titleController.text,
                      score: int.parse(scoreController.text),
                      cate: selectedCategory!,
                      date: selectedDate,
                    );
                    provider.addItem(newItem);
                    Navigator.pop(context);
                  }
                },
                child: const Text('เพิ่มแอป'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
