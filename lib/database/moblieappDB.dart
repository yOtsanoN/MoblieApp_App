import 'dart:io';
import 'package:moblieapp_app/model/cateitem.dart';
import 'package:moblieapp_app/model/moblieappitem.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class MoblieAppItemDB {
  String dbName;

  MoblieAppItemDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);

    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<int> insertItem(Moblieappitem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('moblieapp_items');

    Future<int> keyID = store.add(db, {
      'title': item.title,
      'score': item.score,
      'cateID': item.cate.cateID,
      'date': item.date?.toIso8601String(),
    });
    db.close();
    return keyID;
  }
Future<List<Moblieappitem>> loadAllItems() async {
  var db = await openDatabase();
  var store = intMapStoreFactory.store('moblieapp_items');
  var snapshot = await store.find(db);

  List<Moblieappitem> items = snapshot.map((record) {
    // ตรวจสอบประเภทของ cateID และแปลงให้เป็น int?
    var cateID = (record['cateID'] is int) ? record['cateID'] as int : null;

    // โหลด cateID เพื่อเชื่อมโยงกับหมวดหมู่
    Cateitem category = Cateitem(cateID: cateID, title: ''); // ชื่อหมวดหมู่ยังไม่ได้โหลด

    return Moblieappitem(
      keyID: record.key,
      title: record['title'].toString(),
      score: record['score'] != null ? int.tryParse(record['score'].toString()) : null,
      cate: category,  // ยังไม่ได้โหลด title ของหมวดหมู่
      date: record['date'] != null ? DateTime.parse(record['date'].toString()) : null,
    );
  }).toList();

  db.close();

  // ตอนนี้ `items` มี `Moblieappitem` แต่หมวดหมู่ยังไม่มีชื่อ
  return items;
}


  Future<void> deleteItem(int keyID) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('moblieapp_items');
    await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, keyID)));
    db.close();
  }

  Future<void> updateItem(Moblieappitem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('moblieapp_items');

    await store.update(
      db,
      {
        'title': item.title,
        'score': item.score,
        'cateID': item.cate.cateID,
        'date': item.date?.toIso8601String(),
      },
      finder: Finder(filter: Filter.equals(Field.key, item.keyID)),
    );

    db.close();
  }
}
