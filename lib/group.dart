import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'time.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

List<String> selectedUsers = [];
bool loading = true;
var hstyle = TextStyle(fontSize: 30, color: Colors.black);

class Group extends StatefulWidget {

  @override
  _GroupState createState() => new _GroupState();
}
class _GroupState extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Users"),
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
              _retrieveUsers(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    color: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Create group', style: TextStyle(fontSize: 25, color: Colors.white),),),
                      elevation: 5.0,
                      onPressed: (){
                        getFreeTime(selectedUsers);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {return TimetableExample();},),);
                      },
              ),)),
            ],
          ),
        ),
      ),
    );
  }

  void getFreeTime(List<String> usersList) async{

    final userCollection = Firestore.instance.collection('users');
    List<List<String>> init = [];
    List<BasicEvent> events = [];

    selectedUsers.forEach((element) async{
      await userCollection.document(element).get().then((value) {
        init.add(value.data['events'].cast<String>());
      });

      List<List<DateTime>> all = [];
      List<List<DateTime>> output = [];

      List<List<DateTime>> test1 = [];
      List<List<DateTime>> test2 = [];

      List<String> first = init[0];
      List<String> sec = init[1];

      for(int i = 0; i < first.length; i+=2){
        List<DateTime> temp = [DateTime.parse(first[i]).subtract(Duration(hours: 1)), DateTime.parse(first[i+1]).subtract(Duration(hours: 1))];
        test2.add(temp);
      }
      for(int i = 0; i < sec.length; i+=2){
        List<DateTime> temp = [DateTime.parse(sec[i]).subtract(Duration(hours: 1)), DateTime.parse(sec[i+1]).subtract(Duration(hours: 1))];
        test1.add(temp);
      }

      print(test1);
      print(test2);


      int i =0;
      int j =0;

      while(i!=test1.length || j!=test2.length){
        if(j == test2.length){
          all.add(test1[i]);
          i++;
        } else if(i == test1.length){
          all.add(test2[j]);
          j++;
        } else {
          if(test1[i][0].isBefore(test2[j][0])){
            all.add(test1[i]);
            i++;
          } else {
            all.add(test2[j]);
            j++;
          }
        }
      }

      print('in getFreeTime time.dart');
      print(all);

      //remove unneccasary

      for(int i = 0; i < all.length; i++){
        if(i == all.length-1){
          if(all[i-1][1].isAfter(all[i][0]) || all[i][1].isAtSameMomentAs(all[i+1][0])){
            if(all[i-1][1].isBefore(all[i][1])){
              all[i-1][1] = all[i][1];
            }
            all.removeAt(i);
          }
        }else{
          if(all[i][1].isAfter(all[i+1][0]) || all[i][1].isAtSameMomentAs(all[i+1][0])){
            if(all[i][1].isBefore(all[i+1][1])){
              all[i][1] = all[i+1][1];
            }
            all.removeAt(i+1);
          }
        }
      }
      // Это не нужно, просто если с двумя сразу пересекается
      for(int i = 0; i < all.length; i++){
        if(i == all.length-1){
          if(all[i-1][1].isAfter(all[i][0])){
            if(all[i-1][1].isBefore(all[i][1])){
              all[i-1][1] = all[i][1];
            }
            all.removeAt(i);
          }
        }else{
          if(all[i][1].isAfter(all[i+1][0])){
            if(all[i][1].isBefore(all[i+1][1])){
              all[i][1] = all[i+1][1];
            }
            all.removeAt(i+1);
          }
        }
      }
      print('final result');
      print(all);


//    DateTime firstEvent = all[0][0];
//    output.add([DateTime(firstEvent.year, firstEvent.month, firstEvent.day, 8), firstEvent]);
      for(int i = 0; i < all.length - 1; i++){
        output.add([all[i][1], all[i+1][0]]);
      }
      print('output');
      print(output);

      listOfFreetime = output;
      for(int i = 0; i < output.length; i++){
        LocalDateTime start = LocalDateTime(output[i][0].year, output[i][0].month, output[i][0].day, output[i][0].hour, output[i][0].minute, 0);
        LocalDateTime end = LocalDateTime(output[i][1].year, output[i][1].month, output[i][1].day, output[i][1].hour, output[i][1].minute, 0);
        events.add(BasicEvent(id: i, title: 'Free Time', start: start, end: end, color: Colors.deepPurple));
      }

      listEvents = events;
      setState((){ loading = false; });

//    i = 0;
//    j = 0;
//
//    while(firstEvent.day < 14){
//      if(firstEvent.hour >= 8){
//        output.add([DateTime(firstEvent.year, firstEvent.month, firstEvent.day, 8), firstEvent]);
//      }
//
//    }
    });


  }

  StreamBuilder<QuerySnapshot> _retrieveUsers() {

    return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            print("retrieve users do not have data.");
            selectedUsers = [];
            return Container();
          }

          // This ListView widget consists of a list of tiles
          // each represents a user.
          return ListView.builder(
              itemCount: snapshot.data.documents.length,
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
                      title: new Text(snapshot.data.documents[index]['name']),
                      subtitle: new Text(snapshot.data.documents[index]['email']),
                      onTap: () => setState((){
                        if (selectedUsers.contains(snapshot.data.documents[index].documentID)) {
                          selectedUsers.remove(snapshot.data.documents[index].documentID);
                        } else {
                          selectedUsers.add(snapshot.data.documents[index].documentID);
                        }
                        print(selectedUsers);
                      },),
                      selected: selectedUsers.contains(snapshot.data.documents[index].documentID),
                    ),
                  ),
                );
              }
          );
        }
    );
  }
}

