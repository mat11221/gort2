//@dart=2.1
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gort/app_theme.dart';
import 'package:gort/gort_app_theme.dart';
import 'package:gort/ui/page_detail.dart';
import 'package:gort/ui/page_task.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'ui/globals.dart' as globals;
import 'package:http/http.dart' as http;
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();

//   print("Handling a background message: ${message.messageId}");
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await AwesomeNotifications().initialize(
    'resource://drawable/res_notification_app_icon',
    [
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        defaultColor: Colors.red,
        locked: true,
        importance: NotificationImportance.High,
        channelDescription: 'test',
      ),
    ],
  );

  bool isLoggedIn;
  MobileAds.instance.initialize();

  if (_currentUser == null) {
    isLoggedIn = false;
  } else {
    isLoggedIn = true;
    // final docRef = FirebaseFirestore.instance
    //     .collection('PayedUsers')
    //     .doc(FirebaseAuth.instance.currentUser.uid);
    // final docSnapshot = await docRef.get();

    // if (docSnapshot.exists) {
    //   // globals.payd = field;
    // }
  }

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {}
  });

  // getorcreateuser();
  if (_currentUser == null) {
    isLoggedIn = false;
  } else {
    isLoggedIn = true;
  }

  runApp(TaskistApp(
    isLoggedIn: isLoggedIn,
  ));
}

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  if (receivedAction.actionType == ActionType.SilentAction ||
      receivedAction.actionType == ActionType.SilentBackgroundAction) {
    // For background actions, you must hold the execution until the end
    // print(
    //     'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
    await executeLongTaskInBackground();
  } else {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification-page',
        (route) =>
            (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }
}

Future<void> executeLongTaskInBackground() async {
  print("starting long task");
  await Future.delayed(const Duration(seconds: 4));
  final url = Uri.parse("http://google.com");
  final re = await http.get(url);
  print(re.body);
  print("long task done");
}

// Future<User> getorcreateuser() async {
//   if (_currentUser == null) {
//     await _auth.signInAnonymously();
//   } else {
//     return _currentUser;
//   }
// }

final FirebaseAuth _auth = FirebaseAuth.instance;

// The navigator key is necessary to navigate using static methods
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

User get _currentUser => _auth.currentUser;
ReceivedAction initialAction;

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key key, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class TaskistApp extends StatelessWidget {
  final bool isLoggedIn;
  const TaskistApp({Key key, this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child),
      debugShowCheckedModeBanner: false,
      title: "Gört",
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomePage());

          case '/notification-page':
            final ReceivedAction receivedAction =
                settings.arguments as ReceivedAction;
            var payload = receivedAction.payload['gort'];
            return MaterialPageRoute(
                builder: (context) => DetailPage(
                      payload: payload.toString(),
                    ));

          default:
            assert(false, 'Page ${settings.name} not found');
            return null;
        }
      },
      // routes: {
      //   // When navigating to the "/second" route, build the SecondScreen widget.
      //   '/login': (context) => const LoginPage(),
      //   '/home': (context) => const HomePage(),
      // },
      //home: HomePage(
      //user: _currentUser,
      //),
      home: isLoggedIn ? HomePage(user: _currentUser) : const LoginPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
      ),
    );
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final taskpage = const TaskPage();

  final List<Widget> _children = [
    TaskPage(
      user: _currentUser,
    ),
    const DetailPage(),
    const DetailPage()
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        //forbidden swipe in iOS(my ThemeData(platform: TargetPlatform.iOS,)
        onWillPop: () async {
          if (Navigator.of(context).userGestureInProgress) {
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 26, 26, 26),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (int index) {
              setState(() {
                onTabTapped(index);
              });
            },
            currentIndex: _currentIndex,
            fixedColor: GortAppTheme.darkText,
            backgroundColor: GortAppTheme.background,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.house), label: "Gört"),
              BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.eye), label: ""),
              BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.instagram), label: "Inspiration"),
            ],
          ),
          body: _children[_currentIndex],
        ));
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    } else {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/notification-page',
          (route) =>
              (route.settings.name != '/notification-page') || route.isFirst,
          arguments: receivedAction);
    }
  }

  @override
  void initState() {
    startListeningNotificationEvents();
    super.initState();

    // AwesomeNotifications().actionStream.listen((notification) {
    //   if (notification.channelKey == 'scheduled_channel') {
    //     var payload = notification.payload['gort'];
    //     FirebaseFirestore.instance
    //         .collection(widget.user.uid)
    //         .doc(payload)
    //         .get()
    //         .then((value) => navigatorKey.currentState.push(PageRouteBuilder(
    //             pageBuilder: (_, __, ___) => DetailPage(
    //                   user: widget.user,
    //                   i: 0,
    //                   docname: payload,
    //                   color: value.data()['color'].toString(),
    //                   dayindex: value.data()['currentDayIndex'].toString(),
    //                   createdDate: int.parse((value.data()['date'].toString())),
    //                   documentId: value.data()['documentId'].toString(),
    //                   webimages:
    //                       List<String>.from(value.data()['webimagelist']),
    //                   webvideos:
    //                       List<String>.from(value.data()['webvideolist']),
    //                   week: value.data()['currentweek'].toString(),
    //                   allGottNames: [payload],
    //                   // gortActivitiyDaysCount: '2',
    //                   // gortActivitiyDaysDoneCount: '2',
    //                   // days: '2',
    //                   // streak: '2',
    //                   // record: '2',
    //                 ),
    //             transitionsBuilder:
    //                 (context, animation, secondaryAnimation, child) =>
    //                     ScaleTransition(
    //                       scale: Tween<double>(
    //                         begin: 1.5,
    //                         end: 1.0,
    //                       ).animate(
    //                         CurvedAnimation(
    //                           parent: animation,
    //                           curve: const Interval(
    //                             0.50,
    //                             1.00,
    //                             curve: Curves.linear,
    //                           ),
    //                         ),
    //                       ),
    //                       child: ScaleTransition(
    //                         scale: Tween<double>(
    //                           begin: 0.0,
    //                           end: 1.0,
    //                         ).animate(
    //                           CurvedAnimation(
    //                             parent: animation,
    //                             curve: const Interval(
    //                               0.00,
    //                               0.50,
    //                               curve: Curves.linear,
    //                             ),
    //                           ),
    //                         ),
    //                         child: child,
    //                       ),
    //                     ))));
    //   }
    // });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed && Platform.isIOS) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
      if (!isAllowed && Platform.isAndroid) {
        Dialogs.materialDialog(
            msg: 'Our app would like to send you notifications',
            title: "Allow Notifications",
            color: Colors.white,
            context: context,
            actions: [
              IconsOutlineButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: 'Don\'t Allow',
                iconData: Icons.cancel_outlined,
                textStyle: const TextStyle(color: Colors.grey),
                iconColor: Colors.grey,
              ),
              IconsOutlineButton(
                onPressed: () => AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then((_) => Navigator.pop(context)),
                text: 'Allow',
                iconData: Icons.check,
                color: Colors.green,
                textStyle: const TextStyle(color: Colors.white),
                iconColor: Colors.white,
              ),
            ]);
      }
    });
  }

  void _showStory() {}

  void onTabTapped(int index) {
    if (index == 1) {
      _showStory();
    } else {
      _currentIndex = index;
    }
  }
  // Dialogs.materialDialog(
  //     msg: '',
  //     title: "Remove all Notifications",
  //     color: Colors.white,
  //     context: context,
  //     actions: [
  //       IconsOutlineButton(
  //         onPressed: () {
  //           Navigator.pop(context);
  //         },
  //         text: 'No',
  //         iconData: Icons.cancel_outlined,
  //         textStyle: const TextStyle(color: Colors.grey),
  //         iconColor: Colors.grey,
  //       ),
  //       IconsOutlineButton(
  //         onPressed: () => AwesomeNotifications()
  //             .cancelAll()
  //             .then((_) => Navigator.pop(context)),
  //         text: 'Yes',
  //         iconData: Icons.check,
  //         color: Colors.green,
  //         textStyle: const TextStyle(color: Colors.white),
  //         iconColor: Colors.white,
  //       ),
  //     ]);
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  void dispose() {
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  String _email, _password;

  final kHintTextStyle = const TextStyle(
    color: Color.fromARGB(137, 133, 147, 255),
    fontFamily: 'OpenSans',
  );

  final kLabelStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );

  final kBoxDecorationStyle = BoxDecoration(
    color: const Color.fromARGB(255, 255, 255, 255),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Text(
        //   'Email',
        //   style: kLabelStyle,
        // ),
        // SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            onChanged: (value) => _email = value,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Color.fromARGB(255, 32, 105, 251),
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 1.0, left: 10),
              // prefixIcon: Icon(
              //   Icons.email,
              //   color: Colors.white,
              // ),
              hintText: 'Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Text(
        //   'Password',
        //   style: kLabelStyle,
        // ),
        // SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            onChanged: (value) => _password = value,
            obscureText: true,
            style: const TextStyle(
              color: Color.fromARGB(255, 37, 72, 247),
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 1.0, left: 10),
              // prefixIcon: Icon(
              //   Icons.lock,
              //   color: Colors.white,
              // ),
              hintText: 'Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        // elevation: 5.0,
        onPressed: () async {
          try {
            UserCredential result = await _auth.signInWithEmailAndPassword(
              email: _email,
              password: _password,
            );

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        user: result.user,
                      )),
            );
          } catch (e) {}
        },
        // padding: EdgeInsets.all(15.0),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(30.0),

        child: const Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildLoginBtnGuest() {
    return GestureDetector(
      onTap: () async {
        try {
          UserCredential result = await _auth.signInAnonymously();

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      user: result.user,
                    )),
          );
        } catch (e) {}
      },
      child: Container(
        height: 50.0,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(
                Icons.person,
                color: Colors.black54,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ]),
      ),
    );
  }

  Widget _buildSignInWithText() {
    return Column(
      children: const <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        // SizedBox(height: 20.0),
        // Text(
        //   'Sign in with',
        //   style: kLabelStyle,
        // ),
      ],
    );
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: () async {
        try {
          GoogleSignInAccount googleUser = await _googleSignIn.signIn();
          GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          UserCredential result = await _auth.signInWithCredential(credential);
          User user = result.user;
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      user: user,
                    )),
          );
        } catch (e) {}
      },
      child: Container(
        height: 50.0,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: logo,
                height: 35.0,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ]),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // _buildSocialBtn(
          //   () => print('Login with Facebook'),
          //   AssetImage(
          //     'assets/logos/facebook.jpg',
          //   ),
          // ),
          _buildSocialBtn(
            () => print('Login with Facebook'),
            const AssetImage(
              'assets/logos/google.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignUpPage(),
          )),
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: GortAppTheme.darkText,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: GortAppTheme.darkText,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(color: GortAppTheme.background
                    // gradient: LinearGradient(
                    //   begin: Alignment.topCenter,
                    //   end: Alignment.bottomCenter,
                    //   colors: [
                    //     Color(0xFF73AEF5),
                    //     Color(0xFF61A4F1),
                    //     Color(0xFF478DE0),
                    //     Color(0xFF398AE5),
                    //   ],
                    //   stops: [0.1, 0.4, 0.7, 0.9],
                    // ),
                    ),
              ),
              SizedBox(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0.0,
                      vertical: 120.0,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Gört',
                            style: TextStyle(
                              color: GortAppTheme.darkText,
                              fontFamily: 'OpenSans',
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          // _buildEmailTF(),
                          // const SizedBox(
                          //   height: 30.0,
                          // ),
                          // _buildPasswordTF(),
                          // _buildLoginBtn(),
                          // _buildSignInWithText(),
                          // _buildSocialBtnRow(),
                          _buildLoginBtnGuest(),
                          const SizedBox(
                            height: 30,
                          ),
                          // _buildSignupBtn(),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//       ),
//       body: Column(
//         children: <Widget>[
//           TextField(
//             onChanged: (value) => _email = value,
//             decoration: InputDecoration(
//               hintText: 'Email',
//             ),
//           ),
//           TextField(
//             onChanged: (value) => _password = value,
//             decoration: InputDecoration(
//               hintText: 'Password',
//             ),
//             obscureText: true,
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 UserCredential result = await _auth.signInWithEmailAndPassword(
//                   email: _email,
//                   password: _password,
//                 );
//                 User? user = result.user;
//                 Navigator.pushReplacementNamed(context, '/home');
//               } catch (e) {
//                 print(e);
//               }
//             },
//             child: Text('Login'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//                 GoogleSignInAuthentication googleAuth =
//                     await googleUser!.authentication;
//                 final AuthCredential credential = GoogleAuthProvider.credential(
//                   accessToken: googleAuth.accessToken,
//                   idToken: googleAuth.idToken,
//                 );
//                 UserCredential result =
//                     await _auth.signInWithCredential(credential);
//                 User? user = result.user;
//                 Navigator.pushReplacementNamed(context, '/home');
//               } catch (e) {
//                 print(e);
//               }
//             },
//             child: Text('Login with Google'),
//           ),
//         ],
//       ),
//     );
//   }

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key key}) : super(key: key);

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  String _username, _email, _password;

  final kHintTextStyle = const TextStyle(
    color: Color.fromARGB(137, 133, 147, 255),
    fontFamily: 'OpenSans',
  );

  final kLabelStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );

  final kBoxDecorationStyle = BoxDecoration(
    color: const Color.fromARGB(255, 255, 255, 255),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  Widget _buildUsernameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Text(
        //   'Email',
        //   style: kLabelStyle,
        // ),
        // SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            onChanged: (value) => _username = value,
            keyboardType: TextInputType.name,
            style: const TextStyle(
              color: Color.fromARGB(255, 32, 105, 251),
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 1.0, left: 10),
              // prefixIcon: Icon(
              //   Icons.email,
              //   color: Colors.white,
              // ),
              hintText: 'Name',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Text(
        //   'Email',
        //   style: kLabelStyle,
        // ),
        // SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            onChanged: (value) => _email = value,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Color.fromARGB(255, 32, 105, 251),
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 1.0, left: 10),
              // prefixIcon: Icon(
              //   Icons.email,
              //   color: Colors.white,
              // ),
              hintText: 'Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Text(
        //   'Password',
        //   style: kLabelStyle,
        // ),
        // SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            onChanged: (value) => _password = value,
            obscureText: true,
            style: const TextStyle(
              color: Color.fromARGB(255, 37, 72, 247),
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 1.0, left: 10),
              // prefixIcon: Icon(
              //   Icons.lock,
              //   color: Colors.white,
              // ),
              hintText: 'Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        // elevation: 5.0,
        onPressed: () async {
          try {
            UserCredential result = await _auth.createUserWithEmailAndPassword(
              email: _email,
              password: _password,
            );
            User user = result.user;
            user.updateDisplayName(_username);

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage(user: user)),
            );
          } catch (e) {}
        },
        // padding: EdgeInsets.all(15.0),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(30.0),

        child: const Text(
          'SIGN UP',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => Navigator.pop(
        context,
      ),
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Already have an Account? ',
              style: TextStyle(
                color: GortAppTheme.darkText,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Log in',
              style: TextStyle(
                color: GortAppTheme.darkText,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(color: GortAppTheme.background
                    // gradient: LinearGradient(
                    //   begin: Alignment.topCenter,
                    //   end: Alignment.bottomCenter,
                    //   colors: [
                    //     Color(0xFF73AEF5),
                    //     Color(0xFF61A4F1),
                    //     Color(0xFF478DE0),
                    //     Color(0xFF398AE5),
                    //   ],
                    //   stops: [0.1, 0.4, 0.7, 0.9],
                    // ),
                    ),
              ),
              SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: GortAppTheme.darkText,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      _buildUsernameTF(),
                      const SizedBox(
                        height: 30.0,
                      ),
                      _buildEmailTF(),
                      const SizedBox(
                        height: 30.0,
                      ),
                      _buildPasswordTF(),
                      _buildLoginBtn(),
                      _buildSignupBtn()
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
}
