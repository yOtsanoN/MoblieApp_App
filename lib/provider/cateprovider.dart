import 'package:flutter/foundation.dart';
import 'package:moblieapp_app/model/cateitem.dart';
import 'package:moblieapp_app/database/cateDB.dart';

class CategoryProvider with ChangeNotifier {
  List<Cateitem> categories = [];

  List<Cateitem> getCategories() {
    return categories;
  }

  void initData() async {
    var db = CategoryDB(dbName: 'categories.db');
    categories = await db.loadAllCategories();
    notifyListeners();
  }

  void addCategory(Cateitem category) async {
    var db = CategoryDB(dbName: 'categories.db');
    await db.insertCategory(category);
    categories = await db.loadAllCategories();
    notifyListeners();
  }

  void deleteCategory(Cateitem category) async {
    var db = CategoryDB(dbName: 'categories.db');
    await db.deleteCategory(category.cateID!);
    categories = await db.loadAllCategories();
    notifyListeners();
  }

  void updateCategory(Cateitem category) async {
    var db = CategoryDB(dbName: 'categories.db');
    await db.updateCategory(category);
    categories = await db.loadAllCategories();
    notifyListeners();
  }

  void insertDummyCategories() async {
    var db = CategoryDB(dbName: 'categories.db');
    await db.insertDummyCategories();
    categories = await db.loadAllCategories();
    notifyListeners();
  }
}
