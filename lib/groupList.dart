import 'package:flutter/material.dart';
import 'time.dart';

List<String> groups = ["Work", "Business club", "Relatives"];
List<String> names = ["Nikita, John, Mira, Andre, Maria", "Felix, Marzia, Edgar", "Alex, Shawn, Lina"];
class GroupList extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.deepPurple,
      title: Text("My Groups"),
  centerTitle: true,
  ),
  body: Container(
  decoration: BoxDecoration(
  gradient: LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [Colors.blue[100], Colors.blue[400]],
  ),
  ),
  child: Center(
  child: Column(
  children: <Widget>[
  ListView.builder(
      itemCount: 3,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index) {
      return Card(
        elevation: 20.0,
        margin: new EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        child: Container(
        padding: EdgeInsets.only(right: 12.0),
        child: new ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
        title: new Text(groups[index]),
        subtitle: new Text(names[index]),
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {return TimetableExample();},),);
          },
  )));})
  ])
  )
  )
  );}}