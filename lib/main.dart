/*------------ Add Start --------------*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'かしかりメモ',
      home: List(),
    );
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
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: StreamBuilder<QuerySnapshot>(
      //     stream: Firestore.instance.collection('kashikari-memo').snapshots(),
      //     builder:
      //         (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      //       if (!snapshot.hasData) return const Text('Loarding...');
      //       return ListView.builder(
      //         itemCount: snapshot.data.documents.length,
      //         padding: const EdgeInsets.only(top: 10.0),
      //         itemBuilder: (context, index) =>
      //             _buildListItem(context, snapshot.data.documents[index]),
      //       );
      //     },
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          print("新規作成ボタンを押しました");
          Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: "/new"),
                builder: (BuildContext contxt) => InputForm(),
              ));
        },
      ),
    );
  }
}

class InputForm extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('かしかり入力'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              print("保存ボタンを押しました");
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              print("削除ボタンを押しました");
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
                },
              ),
              RadioListTile(
                value: "lend",
                groupValue: _date.borrowOrLend,
                title: Text("貸した"),
                onChanged: (String value) {
                  print("貸したをタッチしました");
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.business_center),
                  hintText: '借りたもの、貸したもの',
                  labelText: 'loan',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("締切日:${_date.date.toString().substring(0, 10)}"),
              ),
              RaisedButton(
                child: const Text("締切日変更"),
                onPressed: () {
                  print("締切日変更をタッチしました");
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
                },
              )
            ],
          ),
        ),
      ],
    ),
  );
}
