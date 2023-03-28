//@dart=2.1

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gort/gort_app_theme.dart';
import 'package:gort/model/element.dart';
import 'package:gort/ui/page_detail.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:popup_banner/popup_banner.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'page_addlist.dart';
import 'dart:io' show Platform;
import 'globals.dart' as globals;
import 'package:purchases_flutter/purchases_flutter.dart' as purchases;

class TaskPage extends StatefulWidget {
  final User user;
  const TaskPage({Key key, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  String directory;
  List filelist = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GortAppTheme.background,
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            // ),
            FloatingActionButton(
              backgroundColor: GortAppTheme.darkText,
              onPressed: () => _addTaskPressed(),
              heroTag: null,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          ])),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Text(
                                'Title!',
                                style: TextStyle(
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: GortAppTheme.fontName,
                                    color: GortAppTheme.darkText),
                              ),
                              // const SizedBox(
                              //   width: 40,
                              // )
                              // SizedBox(
                              //   width: 40,
                              // )
                            ],
                          )),
                    ],
                  )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Container(
              height: 600.0,
              padding: const EdgeInsets.only(bottom: 25.0),
              child: NotificationListener<OverscrollIndicatorNotification>(
                // ignore: missing_return
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                },
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(widget.user.uid)
                        .orderBy("date", descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                        ));
                      }
                      if (snapshot.hasData && snapshot.data.docs.isEmpty) {
                        return Center(
                            child: Column(
                          children: [
                            const Padding(
                                padding: EdgeInsets.only(top: 50.0),
                                child: Text('! Means do it!',
                                    style: GortAppTheme.caption)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0, left: 70, right: 70),
                              child: Column(
                                children: const <Widget>[
                                  Text(
                                    ' is a project where you visualize a goal, something that you definitely will achieve',
                                    style: GortAppTheme.caption,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.only(
                                    top: 100.0, left: 70, right: 70),
                                child: Text(
                                  'No  is available',
                                  style: GortAppTheme.caption,
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 30.0, left: 20, right: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Press  ',
                                      style: GortAppTheme.caption,
                                    ),
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: GortAppTheme.darkText,
                                        ),
                                        height: 34,
                                        width: 34,
                                        child: const Icon(
                                          Icons.add,
                                          size: 15,
                                          color: Colors.white,
                                        )),
                                    const Text(
                                      '  to create a new ',
                                      style: GortAppTheme.caption,
                                    )
                                  ],
                                )),
                          ],
                        ));
                      }
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        scrollDirection: Axis.vertical,
                        children: getExpenseItems(snapshot),
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<dynamic> activities = [];
    List<int> gortActivitiyDaysDoneCount = [];
    List<int> gortActivitiyDaysCount = [];
    List<dynamic> activitiesdone = [];

    List<ElementTask> listElement = [], listElement2;
    Map<String, List<ElementTask>> userMap = {};
    List<String> docName = [];
    List<String> imageurl = [];
    List<String> cardColor = [];
    List<String> dayIndex = [];
    List<int> createdDate = [];
    List<String> documentId = [];
    List<String> currentweek = [];
    List<String> activitycount = [];
    List<dynamic> webimages = [];
    List<dynamic> webvideos = [];
    List<dynamic> actdayslist = [];
    List<dynamic> actdaysdonelist = [];
    List<bool> endDate = [];
    List<String> streak = [];
    List<String> record = [];

    List<String> freq = [];
    Map<dynamic, dynamic> dataMap = {};

    if (widget.user.uid.isNotEmpty) {
      imageurl.clear();
      docName.clear();
      cardColor.clear();
      dayIndex.clear();
      createdDate.clear();
      documentId.clear();
      activitycount.clear();
      actdayslist.clear();
      actdaysdonelist.clear();
      webimages.clear();
      currentweek.clear();
      webvideos.clear();
      globals.storyimages.clear();
      endDate.clear();
      streak.clear();
      record.clear();

      /// Hold Temporary Activity Days Count
      int activityDaysGortCount = 0;
      int activityDaysDoneGortCount = 0;
      snapshot.data.docs.map<List>((f) {
        String imgurl;
        String name;
        String color;
        String currentDayIndex;
        int created;
        String docid;
        String week;
        String actcount;
        String actdays;
        String actdaysdone;
        List<String> webimg = [];
        List<String> webvd = [];
        bool endD;
        String str;
        String rec;

        // if (snapshot.data[widget.user.user.uid + 'settings']) {
        //   FirebaseFirestore.instance
        //       .collection(widget.user.user.uid)
        //       .doc(widget.user.user.uid + 'settings')
        //       .set({
        //     'weeknumber': DateTime.now().weekOfYear.toString(),
        //     'paid': false
        //   });
        // }

        Map<String, dynamic> data = f.data() as Map<String, dynamic>;
        data.forEach((a, b) {
          /// Reset _activityDaysGortCount back to zero
          activityDaysGortCount = 0;
          activityDaysDoneGortCount = 0;
          name = f.id;
          if (b.runtimeType == bool) {
            listElement.add(ElementTask(a, b));
            freq.add("${a}freq");
          } else {
            dataMap[a] = [b];
          }
          if (b is String && a == "color") {
            color = b;
          }
          if (b is String && a == "currentDayIndex") {
            currentDayIndex = b;
          }
          if (b is int && a == "date") {
            created = b;
          }
          if (b is String && a == "documentId") {
            docid = b;
          }
          if (b is String && a == "currentweek") {
            week = b;
          }
          if (b is String && a == "imageurl") {
            imgurl = b;
          }
          if (b is String && a == "endDate") {
            if (b == "true") {
              endD = true;
            } else {
              endD = false;
            }
          }
          if (b is String && a == "streak") {
            str = b;
          }

          if (b is String && a == "record") {
            rec = b;
          }
          if (a == "activities") {
            for (var element in (data['activities'] as List)) {
              activityDaysDoneGortCount += (element['daysdone'] as List).length;
              activityDaysGortCount += (element['days'] as List).length;
              activities.add(element['days']);
              activitiesdone.add(element['daysdone']);
            }

            /// Now ad `_activityDaysGortCount` int value to `gortActivitiyDaysCount` list
            gortActivitiyDaysCount.add(activityDaysGortCount);
            gortActivitiyDaysDoneCount.add(activityDaysDoneGortCount);
          }
          if (a == "webimagelist") {
            for (var element in (data['webimagelist'] as List)) {
              webimg.add((element.toString()));
              globals.storyimages.add(element.toString());
            }
          }
          if (a == "webvideolist") {
            for (var element in (data['webvideolist'] as List)) {
              webvd.add((element.toString()));
            }
          }
        });
        listElement2 = List<ElementTask>.from(listElement);
        for (int i = 0; i < listElement2.length; i++) {
          if (listElement2.elementAt(i).isDone == false) {
            userMap[f.id] = listElement2;
            docName.add(name);
            cardColor.add(color);
            dayIndex.add(currentDayIndex);
            createdDate.add(created);
            documentId.add(docid);
            activitycount.add(actcount);
            actdayslist.add(actdays);
            actdaysdonelist.add(actdaysdone);
            webimages.add(webimg);
            webvideos.add(webvd);
            currentweek.add(week);
            imageurl.add(imgurl);
            endDate.add(endD);
            streak.add(str);
            record.add(rec);
            break;
          }
        }
        if (listElement2.isEmpty) {
          userMap[f.id] = listElement2;
          docName.add(name);
          cardColor.add(color);
          dayIndex.add(currentDayIndex);
          createdDate.add(created);
          documentId.add(docid);
          activitycount.add(actcount);
          actdayslist.add(actdays);
          actdaysdonelist.add(actdaysdone);
          webimages.add(webimg);
          webvideos.add(webvd);
          currentweek.add(week);
          imageurl.add(imgurl);
          endDate.add(endD);
          streak.add(str);
          record.add(rec);
        }
        listElement.clear();
        globals.totalgort = cardColor.length;
        return null;
      }).toList();

      // if (isSaving) {
      //   dataMap.forEach((key, value) {
      //     for (int i = 0; i < freq.length; i++) {
      //       if (key == freq[i]) {
      //         frequencies.add(int.parse(value[0]));
      //       }
      //     }
      //   });
      // }
      // isSaving = false;

      return List<Widget>.generate(userMap.length, (int index) {
        return GestureDetector(
          onTap: () {
            print(docName);
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => DetailPage(
                  user: widget.user,
                  i: index,
                  docname: docName.elementAt(index),
                  color: cardColor.elementAt(index),
                  dayindex: dayIndex.elementAt(index),
                  createdDate: createdDate.elementAt(index),
                  documentId: documentId.elementAt(index),
                  webimages: webimages.elementAt(index),
                  webvideos: webvideos.elementAt(index),
                  week: currentweek.elementAt(index),
                  gortActivitiyDaysCount:
                      gortActivitiyDaysCount.elementAt(index).toString(),
                  gortActivitiyDaysDoneCount:
                      gortActivitiyDaysDoneCount.elementAt(index).toString(),
                  endDate: endDate.elementAt(index),
                  streak: streak.elementAt(index),
                  record: record.elementAt(index),
                  allGottNames: docName,
                ),
                transitionsBuilder:
                    (_, Animation<double> animation, __, child) =>
                        ScaleTransition(
                  scale: Tween<double>(begin: 1.5, end: 1.0)
                      .animate(CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.50, 1.00, curve: Curves.linear),
                  )),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.00, 0.50, curve: Curves.linear),
                      ),
                    ),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: Card(
            color: Color(int.parse(cardColor.elementAt(index))),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Container(
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   // Where the linear gradient begins and ends
                //   begin: Alignment.topRight,
                //   end: Alignment.bottomLeft,
                // Add one stop for each color. Stops should increase from 0 to 1
                // stops: const [0.3, 0.5, 0.7, 0.9],
                color: Color(
                  int.parse(cardColor.elementAt(index)),
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: GortAppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 2, left: 16, right: 2),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 4),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    // Container(
                                    //   height: 48,
                                    //   width: 2,
                                    //   decoration: BoxDecoration(
                                    //     color: GortAppTheme.nearlyWhite
                                    //         .withOpacity(0.5),
                                    //     borderRadius: const BorderRadius.all(
                                    //         Radius.circular(4.0)),
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        docName
                                            .elementAt(index)
                                            .replaceAll('ô', '/'),
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          fontFamily: GortAppTheme.fontName,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                          letterSpacing: 1.2,
                                          color: GortAppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4, bottom: 2),
                                            child: Text(
                                              endDate.elementAt(index) == true
                                                  ? dayIndex.elementAt(index)
                                                  : ' ',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontFamily:
                                                    GortAppTheme.fontName,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                letterSpacing: -0.1,
                                                color: GortAppTheme.nearlyWhite,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4, bottom: 3),
                                                child: gortActivitiyDaysCount[
                                                            index] ==
                                                        0
                                                    ? const Text(
                                                        '0 activities this week',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              GortAppTheme
                                                                  .fontName,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          letterSpacing: -0.2,
                                                          color: GortAppTheme
                                                              .nearlyWhite,
                                                        ),
                                                      )
                                                    : Text(
                                                        '${gortActivitiyDaysDoneCount[index]}/${gortActivitiyDaysCount[index]} activities this week',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              GortAppTheme
                                                                  .fontName,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          letterSpacing: -0.2,
                                                          color: GortAppTheme
                                                              .nearlyWhite,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              children: [
                                CircularPercentIndicator(
                                    radius: 40.0,
                                    animation: true,
                                    animationDuration: 1200,
                                    lineWidth: 10.0,
                                    percent: int.parse(
                                                record.elementAt(index)) <
                                            int.parse(streak.elementAt(index))
                                        ? 1
                                        : (int.parse(streak.elementAt(index)) /
                                            (int.parse(
                                                record.elementAt(index)))),
                                    center: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          streak.elementAt(index),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26.0),
                                        ),
                                        const Text(
                                          "Streak",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12.0),
                                        ),
                                      ],
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    backgroundColor: const Color.fromARGB(
                                        255, 228, 228, 228),
                                    progressColor:
                                        const Color.fromARGB(255, 241, 76, 76)),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  int.parse(record.elementAt(index)) >
                                          int.parse(streak.elementAt(index))
                                      ? 'Record: ${record.elementAt(index)}'
                                      : 'Record: ${streak.elementAt(index)}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                  )
                ],
              ),
            ),
          ),
        );
      });
    }
    return <Widget>[];
  }

  showDefaultPopup(List<String> img) {
    PopupBanner(
      context: context,
      images: img,
      onClick: (index) {
        debugPrint("CLICKED $index");
      },
    ).show();
  }

  int countElements(List<dynamic> list) {
    int count = 0;
    for (var element in list) {
      if (element is List) {
        count += countElements(element);
      } else {
        count++;
      }
    }
    return count;
  }

  Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex =
          '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  changePayment() {
    FirebaseFirestore.instance
        .collection('PayedUsers')
        .doc(widget.user.uid)
        .set({"payd": true});
    globals.payd = true;
  }

  void _addTaskPressed() async {
    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NewTaskPage(
          user: widget.user,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            ScaleTransition(
          scale: Tween<double>(
            begin: 1.5,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(
                0.50,
                1.00,
                curve: Curves.linear,
              ),
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(
                  0.00,
                  0.50,
                  curve: Curves.linear,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
    //Navigator.of(context).pushNamed('/new');
  }
}
