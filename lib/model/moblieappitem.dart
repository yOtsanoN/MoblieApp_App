import 'package:moblieapp_app/model/cateitem.dart';

class Moblieappitem {
  int? keyID;
  String title;
  int? score;
  Cateitem cate;
  DateTime? date;

  Moblieappitem({this.keyID, required this.title,required this.score, required this.cate, this.date});
}