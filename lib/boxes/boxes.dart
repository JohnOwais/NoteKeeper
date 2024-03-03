import 'package:hive/hive.dart';
import 'package:notekeeper/models/notes.dart';

class Boxes {
  static Box<Notes> getData() => Hive.box('notes');
}
