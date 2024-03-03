import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notekeeper/models/notes.dart';
import 'package:notekeeper/views/home.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(NotesAdapter());
  await Hive.openBox<Notes>('notes');
  runApp(const NoteKeeper());
}

class NoteKeeper extends StatelessWidget {
  const NoteKeeper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note Keeper",
      home: const HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
    );
  }
}
