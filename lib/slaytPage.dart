import 'package:flutter/material.dart';
import 'models/slaytModel.dart';
import 'package:mysql1/mysql1.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SlaytPage extends StatefulWidget {
  final String _title;
  SlaytPage(this._title);
  @override
  _SlaytPageState createState() => _SlaytPageState();
}

class _SlaytPageState extends State<SlaytPage> {
  String title;
  String subtitle;
  var formKey = GlobalKey<FormState>();

  int sayac = 1;
  String islem = "";
  int slaytId = 0;
  List<Slayt> slaytList = [];

  @override
  void initState() {
    super.initState();
    _mysqlIslemler(islem, slaytId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(title: Text(widget._title)),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    onSaved: (x) {
                      setState(() {
                        title = x;
                      });
                    },
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: 20),
                        labelText: "Başlık",
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          width: 1,
                        ))),
                    validator: (x) {
                      if (x.isEmpty) {
                        return "Doldurulması Zorunludur!";
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  TextFormField(
                    onSaved: (x) {
                      setState(() {
                        subtitle = x;
                        islem = "kaydet";
                      });

                      _mysqlIslemler(islem, slaytId);
                      _onAlertSuccess(context);
                    },
                    maxLength: 250,
                    textInputAction: TextInputAction.done,
                    maxLines: 3,
                    autofocus: true,
                    decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: 20),
                        labelText: "Manşet",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                          ),
                        )),
                    validator: (x) {
                      if (x.isEmpty) {
                        return "Doldurulması Zorunludur!";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.all(10),
              child: Text(
                "Silmek İstediğiniz Kaydı Sağa Kaydır!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 20),
              )),
          Expanded(
            child: ListView.builder(
                itemCount: slaytList.length,
                itemBuilder: (context, index) {
                  sayac++;

                  return Dismissible(
                    key: Key(sayac.toString()),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      setState(() {
                        islem = "sil";
                      });

                      _mysqlIslemler(islem, slaytList[index].id);
                      _onAlertWarning(context);
                    },
                    child: Card(
                        color: index % 2 == 0
                            ? Colors.purple[100]
                            : Colors.purple[200],
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: slaytList[index].image != null
                                ? AssetImage(
                                    "assets/images/${slaytList[index].image}.${slaytList[index].imageType}")
                                : AssetImage("assets/images/icon.png"),
                          ),
                          title: Text(slaytList[index].title),
                          subtitle: Text(slaytList[index].subtitle),
                          trailing: Icon(
                            Icons.arrow_right,
                            size: 36,
                          ),
                        )),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState.validate()) {
            formKey.currentState.save();
            formKey.currentState.reset();
          }
        },
        child: Icon(Icons.add, size: 32),
      ),
    );
  }

  Future _mysqlIslemler(String _islem, int _slaytId) async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '93.89.225.127',
        port: 3306,
        user: 'pmksBb556_user01',
        password: '121212iP+-',
        db: 'pmksBb556_db0001'));

    if (_islem == "kaydet") {
      await conn.query(
          'insert into slayt (title, subtitle, confirm) values (?, ?, ?)',
          [title, subtitle, 1]);
      slaytList = [];
    }

    if (_islem == "sil") {
      await conn.query('delete from slayt where id=?', [_slaytId]);

      slaytList = [];
    }

    var results = await conn.query('select * from slayt');

    for (var row in results) {
      setState(() {
        slaytList.add(Slayt(
            row['id'],
            row['title'],
            row['subtitle'],
            row['image'],
            row['imageType'],
            row['url'],
            row['target'],
            row['buttonTitle'],
            row['confirm'],
            row['text']));
      });
    }

    await conn.close();

    islem = "";
  }
  void _onAlertWarning(BuildContext context) {
    Alert(
      type: AlertType.warning,
      context: context,
      title: "KAYIT SİLİNDİ!",
      buttons: [
        DialogButton(
          child: Text(
            "KAPAT",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  void _onAlertSuccess(BuildContext context) {
    Alert(
      type: AlertType.success,
      context: context,
      title: "KAYIT EKLENDİ!",
      buttons: [
        DialogButton(
          child: Text(
            "KAPAT",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }
}
