import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:lufick/api.dart';
import 'package:intl/intl.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  final box = await Hive.openBox<String>('box');
  runApp(Home());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Box<String> box;
  API api = new API();
  String convertResult = "";
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //initialize hive database
    box = Hive.box('box');
    if (box.isEmpty)
      box.put('date', '9/26/2020');
    //get JSON data from the API
    this.getJSONData();
    textController.text = '1';
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  //gets the JSON data from the API
  getJSONData() async {
    var url = 'https://api.exchangeratesapi.io/latest';
    var response = await http.get(url);
    if (response.statusCode == 200){
      Map result = json.decode(response.body);
      this.api.rates = result['rates'];
      this.api.base = result['base'];
      this.api.date = result['date'];
    }
  }

  onConvert(){
    //validate the input
    if (validate(textController.text)){
      int convertValue = int.parse(textController.text);
      convertResult = '';
      //iterate through each key-value pair and calculate the conversion rate and append it to the desired text
      api.rates.forEach((key, value) {
        convertResult += key.toString() + ': ' + (value.toDouble()*convertValue as double).toStringAsFixed(4) + '\n';
      });
      //hides the keyboard
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState((){});
    } else {
      print('error');
    }
  }

  //validates the input
  bool validate(String str) {
    int value = int.parse(str);
    if(str.contains(',') || str.contains(' ') || str.contains('.') || str.contains('-') || value <= 0)
      return false;
    else
      return true;
  }

  onRefresh(){
    var now = new DateTime.now();
    //re-format the date and time
    DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm');
    String formatted = formatter.format(now);
    //add/update the current date and time
    box.put('date', formatted);
  }

  @override
  Widget build(BuildContext context) {
    //force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Euro",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 3,),
              //last refresh status - textfield
              ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<String> box, _){
                  return Text(
                    "Last refresh at " + box.get('date'),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300
                    ),
                  );
                }
              )
            ],
          ),
          actions: [
            Container(
              padding: EdgeInsets.all(10),
              child: RaisedButton(
                color: Colors.blue[0],
                onPressed: onRefresh,
                child: Text(
                  "Refresh",
                ),
              ),
            )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(60, 20, 60, 20),
                child: TextField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: RaisedButton(
                  color: Colors.blue[0],
                  onPressed: onConvert,
                  child: Text("Convert"),
                ),
              ),
              Divider(
                // color: Colors.black,
                height: 20,
                thickness: 2,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Text(convertResult),
                  ),
                )
              )
            ],
          )
        ),
      ),
    );
  }
}
