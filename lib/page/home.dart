import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../database/databasehelper.dart';
import 'package:image_cropper/image_cropper.dart';
import '../database/game.dart';
import 'accountpage.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:quickalert/quickalert.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController gameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final ScrollController addControlerScrol = ScrollController();
  Databasehelper databasehelper = Databasehelper.instance;
  CroppedFile? _croppedFile;
  late String imagePath;
  List<Map<String, dynamic>> allGame = [];
  List<Map<String, dynamic>> _foundGame = [];

  void addGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add game'),
        content: SingleChildScrollView(
          controller: addControlerScrol,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderImagePicker(
                        name: 'GameIcon',
                        decoration:
                            const InputDecoration(labelText: 'Game Icon'),
                        maxImages: 1,
                        transformImageWidget: (context, displayImage) => Card(
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                              child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: displayImage,
                          )),
                        ),
                        availableImageSources: const [
                          ImageSourceOption.gallery
                        ],
                        onChanged: (value) async {
                          final directory =
                              await getApplicationDocumentsDirectory();
                          XFile image = value?.first;
                          await cropImage(image);
                          String newName = "${DateTime.now().microsecond}";
                          final newPath = Path.join(directory.path, newName);
                          final File newImage =
                              await File(_croppedFile!.path).copy(newPath);
                          setState(() {
                            imagePath = newImage.path;
                          });
                          var appDir = (await getTemporaryDirectory()).path;
                          Directory(appDir).delete(recursive: true);
                          print("letak imagePath ====== ${imagePath}");
                        },
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        controller: nameController,
                        name: 'Nama',
                        // maxLength: 14,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nama',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MaterialButton(
                        child: Text("Save"),
                        color: Colors.green,
                        onPressed: () async {
                          Game game = Game(
                              id: DateTime.now().microsecond,
                              name: nameController.text,
                              photo: imagePath);
                          databasehelper.insertGame(game);
                          List<Map<String, dynamic>> games =
                              await databasehelper.getAllGames();
                          print("Banyak game = ${games.length}");
                          Navigator.pop(context);
                          nameController.clear();
                          _getAllGames();
                          print(allGame);
                          notif('Add game');
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void editGame(int id, String name, String photo) {
    final TextEditingController nameEdit = TextEditingController(text: name);
    final photoEdit = photo;
    String newPhoto = photoEdit;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit game'),
        content: SingleChildScrollView(
          controller: addControlerScrol,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderImagePicker(
                        name: 'GameIcon',
                        decoration:
                            const InputDecoration(labelText: 'Game Icon'),
                        maxImages: 1,
                        placeholderImage: FileImage(File(photo)),
                        imageQuality: 10,
                        transformImageWidget: (context, displayImage) => Card(
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: displayImage,
                            ),
                          ),
                        ),
                        availableImageSources: const [
                          ImageSourceOption.gallery
                        ],
                        onReset: () {
                          setState(() {
                            newPhoto = photoEdit;
                            print(newPhoto);
                          });
                        },
                        onChanged: (value) async {
                          if (value != null && value.isNotEmpty) {
                            final directory =
                                await getApplicationDocumentsDirectory();
                            XFile image = value.first;
                            await cropImage(image);
                            String newName = "${DateTime.now().microsecond}";
                            final newPath = Path.join(directory.path, newName);
                            final File newImage =
                                await File(_croppedFile!.path).copy(newPath);
                            setState(() {
                              newPhoto = newImage.path;
                              print(newPhoto);
                            });
                            var appDir = (await getTemporaryDirectory()).path;
                            Directory(appDir).delete(recursive: true);
                            print("letak imagePath ====== ${imagePath}");
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        controller: nameEdit,
                        name: 'Nama',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nama',
                        ),
                      ),
                      const SizedBox(height: 10),
                      MaterialButton(
                        color: Colors.green,
                        onPressed: () async {
                          if (newPhoto != photoEdit) {
                            try {
                              await File(photoEdit).delete();
                            } catch (e) {
                              print("Error deleting old photo: $e");
                            }
                          }
                          Game game = Game(
                              id: id, name: nameEdit.text, photo: newPhoto);
                          await databasehelper.updateGame(game.toMap());
                          List<Map<String, dynamic>> games =
                              await databasehelper.getAllGames();
                          print("Banyak game = ${games.length}");
                          Navigator.pop(context);
                          nameController.clear();
                          _getAllGames();
                          print(allGame);
                          notif('Edit game');
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cropImage(XFile _pickedFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _pickedFile.path,
      maxHeight: 1280,
      maxWidth: 720,
      compressFormat: ImageCompressFormat.png,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      compressQuality: 50,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;
      });
    }
  }

  void _sortGamesByName() {
    allGame.sort((a, b) {
      return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    });
  }

  Future<void> _getAllGames() async {
    List<Map<String, dynamic>> games = await databasehelper.getAllGames();
    setState(() {
      allGame = List<Map<String, dynamic>>.from(
          games); //agar tidak error Unsupported operation: read-only
      _foundGame = allGame;
      _sortGamesByName();
    });
    print(allGame);
  }

  @override
  void initState() {
    super.initState();
    _getAllGames();
  }

  void _searchByName(String name) {
    List<Map<String, dynamic>> result = [];
    if (name.isEmpty) {
      result = allGame;
    } else {
      result = allGame
          .where((game) => game["name"]
              .toString()
              .toLowerCase()
              .startsWith(name.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundGame = result;
    });
  }

  void notif(String notif) {
    if (notif.toLowerCase() == 'delete game') {
      showTopSnackBar(Overlay.of(context),
          CustomSnackBar.error(message: "$notif has been succeeded"));
    } else {
      showTopSnackBar(Overlay.of(context),
          CustomSnackBar.success(message: "$notif has been succeeded"));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; //Mengambil Data layar
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addGame();
        },
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: size.height * 0.2,
            decoration: BoxDecoration(color: Color(0xFFF5CEB8)),
          ),
          SafeArea(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                const Center(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Account Manager',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal),
                  ),
                )),
                const SizedBox(height: 15),
                Container(
                  height: size.height * 0.05,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: FormBuilder(
                    child: FormBuilderTextField(
                      controller: gameController,
                      name: 'Game',
                      decoration: const InputDecoration(
                          // labelText: 'Cari Game',
                          hintText: 'Search Game',
                          suffixIcon: Icon(Icons.search)),
                      onChanged: (value) {
                        _searchByName(gameController.text);
                      },
                      onSubmitted: (value) {
                        gameController.clear();
                      },
                    ),
                  ),
                ),
              ],
            ),
          )),
          Positioned(
              top: size.height * 0.2,
              bottom: 0,
              left: size.width * 0.01,
              right: size.width * 0.01,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0, // Spasi antar item secara vertikal
                  crossAxisSpacing: 8.0, // Spasi antar item secara horizontal
                  childAspectRatio: 1.5, // Perbandingan aspek setiap item
                ),
                itemCount: _foundGame.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> game = _foundGame[index];

                  return GridTile(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute<Widget>(
                              builder: (BuildContext context) {
                            return Accountpage(
                              GameId: game['id'],
                              GameName: game['name'],
                              GameImage: game['photo'],
                            );
                          }));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.file(
                                File(game['photo']),
                                height: 64,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        game['name'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: 'Delete Game',
                                            confirmBtnText: 'Yes',
                                            cancelBtnText: 'No',
                                            onConfirmBtnTap: () async {
                                              await File(game['photo'])
                                                  .delete();
                                              await databasehelper
                                                  .deleteGame(game['id']);
                                              await _getAllGames();
                                              Navigator.pop(context);
                                              notif('Delete game');
                                            },
                                            text:
                                                'Delete all account in ${game['name']}');
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        editGame(game['id'], game['name'],
                                            game['photo']);
                                      },
                                      icon: const Icon(Icons.edit),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),
                  );
                },
              ))
        ],
      ),
    );
  }
}
