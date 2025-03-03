import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:moblieapp_app/model/cateitem.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' as sembast_io;
import 'package:sembast_web/sembast_web.dart'; // Import for Web

class CategoryDB {
  String dbName;

  CategoryDB({required this.dbName});

  // Open the database based on the platform (mobile or web)
  Future<Database> openDatabase() async {
    if (kIsWeb) {
      // For Web, use sembast_web
      return await databaseFactoryWeb.openDatabase(dbName);
    } else {
      // For mobile, use sembast_io
      Directory appDir = await getApplicationDocumentsDirectory();
      String dbLocation = join(appDir.path, dbName);
      return await sembast_io.databaseFactoryIo.openDatabase(dbLocation);
    }
  }

  // Insert a Category into the database
  Future<int> insertCategory(Cateitem category) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('category');
    int keyID = await store.add(db, {
      'title': category.title,
    });
    // db.close();  // Do not close here to avoid closing it too early
    return keyID;
  }

  // Load all Categories from the database
  Future<List<Cateitem>> loadAllCategories() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('category');
    var snapshot = await store.find(db);

    List<Cateitem> categories = snapshot.map((record) {
      return Cateitem(
        cateID: record.key,
        title: record['title'].toString(),
      );
    }).toList();

    // db.close();  // Do not close here to avoid closing it too early
    return categories;
  }

  // Delete a Category from the database
  Future<void> deleteCategory(int cateID) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('category');
    await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, cateID)));
  }

  // Update a Category in the database
  Future<void> updateCategory(Cateitem category) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('category');

    await store.update(
      db,
      {'title': category.title},
      finder: Finder(filter: Filter.equals(Field.key, category.cateID)),
    );
  }

  // Insert dummy Categories into the database
  Future<void> insertDummyCategories() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('category');

    await store.add(db, {'title': 'Games'});
    await store.add(db, {'title': 'News'});
    await store.add(db, {'title': 'Navigator'});
    await store.add(db, {'title': 'Social '});
  }

  // Add a method to fetch a Category by ID (optional but useful for future needs)
  Future<Cateitem?> getCategoryById(int cateID) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('category');
    var record = await store.record(cateID).get(db);

    if (record != null) {
      return Cateitem(
        cateID: cateID,
        title: record['title'].toString(),
      );
    }
    return null;
  }
}
