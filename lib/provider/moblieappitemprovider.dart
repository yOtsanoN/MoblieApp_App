import 'package:flutter/foundation.dart';
import 'package:moblieapp_app/model/moblieappitem.dart';
import 'package:moblieapp_app/database/moblieappDB.dart';

class MoblieAppItemProvider with ChangeNotifier {
  List<Moblieappitem> items = [];

  List<Moblieappitem> getItems() {
    return items;
  }

  void initData() async {
    var db = MoblieAppItemDB(dbName: 'moblieapp_items.db');
    items = await db.loadAllItems();
    notifyListeners();
  }

  void addItem(Moblieappitem item) async {
    var db = MoblieAppItemDB(dbName: 'moblieapp_items.db');
    await db.insertItem(item);
    items = await db.loadAllItems();
    notifyListeners();
  }

  void deleteItem(int keyID) async {
    var db = MoblieAppItemDB(dbName: 'moblieapp_items.db');
    await db.deleteItem(keyID);
    items = await db.loadAllItems();
    notifyListeners();
  }

  void updateItem(Moblieappitem item) async {
    var db = MoblieAppItemDB(dbName: 'moblieapp_items.db');
    await db.updateItem(item);
    items = await db.loadAllItems();
    notifyListeners();
  }
}
