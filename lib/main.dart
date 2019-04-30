/*------------ Add Start --------------*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseUser firebaseUser;
final FirebaseAuth _auth = FirebaseAuth.instance;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'かしかりメモ',
        // home: Splash(),
        routes: <String, WidgetBuilder>{
          '/': (_) => new Splash(),
          '/list': (_) => new List()
        });
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _getUser(context);
    return Scaffold(
      body: Center(
        child: const Text("スプラッシュ画面"),
      ),
    );
  }
}

void _getUser(BuildContext context) async {
  try {
    firebaseUser = await _auth.currentUser();
    if (firebaseUser == null) {
      await _auth.signInAnonymously();
      firebaseUser = await _auth.currentUser();
    }
    Navigator.pushReplacementNamed(context, '/list');
  } catch (e) {
    Fluttertoast.showToast(msg: "Firebase との接続に失敗しました");
  }
}

class List extends StatefulWidget {
  @override
  _MyList createState() => _MyList();
}

class _MyList extends State<List> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト画面"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              print("login");
              showBasicDialog(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .collection('transaction')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text('Loarding...');
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              padding: const EdgeInsets.only(top: 10.0),
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          print("新規作成ボタンを押しました");
          Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: "/new"),
                builder: (BuildContext contxt) => InputForm(null),
              ));
        },
      ),
    );
  }
}

void showBasicDialog(BuildContext context) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email, password;

  if (firebaseUser.isAnonymous) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("ログイン/登録ダイアログ"),
              content: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                          icon: const Icon(Icons.mail), labelText: 'Email'),
                      onSaved: (String value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Emailは必須入力です';
                        }
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.vpn_key), labelText: 'Password'),
                      onSaved: (String value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Passwordは必須入力です';
                        }
                        if (value.length < 6) {
                          return 'Passwordは6桁以上です';
                        }
                      },
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: const Text('登録'),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      _createUser(context, email, password);
                    }
                  },
                ),
                FlatButton(
                  child: const Text('ログイン'),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      _signIn(context, email, password);
                    }
                  },
                )
              ],
            ));
  } else {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('確認ダイアログ'),
              content: Text(firebaseUser.email + '　でログインしています'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: const Text('ログアウト'),
                  onPressed: () {
                    _auth.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (_) => false);
                  },
                )
              ],
            ));
  }
}

void _signIn(BuildContext context, String email, String password) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  } catch (e) {
    Fluttertoast.showToast(msg: 'Firebaseのログインに失敗しました');
  }
}

void _createUser(BuildContext context, String email, String password) async {
  try {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  } catch (e) {
    Fluttertoast.showToast(msg: 'Firebaseのログインに失敗しました');
  }
}

class InputForm extends StatefulWidget {
  InputForm(this.document);
  final DocumentSnapshot document;

  @override
  _MyInputFormState createState() => _MyInputFormState();
}

class _FormDate {
  String borrowOrLend = "borrow";
  String user;
  String stuff;
  DateTime date = DateTime.now();
}

class _MyInputFormState extends State<InputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _FormDate _date = _FormDate();

  Future<DateTime> _selectTime(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: _date.date,
      firstDate: DateTime(_date.date.year - 2),
      lastDate: DateTime(_date.date.year + 2),
    );
  }

  void _setLendOrRent(String value) {
    setState(() {
      _date.borrowOrLend = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference _mainReference;
    _mainReference = Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection('transaction')
        .document();
    bool deleteFlg = false;
    if (widget.document != null) {
      if (_date.user == null && _date.stuff == null) {
        _date.borrowOrLend == widget.document['borrowOrLend'];
        _date.user == widget.document['user'];
        _date.stuff == widget.document['stuff'];
        _date.date == widget.document['date'];
      }
      _mainReference = Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .collection('transaction')
          .document(widget.document.documentID);
      deleteFlg = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('かしかり入力'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              print("保存ボタンを押しました");
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _mainReference.setData({
                  'borrowOrLend': _date.borrowOrLend,
                  'user': _date.user,
                  'stuff': _date.stuff,
                  'date': _date.date
                });
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: !deleteFlg
                ? null
                : () {
                    print("削除ボタンを押しました");
                    _mainReference.delete();
                    Navigator.pop(context);
                  },
          )
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              RadioListTile(
                value: "borrow",
                groupValue: _date.borrowOrLend,
                title: Text("借りた"),
                onChanged: (String value) {
                  print("借りたをタッチしました");
                  _setLendOrRent(value);
                },
              ),
              RadioListTile(
                value: "lend",
                groupValue: _date.borrowOrLend,
                title: Text("貸した"),
                onChanged: (String value) {
                  print("貸したをタッチしました");
                  _setLendOrRent(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: '相手の名前',
                  labelText: 'Name',
                ),
                onSaved: (String value) {
                  _date.user = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return '名前は必須入力項目です';
                  }
                },
                initialValue: _date.user,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.business_center),
                  hintText: '借りたもの、貸したもの',
                  labelText: 'loan',
                ),
                onSaved: (String value) {
                  _date.stuff = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return '借りたもの、貸したものは必須入力項目です';
                  }
                },
                initialValue: _date.stuff,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("締切日:${_date.date.toString().substring(0, 10)}"),
              ),
              RaisedButton(
                child: const Text("締切日変更"),
                onPressed: () {
                  print("締切日変更をタッチしました");
                  _selectTime(context).then((time) {
                    if (time != null && time != _date.date) {
                      setState(() {
                        _date.date = time;
                      });
                    }
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
  return Card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.android),
          title: Text("【" +
              (document['borrowOrLend'] == "lend" ? "貸" : "借") +
              "】" +
              document['stuff']),
          subtitle: Text("期限 : " +
              document['date'].toString().substring(0, 10) +
              "\n 相手 : " +
              document['user']),
        ),
        ButtonTheme.bar(
          child: ButtonBar(
            children: <Widget>[
              FlatButton(
                child: const Text("へんしゅう"),
                onPressed: () {
                  print("編集ボタンを押しました");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        settings: const RouteSettings(name: "/edit"),
                        builder: (BuildContext context) => InputForm(document)),
                  );
                },
              )
            ],
          ),
        ),
      ],
    ),
  );
}
