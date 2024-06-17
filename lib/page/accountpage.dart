import 'dart:io';
import 'package:account_manager/database/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../database/databasehelper.dart';
import 'package:image_cropper/image_cropper.dart';
import '../constrant.dart';

import 'package:flutter/material.dart';

class Accountpage extends StatefulWidget {
  final int GameId;
  final String GameName;
  final String GameImage;

  const Accountpage(
      {super.key,
      required this.GameId,
      required this.GameName,
      required this.GameImage});

  @override
  State<Accountpage> createState() => _AccountpageState();
}

class _AccountpageState extends State<Accountpage> {
  Databasehelper databasehelper = Databasehelper.instance;
  final TextEditingController accountController = TextEditingController();
  final TextEditingController accountSearch = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final ScrollController _firstController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();
  CroppedFile? _croppedFile;
  late String imagePath;
  List<Map<String, dynamic>> allAccount = [];
  List<Map<String, dynamic>> _foundAccount = [];

  void _sortAccountByName() {
    allAccount.sort((a, b) {
      return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
    });
  }

  Future<void> _getAllAccounts() async {
    List<Map<String, dynamic>> Account =
        await databasehelper.getAccountsByGameId(widget.GameId);
    setState(() {
      allAccount = List<Map<String, dynamic>>.from(
          Account); //agar tidak error Unsupported operation: read-only
      _foundAccount = allAccount;
      _sortAccountByName();
    });
    print(allAccount);
  }

  void _searchByAccount(String name) {
    List<Map<String, dynamic>> result = [];
    if (name.isEmpty) {
      result = allAccount;
    } else {
      result = allAccount
          .where((account) => account["name"]
              .toString()
              .toLowerCase()
              .startsWith(name.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundAccount = result;
    });
  }

  void clearControl() {
    nameController.clear();
    usernameController.clear();
    passwordController.clear();
    deskripsiController.clear();
  }

  void addAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Account'),
        content: SingleChildScrollView(
          controller: _firstController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        controller: nameController,
                        name: 'Nama',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nama',
                        ),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        controller: usernameController,
                        name: 'Username',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        controller: passwordController,
                        name: 'Password',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        controller: deskripsiController,
                        name: 'Deskripsi',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Deskripsi',
                        ),
                      ),
                      const SizedBox(height: 10),
                      MaterialButton(
                        child: Text("Save"),
                        color: Colors.green,
                        onPressed: () async {
                          Account account = Account(
                            id: DateTime.now().microsecondsSinceEpoch,
                            name: nameController.text,
                            username: usernameController.text,
                            password: passwordController.text,
                            deskripsi: deskripsiController.text,
                            gameId: widget.GameId,
                          );
                          databasehelper.insertAccount(account);
                          List<Map<String, dynamic>> accounts =
                              await databasehelper
                                  .getAccountsByGameId(widget.GameId);
                          print("Banyak account = ${accounts.length}");
                          Navigator.pop(context);
                          clearControl();
                          _getAllAccounts();
                          print(allAccount);
                          accountNotif('added');
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

  void editAccount(
      int id, String name, String username, String password, String deskripsi) {
    final TextEditingController nameEdit = TextEditingController(text: name);
    final TextEditingController usernameEdit =
        TextEditingController(text: username);
    final TextEditingController passwordEdit =
        TextEditingController(text: password);
    final TextEditingController deskripsiEdit =
        TextEditingController(text: deskripsi);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Account'),
        content: SingleChildScrollView(
          controller: _firstController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
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
                      FormBuilderTextField(
                        controller: usernameEdit,
                        name: 'Username',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        controller: passwordEdit,
                        name: 'Password',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        controller: deskripsiEdit,
                        name: 'Deskripsi',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Deskripsi',
                        ),
                      ),
                      const SizedBox(height: 10),
                      MaterialButton(
                        color: Colors.green,
                        onPressed: () async {
                          Account account = Account(
                            id: id,
                            name: nameEdit.text,
                            username: usernameEdit.text,
                            password: passwordEdit.text,
                            deskripsi: deskripsiEdit.text,
                            gameId: widget.GameId,
                          );
                          databasehelper.updateAccount(account.toMap());
                          List<Map<String, dynamic>> accounts =
                              await databasehelper
                                  .getAccountsByGameId(widget.GameId);
                          print("Banyak account = ${accounts.length}");
                          Navigator.pop(context);
                          clearControl();
                          _getAllAccounts();
                          print(allAccount);
                          accountNotif('edited');
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

  @override
  void initState() {
    super.initState();
    _getAllAccounts();
  }

  void copyNotif(String notif) {
    showTopSnackBar(Overlay.of(context),
        CustomSnackBar.success(message: "$notif has been copied"));
  }

  void accountNotif(String notif) {
    if (notif.toLowerCase() == 'deleted') {
      showTopSnackBar(Overlay.of(context),
          CustomSnackBar.error(message: "Your account has been $notif"));
    } else {
      showTopSnackBar(Overlay.of(context),
          CustomSnackBar.success(message: "Your account has been $notif"));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addAccount();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: size.height * 0.3,
            decoration: const BoxDecoration(
              color: kBlueColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.GameName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: AspectRatio(
                          aspectRatio: 1, // Rasio 1:1
                          child: ClipRRect(
                            child: CircleAvatar(
                              backgroundImage: FileImage(
                                File(widget.GameImage),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SearchBar(
                      controller: accountSearch,
                      leading: const Icon(Icons.search),
                      hintText: "Cari Account",
                      onChanged: (value) =>
                          {_searchByAccount(accountSearch.text)},
                      trailing: <Widget>[
                        Tooltip(
                          message: 'Clear',
                          child: IconButton(
                              onPressed: () {
                                accountSearch.clear();
                                _getAllAccounts();
                              },
                              icon: const Icon(Icons.highlight_remove)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _foundAccount.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> account = _foundAccount[index];
                return Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('Nama: ${account['name']}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.circle),
                          title: Text('Username: ${account['username']}'),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: account['username']));
                            copyNotif("Username");
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: Text('Password: ${account['password']}'),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: account['password']));
                            copyNotif("Password");
                          },
                        ),
                        ExpandableListTile(
                          description: 'Deskripsi: ${account['deskripsi']}',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              onPressed: () async {
                                print(account['id']);
                                await databasehelper
                                    .deleteAccount(account['id']);
                                await _getAllAccounts();
                                accountNotif('deleted');
                              },
                              icon: const Icon(Icons.delete),
                            ),
                            IconButton(
                              onPressed: () {
                                editAccount(
                                    account['id'],
                                    account['name'],
                                    account['username'],
                                    account['password'],
                                    account['deskripsi']);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableListTile extends StatefulWidget {
  final String description;

  const ExpandableListTile({super.key, required this.description});

  @override
  _ExpandableListTileState createState() => _ExpandableListTileState();
}

class _ExpandableListTileState extends State<ExpandableListTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description),
      title: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Text(
          widget.description,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
