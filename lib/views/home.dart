import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notekeeper/boxes/boxes.dart';
import 'package:notekeeper/models/notes.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Note Keeper Assignment",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            Text("Submitted by: Owais Yosuf",
                style: TextStyle(color: Colors.white, fontSize: 12))
          ],
        ),
        backgroundColor: Colors.cyan,
      ),
      body: ValueListenableBuilder<Box<Notes>>(
          valueListenable: Boxes.getData().listenable(),
          builder: (context, box, _) {
            var data = box.values.toList().cast<Notes>();
            return data.isEmpty
                ? const Center(
                    child: Text(
                      "Empty Notepad",
                      style: TextStyle(fontSize: 17),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(4),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final imagePath = data[index].imagePath.toString();
                          return GestureDetector(
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  builder: ((context) => NoteOptions(
                                      data: data[index], index: index)));
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        data[index].title.toString(),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                          data[index].description.toString(),
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ),
                                    imagePath != "null"
                                        ? Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Image.file(
                                              File(imagePath),
                                              height: 100,
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => const ImagePickerButton());
        },
        backgroundColor: Colors.cyan,
        label: const Text(
          "Add New Note",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class NoteOptions extends StatelessWidget {
  const NoteOptions({super.key, required this.data, required this.index});

  final Notes data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => ImagePickerButton(
                              title: data.title,
                              description: data.description,
                              imagePath: data.imagePath,
                              index: index));
                    },
                    child: const MenuOption(
                        icon: Icons.edit_document, label: "Edit Note")),
                const Divider(),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text("Delete Note"),
                                content: const Text("Sure to delete?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("No")),
                                  TextButton(
                                      onPressed: () {
                                        data.delete();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Row(
                                                  children: [
                                                    Text(
                                                      "Note deleted successfully",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              8, 0, 0, 0),
                                                      child: Icon(
                                                          Icons.done_all,
                                                          color: Colors.white),
                                                    )
                                                  ],
                                                ),
                                                duration: Duration(seconds: 2),
                                                backgroundColor: Colors.red));
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Yes"))
                                ],
                              ));
                    },
                    child: const MenuOption(
                        icon: Icons.delete_forever, label: "Delete Note")),
                const Divider(),
                GestureDetector(
                    onTap: () {
                      if (data.imagePath != "null") {
                        XFile imageFile = XFile(data.imagePath!);
                        Share.shareXFiles([imageFile],
                            text: "*${data.title}*\n${data.description}",
                            subject: "Share Note");
                      } else {
                        Share.share("*${data.title}*\n${data.description}");
                      }
                      Navigator.pop(context);
                    },
                    child: const MenuOption(
                        icon: Icons.share, label: "Share Note")),
              ],
            ),
          ),
        ));
  }
}

class MenuOption extends StatelessWidget {
  const MenuOption({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
            child: Icon(icon),
          ),
          Expanded(child: Text(label))
        ],
      ),
    );
  }
}

class ImagePickerButton extends StatefulWidget {
  const ImagePickerButton(
      {super.key, this.title, this.description, this.imagePath, this.index});

  final String? title;
  final String? description;
  final String? imagePath;
  final int? index;

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  var heading = "Add New Note";
  var buttonLabel = "Add Note";
  XFile? image;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  var imagePath = "null";
  var titleValid = true;
  var descriptionValid = true;

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = pickedFile;
      imagePath = image!.path;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.title != null) {
        setState(() {
          titleController.text = widget.title!;
          descriptionController.text = widget.description!;
          imagePath = widget.imagePath!;
          heading = "Update Note";
          buttonLabel = "Update";
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    heading,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Divider(),
                InputText(
                    hint: "Title",
                    keyboard: TextInputType.text,
                    lines: 1,
                    controller: titleController,
                    errorMsg: "Can't be less than 3 characters",
                    isValid: titleValid),
                const Divider(),
                InputText(
                    hint: "Note description",
                    keyboard: TextInputType.multiline,
                    lines: 3,
                    controller: descriptionController,
                    errorMsg: "Can't be less than 5 characters",
                    isValid: descriptionValid),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: imagePath == "null"
                      ? const Padding(
                          padding: EdgeInsets.all(50),
                          child: Icon(Icons.camera_alt, size: 50),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.file(
                            File(imagePath),
                            height: 130,
                          ),
                        ),
                ),
                AddNoteButton(
                    title: titleController,
                    description: descriptionController,
                    imagePath: imagePath,
                    updateTitleValid: (bool isValid) {
                      setState(() {
                        titleValid = isValid;
                      });
                    },
                    updateDescriptionValid: (bool isValid) {
                      setState(() {
                        descriptionValid = isValid;
                      });
                    },
                    buttonLabel: buttonLabel,
                    index: widget.index)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddNoteButton extends StatelessWidget {
  const AddNoteButton(
      {super.key,
      required this.title,
      required this.description,
      required this.imagePath,
      required this.updateTitleValid,
      required this.updateDescriptionValid,
      required this.buttonLabel,
      required this.index});

  final TextEditingController title;
  final TextEditingController description;
  final String imagePath;
  final Function(bool) updateTitleValid;
  final Function(bool) updateDescriptionValid;
  final String buttonLabel;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
                onPressed: () {
                  updateTitleValid(true);
                  updateDescriptionValid(true);
                  title.text = title.text.trim();
                  description.text = description.text.trim();
                  if (title.text.length < 3) {
                    updateTitleValid(false);
                  } else if (description.text.length < 5) {
                    updateDescriptionValid(false);
                  } else {
                    if (buttonLabel == "Add Note") {
                      final data = Notes(
                          title: title.text,
                          description: description.text,
                          imagePath: imagePath);
                      final box = Boxes.getData();
                      box.add(data);
                      data.save();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Row(
                            children: [
                              Text(
                                "Note added successfully",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: Icon(Icons.done, color: Colors.white),
                              )
                            ],
                          ),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.green));
                    } else {
                      final box = Boxes.getData();
                      final Notes existingNote = box.getAt(index!)!;
                      existingNote.title = title.text;
                      existingNote.description = description.text;
                      existingNote.imagePath = imagePath;
                      box.putAt(index!, existingNote);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Row(
                            children: [
                              Text(
                                "Note updated successfully",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child:
                                    Icon(Icons.done_all, color: Colors.white),
                              )
                            ],
                          ),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.green));
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(buttonLabel))),
      ],
    );
  }
}

class InputText extends StatelessWidget {
  const InputText(
      {super.key,
      required this.hint,
      required this.keyboard,
      required this.lines,
      required this.controller,
      required this.errorMsg,
      required this.isValid});

  final String hint;
  final TextInputType keyboard;
  final int lines;
  final TextEditingController controller;
  final String errorMsg;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: lines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: EdgeInsets.zero,
          errorText: isValid ? null : errorMsg),
    );
  }
}
