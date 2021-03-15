import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'backend.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

bool authSignedIn;
String uid;
String userEmail;
AuthClient client;
var eventList;

const _scopes = const ["https://www.googleapis.com/auth/calendar"];

final GoogleSignIn googleSignIn = GoogleSignIn(scopes: _scopes);

String name;
String imageUrl;

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;


  assert(user.uid != null);
  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);

  uid = user.uid;
  name = user.displayName;
  userEmail = user.email;
  imageUrl = user.photoUrl;
  client = await googleSignIn.authenticatedClient();

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);


  await DatabaseService(uid: uid).updateUserData(userEmail, name, eventList);

  return 'signInWithGoogle succeeded: $user';

}

void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}

getEventList() async {
  var eventList = [];
  var calendar = CalendarApi(client);
  String calendarId = "primary";

  var startTime = DateTime.parse(DateTime.now().subtract(Duration(hours: 4)).toUtc().toIso8601String());
  var endTime = DateTime.parse(startTime.add(Duration(days: 2)).toUtc().subtract(Duration(hours: 4)).toIso8601String());

  var calEvents = calendar.events.list(calendarId, orderBy: "startTime", timeMin: startTime, singleEvents: true, timeMax: endTime);
  calEvents.then((Events events) async {
    events.items.forEach((Event event) {
    eventList.add(event.start.dateTime.subtract(Duration(hours: 4)).toIso8601String());
    eventList.add(event.end.dateTime.subtract(Duration(hours: 4)).toIso8601String());
    print('In getEventList auth');
    print(eventList);
    });
    await DatabaseService(uid: uid).updateUserEvents(userEmail, name, eventList);
  });
}
