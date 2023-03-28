//@dart=2.1

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:video_compress/video_compress.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:gort/utils/color_picker.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gort/gort_app_theme.dart';
import 'package:gort/ui/notification.dart';
import 'package:gort/ui/utilities.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:gort/model/element.dart';
import 'package:gort/ui/page_activity.dart';
import 'package:gort/ui/video.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as pt;
import 'globals.dart' as globals;

class DetailPage extends StatefulWidget {
  final int i;
  final String week;
  final String days;
  final String color;
  final String docname;
  final String dayindex;
  final int createdDate;
  final String documentId;
  final User user;
  final List<String> webimages;
  final List<String> webvideos;
  final String gortActivitiyDaysCount;
  final String gortActivitiyDaysDoneCount;
  final bool endDate;
  final String streak;
  final String record;
  final List<String> allGottNames;
  final String payload;

  const DetailPage(
      {Key key,
      this.i,
      this.week,
      this.days,
      this.color,
      this.docname,
      this.dayindex,
      this.createdDate,
      this.documentId,
      this.user,
      this.webimages,
      this.webvideos,
      this.gortActivitiyDaysCount,
      this.gortActivitiyDaysDoneCount,
      this.endDate,
      this.streak,
      this.record,
      this.allGottNames,
      this.payload})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController itemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: PieCanvas(
          theme: const PieTheme(
            pointerSize: 0,
            delayDuration: Duration.zero,
          ),
          child: Scaffold(
              body: Container(
            decoration: BoxDecoration(
                color:
                    !newweek == true ? currentColor : GortAppTheme.background),
            child: Column(
              children: [
                NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return null;
                  },
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection(currentuser.uid)
                        .snapshots(),
                    builder: (
                      _,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot,
                    ) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: currentColor,
                          ),
                        );
                      }
                      return getExpenseItems(snapshot);
                    },
                  ),
                ),
              ],
            ),
          ))),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool showcontent = true;
  bool showsettings = false;
  List<Activity> newactivities = [];
  int totalDaysGortCount = 0;
  int totalDaysDoneGortCount = 0;

  getExpenseItems(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    List<Activity> activities = [];
    List<String> gortdocnames = [];
    int activityDaysGortCount = 0;
    int activityDaysDoneGortCount = 0;
    if (currentuser != null) {
      // ignore: missing_return
      snapshot.data.docs.map<Widget>((f) {
        if (f.id == documentName) {
          f.data().forEach((String a, dynamic b) {
            if (a == "activities") {
              for (var element in (f.data()['activities'] as List)) {
                activityDaysDoneGortCount +=
                    (element['daysdone'] as List).length;
                activityDaysGortCount += (element['days'] as List).length;

                activities.add(
                  Activity(
                    id: f.id,
                    time: element['time'],
                    title: element['title'],
                    notificationidnumber: element['notificationidnumber'],
                    timelist: List<String>.from(element['timelist']),
                    daylist: List<String>.from(element['days']),
                    daylistdone: List<String>.from(element['daysdone']),
                    weekdaysdone: List<Timestamp>.from(element['weekdaysdone']),
                    weekdaysnotdone:
                        List<Timestamp>.from(element['weekdaysnotdone']),
                  ),
                );

                newactivities = activities;
                totalDaysGortCount = activityDaysGortCount;
                totalDaysDoneGortCount = activityDaysDoneGortCount;
              }
            }
          });
        }
      }).toList();

      return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: ListView(
                shrinkWrap: true,
                children: [
                  Visibility(
                      visible: newweek,
                      child: Column(
                        children: [
                          _getToolbar2(context),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            'VECKA AVKLARAD',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            color: GortAppTheme.darkText,
                            height: 1,
                            width: MediaQuery.of(context).size.width * 0.7,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            'Checka av veckan och fortsätt',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            height: 40,
                          )
                        ],
                      )),
                  Visibility(
                      visible: !newweek,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: _getToolbar(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 0.0, left: 20.0, right: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Text(
                                    documentName,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                        color: GortAppTheme.darkText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(
                                  top: 5.0, left: 30.0, right: 30.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Text(
                                      endDate == true
                                          ? currentDayIndex.toString()
                                          : ' ',
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                          color: GortAppTheme.darkText,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18.0),
                                    ),
                                  ),
                                ],
                              )),
                          Visibility(
                              visible: showcontent,
                              child: activities.isNotEmpty
                                  ? Visibility(
                                      visible: !newweek,
                                      child: Column(children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6),
                                            child: CircularPercentIndicator(
                                                radius: 30.0,
                                                animation: true,
                                                animationDuration: 1200,
                                                lineWidth: 6.0,
                                                percent:
                                                    totalDaysDoneGortCount /
                                                        totalDaysGortCount,
                                                center: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      totalDaysDoneGortCount
                                                          .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20.0),
                                                    ),
                                                  ],
                                                ),
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 228, 228, 228),
                                                progressColor:
                                                    const Color.fromARGB(
                                                        255, 241, 76, 76))),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Text(
                                            'Potential Streak',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 10),
                                          ),
                                        )
                                      ]))
                                  : Container()),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Column(
                              children: <Widget>[
                                activities.isEmpty
                                    ? Visibility(
                                        visible: showcontent,
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5.0,
                                              left: 40.0,
                                              right: 40.0,
                                            ),
                                            child: Column(
                                              children: const [
                                                SizedBox(
                                                  height: 40,
                                                ),
                                                Text(
                                                    'No activities created yet',
                                                    style: TextStyle(
                                                        fontSize: 20)),
                                                SizedBox(
                                                  height: 50,
                                                ),
                                                Text(
                                                  'Create activities that help you achieve your Gört!',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: 40,
                                                ),
                                                Text(
                                                  'Get reminders and visualize yourself to success!',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            )),
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                          Visibility(
                              visible: showsettings,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 40.0, left: 30.0, right: 30.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: const [
                                            Text(
                                              'Background color',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        EasyColorPicker(
                                          selected: currentColor,
                                          colorSelectorSize: 40,
                                          colorSelectorBorderRadius: 20,
                                          onChanged: (color) => setState(
                                              () => changeColor(color)),
                                          key: null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  Row(
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 5.0,
                                            left: 30.0,
                                            right: 30.0,
                                            bottom: 10),
                                        child: Text(
                                          'Target date',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _selectDate(context);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      decoration: BoxDecoration(
                                          color: endDate == true
                                              ? Colors.white
                                              : const Color.fromARGB(
                                                  139, 174, 174, 174),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_selectedDate,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 0, 0, 0))),
                                              Switch(
                                                value: endDate,
                                                onChanged: (value) {
                                                  setState(() {
                                                    endDate = value;
                                                    changeEndDate(
                                                        value.toString());
                                                  });
                                                },
                                                activeTrackColor:
                                                    Colors.lightGreenAccent,
                                                activeColor: Colors.green,
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          top: 40.0,
                                          left: 30.0,
                                          right: 30.0,
                                          bottom: 10),
                                      child: Row(
                                        children: const [
                                          Text(
                                            'Visualize your Gört success',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87),
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      )),
                                  SizedBox(
                                      height: 100,
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            children: [
                                              webvideos.isEmpty &&
                                                      webimages.isEmpty
                                                  ? Container()
                                                  : SizedBox(
                                                      height: 200,
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: ListView(
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            children: [
                                                              ListView.builder(
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                shrinkWrap:
                                                                    true,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            ctx,
                                                                        int index) {
                                                                  return SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.2,
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          Card(
                                                                            elevation:
                                                                                0,
                                                                            color:
                                                                                Colors.transparent,
                                                                            surfaceTintColor:
                                                                                Colors.transparent,
                                                                            margin:
                                                                                const EdgeInsets.all(10),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            ),
                                                                            child:
                                                                                Align(
                                                                              alignment: Alignment.center,
                                                                              child: Container(
                                                                                clipBehavior: Clip.antiAlias,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.transparent,
                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                ),
                                                                                child: Image.network(
                                                                                  webimages[index],
                                                                                  fit: BoxFit.contain,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                              onPressed: () {
                                                                                setState(() {
                                                                                  webimages.removeAt(index);
                                                                                });
                                                                              },
                                                                              icon: const Icon(Icons.delete))
                                                                        ],
                                                                      ));
                                                                },
                                                                itemCount:
                                                                    webimages
                                                                        .length,
                                                              ),
                                                              ListView.builder(
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                shrinkWrap:
                                                                    true,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            ctx,
                                                                        int index) {
                                                                  return SizedBox(
                                                                      height:
                                                                          200,
                                                                      width:
                                                                          200,
                                                                      child: VideoPlay(
                                                                          pathh:
                                                                              webvideos[index]));
                                                                },
                                                                itemCount:
                                                                    webvideos
                                                                        .length,
                                                              )
                                                            ],
                                                          ))),
                                              ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (BuildContext ctx,
                                                    int index) {
                                                  return SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      child: Stack(
                                                        children: [
                                                          Card(
                                                            elevation: 0,
                                                            color: Colors
                                                                .transparent,
                                                            surfaceTintColor:
                                                                Colors
                                                                    .transparent,
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Container(
                                                                clipBehavior: Clip
                                                                    .antiAlias,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .transparent,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                child:
                                                                    Image.file(
                                                                  File(imageFileListM[
                                                                          index]
                                                                      .path),
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  imageFileListM
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                  Icons.delete))
                                                        ],
                                                      ));
                                                },
                                                itemCount:
                                                    imageFileListM.length,
                                              ),
                                              ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (BuildContext ctx,
                                                    int index) {
                                                  return SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      child: Card(
                                                        elevation: 0,
                                                        color:
                                                            Colors.transparent,
                                                        surfaceTintColor:
                                                            Colors.transparent,
                                                        margin: const EdgeInsets
                                                            .all(10),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Container(
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child:
                                                                Image.network(
                                                              newwebimages[
                                                                  index],
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        ),
                                                      ));
                                                },
                                                itemCount: newwebimages.length,
                                              ),
                                              ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemBuilder: (BuildContext ctx,
                                                    int index) {
                                                  return SizedBox(
                                                      height: 100,
                                                      width: 100,
                                                      child: VideoFilePlay(
                                                        pathh: File(
                                                            videoFileListM[
                                                                    index]
                                                                .path),
                                                      ));
                                                },
                                                itemCount:
                                                    videoFileListM.length,
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Center(
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: PieMenu(
                                                        actions: [
                                                          PieAction(
                                                            tooltip: 'Photo',
                                                            onSelect: () {
                                                              selectImages();
                                                            },
                                                            child: const Icon(
                                                                Icons.photo),
                                                          ),
                                                          PieAction(
                                                            buttonTheme: const PieButtonTheme(
                                                                backgroundColor:
                                                                    Colors.red,
                                                                iconColor:
                                                                    Colors
                                                                        .white),
                                                            tooltip: 'Video',
                                                            onSelect: () {
                                                              selectVideo();
                                                            },
                                                            child: const Icon(
                                                              Icons
                                                                  .video_camera_back,
                                                            ),
                                                          ),
                                                          PieAction(
                                                            buttonTheme: const PieButtonTheme(
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                iconColor:
                                                                    Colors
                                                                        .white),
                                                            tooltip: 'Search',
                                                            onSelect: () {
                                                              _navigateAndDisplaySelection(
                                                                  context);
                                                            },
                                                            child: const Icon(
                                                              Icons.search,
                                                            ),
                                                          ),
                                                          PieAction(
                                                            buttonTheme: const PieButtonTheme(
                                                                backgroundColor:
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            244,
                                                                            144,
                                                                            15),
                                                                iconColor:
                                                                    Colors
                                                                        .white),
                                                            tooltip:
                                                                'Search AI',
                                                            onSelect: () {
                                                              _navigateAndDisplaySelectionai(
                                                                  context);
                                                            },
                                                            child: const Icon(
                                                              Icons.search_off,
                                                            ),
                                                          ),
                                                        ],
                                                        child: const Icon(
                                                          Icons.add_a_photo,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                            ],
                                          ))),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 40.0,
                                        left: 30.0,
                                        right: 30.0,
                                        bottom: 10),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Dialogs.materialDialog(
                                              msg:
                                                  'Are you sure? You can\'t undo this',
                                              title: "Delete Gört",
                                              msgStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      GortAppTheme.fontName,
                                                  color: Colors.black54),
                                              titleStyle: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  fontFamily:
                                                      GortAppTheme.fontName,
                                                  color: Colors.black),
                                              color: Colors.white,
                                              context: context,
                                              actions: [
                                                IconsOutlineButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  text: 'Cancel',
                                                  textStyle: const TextStyle(
                                                      fontFamily:
                                                          GortAppTheme.fontName,
                                                      color: Colors.grey),
                                                  iconColor: Colors.grey,
                                                ),
                                                IconsOutlineButton(
                                                  onPressed: () {
                                                    if (globals.totalgort ==
                                                        1) {
                                                      globals.totalgort = 0;
                                                    }
                                                    for (var ac in activities) {
                                                      cancelAllGroupScheduledNotifications(
                                                          documentName +
                                                              ac.title);
                                                    }
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            currentuser.uid)
                                                        .doc(documentName)
                                                        .delete();
                                                    Navigator.pop(context);
                                                    Navigator.of(context).pop();
                                                  },
                                                  text: 'Delete',
                                                  color: Colors.red,
                                                  textStyle: const TextStyle(
                                                      color: Colors.white),
                                                  iconColor: Colors.white,
                                                ),
                                              ]);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          elevation: 15.0,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(15.0),
                                          child: Text(
                                            'Delete Gört',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      )),
                  Visibility(
                    visible: showcontent,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: <Widget>[
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: activities.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (_, int i) {
                              return Slidable(
                                  key: const ValueKey(0),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) async {
                                          var showNewGort = false;
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    backgroundColor:
                                                        GortAppTheme.background,
                                                    title: const Center(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          'Copy activity',
                                                          style: TextStyle(
                                                              color: GortAppTheme
                                                                  .darkText),
                                                        ),
                                                      ),
                                                    ),
                                                    content: StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setState) {
                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Visibility(
                                                            visible:
                                                                !showNewGort,
                                                            child: Container(
                                                              color: GortAppTheme
                                                                  .background,
                                                              height:
                                                                  300.0, // Change as per your requirement
                                                              width:
                                                                  300.0, // Change as per your requirement
                                                              child: ListView
                                                                  .builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    allGortNames
                                                                        .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  return ListTile(
                                                                    onTap: () {
                                                                      var arr =
                                                                          activities;

                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(currentuser
                                                                              .uid)
                                                                          .doc(allGortNames
                                                                              .elementAt(index))
                                                                          .update({
                                                                        "activities":
                                                                            FieldValue.arrayUnion([
                                                                          {
                                                                            'title':
                                                                                arr[i].title,
                                                                            'days':
                                                                                arr[i].daylist,
                                                                            'notificationidnumber':
                                                                                arr[i].notificationidnumber,
                                                                            'daysdone':
                                                                                arr[i].daylistdone,
                                                                            'timelist':
                                                                                arr[i].timelist,
                                                                            'weekdaysdone':
                                                                                arr[i].weekdaysdone,
                                                                            'weekdaysnotdone':
                                                                                arr[i].weekdaysnotdone,
                                                                            'time':
                                                                                arr[i].time
                                                                          }
                                                                        ]),
                                                                      });

                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    title: Card(
                                                                        child: Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child: Text(allGortNames.elementAt(index)))),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          Visibility(
                                                              visible:
                                                                  showNewGort,
                                                              child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 20.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          20.0),
                                                                  child: Column(
                                                                      children: <
                                                                          Widget>[
                                                                        Row(
                                                                          children: const [
                                                                            Text(
                                                                              'Title',
                                                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        TextFormField(
                                                                          decoration: InputDecoration(
                                                                              fillColor: Colors.black,
                                                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Colors.teal)),
                                                                              labelText: "Gört name",
                                                                              // errorText: _validate
                                                                              //     ? 'Value Can\'t Be Empty'
                                                                              //     : null,
                                                                              contentPadding: const EdgeInsets.only(left: 16.0, top: 20.0, right: 16.0, bottom: 5.0)),
                                                                          controller:
                                                                              listNameController,
                                                                          autofocus:
                                                                              false,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                22.0,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                          keyboardType:
                                                                              TextInputType.text,
                                                                          textCapitalization:
                                                                              TextCapitalization.sentences,
                                                                          maxLength:
                                                                              20,
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              15,
                                                                        ),
                                                                      ]))),
                                                          Visibility(
                                                            visible:
                                                                !showNewGort,
                                                            child: ListTile(
                                                              onTap: () async {
                                                                CustomerInfo
                                                                    customerInfo =
                                                                    await Purchases
                                                                        .getCustomerInfo();
                                                                if (customerInfo.entitlements.all[
                                                                            'premium_1m'] !=
                                                                        null &&
                                                                    customerInfo
                                                                            .entitlements
                                                                            .all['premium_1m']
                                                                            .isActive ==
                                                                        true) {
                                                                  setState(() {
                                                                    showNewGort =
                                                                        true;
                                                                  });
                                                                } else {
                                                                  if (!mounted)
                                                                    return;
                                                                  showGeneralDialog(
                                                                      context:
                                                                          context,
                                                                      barrierColor:
                                                                          GortAppTheme
                                                                              .background,
                                                                      barrierDismissible:
                                                                          false,
                                                                      barrierLabel:
                                                                          'Dialog',
                                                                      transitionDuration:
                                                                          const Duration(
                                                                              milliseconds:
                                                                                  400),
                                                                      pageBuilder: (_,
                                                                          __,
                                                                          ___) {
                                                                        return Scaffold(
                                                                            body:
                                                                                Column(
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 60, left: 15),
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: Row(
                                                                                  children: const [
                                                                                    Icon(
                                                                                      Icons.close,
                                                                                      size: 40.0,
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            const Text(
                                                                              'GET PREMIUM',
                                                                              style: TextStyle(fontSize: 20),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Container(
                                                                              color: GortAppTheme.darkText,
                                                                              height: 1,
                                                                              width: MediaQuery.of(context).size.width * 0.7,
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            const Text(
                                                                              'Remove ads',
                                                                              style: TextStyle(fontSize: 20),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 25,
                                                                            ),
                                                                            const Text(
                                                                              'Unlimited Görts',
                                                                              style: TextStyle(fontSize: 20),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            const Icon(
                                                                              Icons.payment_rounded,
                                                                              size: 100,
                                                                              color: GortAppTheme.darkText,
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 20,
                                                                            ),
                                                                            const Text(
                                                                              '19kr/Månad',
                                                                              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            Expanded(
                                                                                child: Align(
                                                                              alignment: Alignment.bottomCenter,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(top: 50.0, bottom: 40),
                                                                                child: SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 0.7,
                                                                                  child: ElevatedButton(
                                                                                    onPressed: () async {
                                                                                      try {
                                                                                        CustomerInfo customerInfo = await Purchases.purchaseProduct('premium_1m');
                                                                                        var isPro = customerInfo.entitlements.all['premium_1m'].isActive;
                                                                                        if (isPro) {
                                                                                          if (!mounted) return;
                                                                                          Navigator.of(context).pop();
                                                                                          // Unlock that great "pro" content
                                                                                        }
                                                                                      } on UnsupportedPlatformException catch (e) {
                                                                                        var errorCode = PurchasesErrorHelper.getErrorCode(e as PlatformException);
                                                                                        if (errorCode != PurchasesErrorCode.purchaseCancelledError) {}
                                                                                      }
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: GortAppTheme.darkText,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(25),
                                                                                      ),
                                                                                      elevation: 15.0,
                                                                                    ),
                                                                                    child: const Padding(
                                                                                      padding: EdgeInsets.all(15.0),
                                                                                      child: Text(
                                                                                        'Subscribe',
                                                                                        style: TextStyle(fontSize: 20, color: GortAppTheme.nearlyWhite),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ))
                                                                          ],
                                                                        ));
                                                                      });
                                                                }
                                                              },
                                                              title: const Card(
                                                                  child: Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      child: Text(
                                                                          'New Gört'))),
                                                            ),
                                                          ),
                                                          // ElevatedButton(
                                                          //   onPressed: () {
                                                          //     Navigator.pop(
                                                          //         context);
                                                          //   },
                                                          //   child: Text(
                                                          //       "New Gört"),
                                                          // ),
                                                          Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: Column(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: const Text(
                                                                        "Cancel"),
                                                                  ),
                                                                  Visibility(
                                                                    visible:
                                                                        showNewGort,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        var arr =
                                                                            activities;

                                                                        //var notificationidnumber = createUniqueId();
                                                                        addToFirebase([
                                                                          {
                                                                            'title':
                                                                                arr[i].title,
                                                                            'days':
                                                                                arr[i].daylist,
                                                                            'notificationidnumber':
                                                                                arr[i].notificationidnumber,
                                                                            'daysdone':
                                                                                arr[i].daylistdone,
                                                                            'timelist':
                                                                                arr[i].timelist,
                                                                            'weekdaysdone':
                                                                                arr[i].weekdaysdone,
                                                                            'weekdaysnotdone':
                                                                                arr[i].weekdaysnotdone,
                                                                            'time':
                                                                                arr[i].time
                                                                          }
                                                                        ]);
                                                                      },
                                                                      child: const Text(
                                                                          "Save Gört"),
                                                                    ),
                                                                  )
                                                                ],
                                                              )),
                                                        ],
                                                      );
                                                    }));
                                              });
                                        },
                                        icon: Icons.copy,
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromARGB(
                                            255, 56, 93, 255),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      SlidableAction(
                                        onPressed: (context) async {
                                          var showNewGort = false;
                                          // for (var day in activities
                                          //     .elementAt(i)
                                          //     .daylist) {
                                          //   for (var time in activities
                                          //       .elementAt(i)
                                          //       .timelist) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    backgroundColor:
                                                        GortAppTheme.background,
                                                    title: const Center(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          'Move activity',
                                                          style: TextStyle(
                                                              color: GortAppTheme
                                                                  .darkText),
                                                        ),
                                                      ),
                                                    ),
                                                    content: StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setState) {
                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Visibility(
                                                            visible:
                                                                !showNewGort,
                                                            child: Container(
                                                              color: GortAppTheme
                                                                  .background,
                                                              height:
                                                                  300.0, // Change as per your requirement
                                                              width:
                                                                  300.0, // Change as per your requirement
                                                              child: ListView
                                                                  .builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    allGortNames
                                                                        .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  return ListTile(
                                                                    onTap: () {
                                                                      var arr =
                                                                          activities;

                                                                      //var notificationidnumber =
                                                                      createUniqueId();
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(currentuser
                                                                              .uid)
                                                                          .doc(allGortNames
                                                                              .elementAt(index))
                                                                          .update({
                                                                        "activities":
                                                                            FieldValue.arrayUnion([
                                                                          {
                                                                            'title':
                                                                                arr[i].title,
                                                                            'days':
                                                                                arr[i].daylist,
                                                                            'notificationidnumber':
                                                                                arr[i].notificationidnumber,
                                                                            'daysdone':
                                                                                arr[i].daylistdone,
                                                                            'timelist':
                                                                                arr[i].timelist,
                                                                            'weekdaysdone':
                                                                                arr[i].weekdaysdone,
                                                                            'weekdaysnotdone':
                                                                                arr[i].weekdaysnotdone,
                                                                            'time':
                                                                                arr[i].time
                                                                          }
                                                                        ]),
                                                                      });
                                                                      cancelAllGroupScheduledNotifications(documentName +
                                                                          activities
                                                                              .elementAt(i)
                                                                              .title);

                                                                      //                                                                       if (documentName.isNotEmpty) {
                                                                      //   for (var selectedDay in arr[i].daylist) {
                                                                      //     for (var reminder in arr[i].timelist) {
                                                                      //       var hrstring = reminder.hour.toString();
                                                                      //       var mrstring = reminder.minute.toString();
                                                                      //       var uniqid = int.parse(selectedDay + hrstring + mrstring);
                                                                      //       createReminderNotification(
                                                                      //           documentName,
                                                                      //           gortdocnames.elementAt(index),
                                                                      //           notificationidnumber + uniqid,
                                                                      //           documentName,
                                                                      //           documentName + listNameController.text.toString(),
                                                                      //           NotificationWeekAndTime(
                                                                      //             dayOfTheWeek: int.parse(selectedDay),
                                                                      //             timeOfDay: reminder,
                                                                      //           ));
                                                                      //     }
                                                                      //   }
                                                                      // }

                                                                      var arr2 =
                                                                          activities;
                                                                      arr2.removeAt(
                                                                          i);

                                                                      final List<
                                                                              Map<String, dynamic>>
                                                                          act2 =
                                                                          [];
                                                                      // start a loop and update stuff
                                                                      for (int i =
                                                                              0;
                                                                          i < arr2.length;
                                                                          i++) {
                                                                        act2.add({
                                                                          'title':
                                                                              arr2[i].title,
                                                                          'days':
                                                                              arr2[i].daylist,
                                                                          'notificationidnumber':
                                                                              arr2[i].notificationidnumber,
                                                                          'daysdone':
                                                                              arr2[i].daylistdone,
                                                                          'timelist':
                                                                              arr2[i].timelist,
                                                                          'weekdaysdone':
                                                                              arr2[i].weekdaysdone,
                                                                          'weekdaysnotdone':
                                                                              arr2[i].weekdaysnotdone,
                                                                          'time':
                                                                              arr2[i].time
                                                                        });
                                                                      }
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(widget
                                                                              .user
                                                                              .uid)
                                                                          .doc(
                                                                              documentName)
                                                                          .update({
                                                                        "activities":
                                                                            act2
                                                                      });

                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    title: Card(
                                                                        child: Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child: Text(allGortNames.elementAt(index)))),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          Visibility(
                                                              visible:
                                                                  showNewGort,
                                                              child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 20.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          20.0),
                                                                  child: Column(
                                                                      children: <
                                                                          Widget>[
                                                                        Row(
                                                                          children: const [
                                                                            Text(
                                                                              'Title',
                                                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        TextFormField(
                                                                          decoration: InputDecoration(
                                                                              fillColor: Colors.black,
                                                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Colors.teal)),
                                                                              labelText: "Gört name",
                                                                              // errorText: _validate
                                                                              //     ? 'Value Can\'t Be Empty'
                                                                              //     : null,
                                                                              contentPadding: const EdgeInsets.only(left: 16.0, top: 20.0, right: 16.0, bottom: 5.0)),
                                                                          controller:
                                                                              listNameController,
                                                                          autofocus:
                                                                              false,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                22.0,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                          keyboardType:
                                                                              TextInputType.text,
                                                                          textCapitalization:
                                                                              TextCapitalization.sentences,
                                                                          maxLength:
                                                                              20,
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              15,
                                                                        ),
                                                                      ]))),
                                                          Visibility(
                                                            visible:
                                                                !showNewGort,
                                                            child: ListTile(
                                                              onTap: () async {
                                                                print(globals
                                                                    .totalgort);
                                                                CustomerInfo
                                                                    customerInfo =
                                                                    await Purchases
                                                                        .getCustomerInfo();
                                                                if (customerInfo.entitlements.all[
                                                                            'premium_1m'] !=
                                                                        null &&
                                                                    customerInfo
                                                                            .entitlements
                                                                            .all['premium_1m']
                                                                            .isActive ==
                                                                        true) {
                                                                  setState(() {
                                                                    showNewGort =
                                                                        true;
                                                                  });
                                                                } else {
                                                                  if (!mounted)
                                                                    return;
                                                                  showGeneralDialog(
                                                                      context:
                                                                          context,
                                                                      barrierColor:
                                                                          GortAppTheme
                                                                              .background,
                                                                      barrierDismissible:
                                                                          false,
                                                                      barrierLabel:
                                                                          'Dialog',
                                                                      transitionDuration:
                                                                          const Duration(
                                                                              milliseconds:
                                                                                  400),
                                                                      pageBuilder: (_,
                                                                          __,
                                                                          ___) {
                                                                        return Scaffold(
                                                                            body:
                                                                                Column(
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 60, left: 15),
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: Row(
                                                                                  children: const [
                                                                                    Icon(
                                                                                      Icons.close,
                                                                                      size: 40.0,
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            const Text(
                                                                              'GET PREMIUM',
                                                                              style: TextStyle(fontSize: 20),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Container(
                                                                              color: GortAppTheme.darkText,
                                                                              height: 1,
                                                                              width: MediaQuery.of(context).size.width * 0.7,
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            const Text(
                                                                              'Remove ads',
                                                                              style: TextStyle(fontSize: 20),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 25,
                                                                            ),
                                                                            const Text(
                                                                              'Unlimited Görts',
                                                                              style: TextStyle(fontSize: 20),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            const Icon(
                                                                              Icons.payment_rounded,
                                                                              size: 100,
                                                                              color: GortAppTheme.darkText,
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 20,
                                                                            ),
                                                                            const Text(
                                                                              '19kr/Månad',
                                                                              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            Expanded(
                                                                                child: Align(
                                                                              alignment: Alignment.bottomCenter,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(top: 50.0, bottom: 40),
                                                                                child: SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 0.7,
                                                                                  child: ElevatedButton(
                                                                                    onPressed: () async {
                                                                                      try {
                                                                                        CustomerInfo customerInfo = await Purchases.purchaseProduct('premium_1m');
                                                                                        var isPro = customerInfo.entitlements.all['premium_1m'].isActive;
                                                                                        if (isPro) {
                                                                                          if (!mounted) return;
                                                                                          Navigator.of(context).pop();
                                                                                          // Unlock that great "pro" content
                                                                                        }
                                                                                      } on UnsupportedPlatformException catch (e) {
                                                                                        var errorCode = PurchasesErrorHelper.getErrorCode(e as PlatformException);
                                                                                        if (errorCode != PurchasesErrorCode.purchaseCancelledError) {}
                                                                                      }
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: GortAppTheme.darkText,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(25),
                                                                                      ),
                                                                                      elevation: 15.0,
                                                                                    ),
                                                                                    child: const Padding(
                                                                                      padding: EdgeInsets.all(15.0),
                                                                                      child: Text(
                                                                                        'Subscribe',
                                                                                        style: TextStyle(fontSize: 20, color: GortAppTheme.nearlyWhite),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ))
                                                                          ],
                                                                        ));
                                                                      });
                                                                }
                                                              },
                                                              title: const Card(
                                                                  child: Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      child: Text(
                                                                          'New Gört'))),
                                                            ),
                                                          ),
                                                          // ElevatedButton(
                                                          //   onPressed: () {
                                                          //     Navigator.pop(
                                                          //         context);
                                                          //   },
                                                          //   child: Text(
                                                          //       "New Gört"),
                                                          // ),
                                                          Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: Column(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: const Text(
                                                                        "Cancel"),
                                                                  ),
                                                                  Visibility(
                                                                    visible:
                                                                        showNewGort,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        var arr =
                                                                            activities;

                                                                        // var notificationidnumber = createUniqueId();
                                                                        addToFirebase([
                                                                          {
                                                                            'title':
                                                                                arr[i].title,
                                                                            'days':
                                                                                arr[i].daylist,
                                                                            'notificationidnumber':
                                                                                arr[i].notificationidnumber,
                                                                            'daysdone':
                                                                                arr[i].daylistdone,
                                                                            'timelist':
                                                                                arr[i].timelist,
                                                                            'weekdaysdone':
                                                                                arr[i].weekdaysdone,
                                                                            'weekdaysnotdone':
                                                                                arr[i].weekdaysnotdone,
                                                                            'time':
                                                                                arr[i].time
                                                                          }
                                                                        ]);
                                                                        setState(
                                                                            () {});

                                                                        if (_connectionStatus ==
                                                                            "ConnectivityResult.none") {
                                                                          showInSnackBar(
                                                                              "Ingen internetanslutning");
                                                                          setState(
                                                                              () {});
                                                                        } else {
                                                                          bool
                                                                              isExist =
                                                                              false;

                                                                          QuerySnapshot
                                                                              query =
                                                                              await FirebaseFirestore.instance.collection(currentuser.uid).get();

                                                                          for (var doc
                                                                              in query.docs) {
                                                                            if (listNameController.text.toString() ==
                                                                                doc.id) {
                                                                              isExist = true;
                                                                            }
                                                                          }

                                                                          if (isExist == false &&
                                                                              listNameController.text.isNotEmpty) {
                                                                            cancelAllGroupScheduledNotifications(documentName +
                                                                                activities.elementAt(i).title);

                                                                            var arr2 =
                                                                                activities;
                                                                            arr2.removeAt(i);

                                                                            final List<Map<String, dynamic>>
                                                                                act2 =
                                                                                [];
                                                                            // start a loop and update stuff
                                                                            for (int i = 0;
                                                                                i < arr2.length;
                                                                                i++) {
                                                                              act2.add({
                                                                                'title': arr2[i].title,
                                                                                'days': arr2[i].daylist,
                                                                                'notificationidnumber': arr2[i].notificationidnumber,
                                                                                'daysdone': arr2[i].daylistdone,
                                                                                'timelist': arr2[i].timelist,
                                                                                'weekdaysdone': arr2[i].weekdaysdone,
                                                                                'weekdaysnotdone': arr2[i].weekdaysnotdone,
                                                                                'time': arr2[i].time
                                                                              });
                                                                            }
                                                                            FirebaseFirestore.instance.collection(currentuser.uid).doc(documentName).update({
                                                                              "activities": act2
                                                                            });
                                                                          }
                                                                        }
                                                                      },
                                                                      child: const Text(
                                                                          "Save Gört"),
                                                                    ),
                                                                  )
                                                                ],
                                                              )),
                                                        ],
                                                      );
                                                    }));
                                              });
                                        },
                                        icon: Icons.move_down,
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            const Color(0xFF21B7CA),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      SlidableAction(
                                        onPressed: (context) {
                                          // for (var day in activities
                                          //     .elementAt(i)
                                          //     .daylist) {
                                          //   for (var time in activities
                                          //       .elementAt(i)
                                          //       .timelist) {
                                          setState(() {
                                            cancelAllGroupScheduledNotifications(
                                                documentName +
                                                    activities
                                                        .elementAt(i)
                                                        .title);
                                          });

                                          var arr = activities;
                                          arr.removeAt(i);

                                          final List<Map<String, dynamic>> act =
                                              [];
                                          // start a loop and update stuff
                                          for (int i = 0; i < arr.length; i++) {
                                            act.add({
                                              'title': arr[i].title,
                                              'days': arr[i].daylist,
                                              'notificationidnumber':
                                                  arr[i].notificationidnumber,
                                              'daysdone': arr[i].daylistdone,
                                              'timelist': arr[i].timelist,
                                              'weekdaysdone':
                                                  arr[i].weekdaysdone,
                                              'weekdaysnotdone':
                                                  arr[i].weekdaysnotdone,
                                              'time': arr[i].time
                                            });
                                          }
                                          FirebaseFirestore.instance
                                              .collection(currentuser.uid)
                                              .doc(documentName)
                                              .update({"activities": act});
                                        },
                                        icon: Icons.delete,
                                        backgroundColor: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, bottom: 10),
                                      child: ActivityCard(
                                        index: i,
                                        listActivities: activities,
                                        userid: currentuser.uid,
                                        activity: activities.elementAt(i),
                                      )));
                            },
                          ),
                          // webvideos.isEmpty && webimages.isEmpty
                          //     ? Container()
                          //     : SizedBox(
                          //         height: 200,
                          //         child: Align(
                          //             alignment: Alignment.centerLeft,
                          //             child: ListView(
                          //               physics: BouncingScrollPhysics(),
                          //               scrollDirection: Axis.horizontal,
                          //               shrinkWrap: true,
                          //               children: [
                          //                 ListView.builder(
                          //                   physics:
                          //                       const NeverScrollableScrollPhysics(),
                          //                   shrinkWrap: true,
                          //                   scrollDirection:
                          //                       Axis.horizontal,
                          //                   itemBuilder:
                          //                       (BuildContext ctx,
                          //                           int index) {
                          //                     return SizedBox(
                          //                         height: MediaQuery.of(
                          //                                     context)
                          //                                 .size
                          //                                 .width *
                          //                             0.2,
                          //                         child: Card(
                          //                           elevation: 0,
                          //                           color: Colors
                          //                               .transparent,
                          //                           surfaceTintColor:
                          //                               Colors
                          //                                   .transparent,
                          //                           margin:
                          //                               const EdgeInsets
                          //                                   .all(10),
                          //                           shape:
                          //                               RoundedRectangleBorder(
                          //                             borderRadius:
                          //                                 BorderRadius
                          //                                     .circular(
                          //                                         20.0),
                          //                           ),
                          //                           child: Align(
                          //                             alignment: Alignment
                          //                                 .center,
                          //                             child: Container(
                          //                               clipBehavior: Clip
                          //                                   .antiAlias,
                          //                               decoration:
                          //                                   BoxDecoration(
                          //                                 color: Colors
                          //                                     .transparent,
                          //                                 borderRadius:
                          //                                     BorderRadius
                          //                                         .circular(
                          //                                             10),
                          //                               ),
                          //                               child: Image.file(
                          //                                 File(_imageFileListM[
                          //                                         index]
                          //                                     .path),
                          //                                 fit: BoxFit
                          //                                     .contain,
                          //                               ),
                          //                             ),
                          //                           ),
                          //                         ));
                          //                   },
                          //                   itemCount:
                          //                       _imageFileListM.length,
                          //                 ),
                          //                 ListView.builder(
                          //                   physics:
                          //                       const NeverScrollableScrollPhysics(),
                          //                   shrinkWrap: true,
                          //                   scrollDirection:
                          //                       Axis.horizontal,
                          //                   itemBuilder:
                          //                       (BuildContext ctx,
                          //                           int index) {
                          //                     return SizedBox(
                          //                         height: MediaQuery.of(
                          //                                     context)
                          //                                 .size
                          //                                 .width *
                          //                             0.2,
                          //                         child: Card(
                          //                           elevation: 0,
                          //                           color: Colors
                          //                               .transparent,
                          //                           surfaceTintColor:
                          //                               Colors
                          //                                   .transparent,
                          //                           margin:
                          //                               const EdgeInsets
                          //                                   .all(10),
                          //                           shape:
                          //                               RoundedRectangleBorder(
                          //                             borderRadius:
                          //                                 BorderRadius
                          //                                     .circular(
                          //                                         20.0),
                          //                           ),
                          //                           child: Align(
                          //                             alignment: Alignment
                          //                                 .center,
                          //                             child: Container(
                          //                               clipBehavior: Clip
                          //                                   .antiAlias,
                          //                               decoration:
                          //                                   BoxDecoration(
                          //                                 color: Colors
                          //                                     .transparent,
                          //                                 borderRadius:
                          //                                     BorderRadius
                          //                                         .circular(
                          //                                             10),
                          //                               ),
                          //                               child:
                          //                                   Image.network(
                          //                                 webimages[
                          //                                     index],
                          //                                 fit: BoxFit
                          //                                     .contain,
                          //                               ),
                          //                             ),
                          //                           ),
                          //                         ));
                          //                   },
                          //                   itemCount: webimages.length,
                          //                 ),
                          //                 ListView.builder(
                          //                   physics:
                          //                       const NeverScrollableScrollPhysics(),
                          //                   scrollDirection:
                          //                       Axis.horizontal,
                          //                   shrinkWrap: true,
                          //                   itemBuilder:
                          //                       (BuildContext ctx,
                          //                           int index) {
                          //                     return SizedBox(
                          //                         height: 200,
                          //                         width: 200,
                          //                         child: VideoPlay(
                          //                             pathh: webvideos[
                          //                                 index]));
                          //                   },
                          //                   itemCount: webvideos.length,
                          //                 )
                          //               ],
                          //             ))),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Visibility(
                          visible: newweek,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      changeWeek();
                                      // Future.delayed(Duration.zero, () {
                                      //   Dialogs.materialDialog(
                                      //     color: Colors.white,
                                      //     msg:
                                      //         'Grattis, du klarade $gortActivitiyDaysDoneCount/$gortActivitiyDaysCount aktiviteter',
                                      //     title: 'Ny vecka',
                                      //     // lottieBuilder: Lottie.asset(
                                      //     // 'assets/cong_example.json',
                                      //     // fit: BoxFit.contain,
                                      //     // ),
                                      //     context: context,
                                      //     actions: [
                                      //       ElevatedButton(
                                      //         onPressed: () async {
                                      //           await changeWeek();
                                      //           FirebaseFirestore.instance
                                      //               .collection(currentuser.uid)
                                      //               .doc(documentName)
                                      //               .update({
                                      //             'currentweek': DateTime.now()
                                      //                 .weekOfYear
                                      //                 .toString(),
                                      //           });

                                      //           if (!mounted) return;
                                      //           Navigator.of(context).pop();
                                      //         },
                                      //         child: const Text('Fortsätt'),
                                      //       ),
                                      //     ],
                                      //   );
                                      // });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 15.0,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Text(
                                        'Fortsätt',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 25,
                                )
                              ],
                            ),
                          )),
                      Visibility(
                          visible: !newweek,
                          child: Visibility(
                              visible: showcontent,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              pageBuilder: (_, __, ___) =>
                                                  ActivityPage(
                                                user: widget.user,
                                                documentName: documentName,
                                                color: currentColor,
                                              ),
                                              transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) =>
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
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          elevation: 15.0,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(15.0),
                                          child: Text(
                                            'Add activity',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    )
                                  ],
                                ),
                              ))),
                    ],
                  ))
            ],
          ));
    }

    //   void storeOldDates(List<int> weekdays) {
    //     List<DateTime> oldDatesDone = [];
    //     int year = 2023;
    //     DateTime startDate = DateTime(year, 1, 1);
    //     while (startDate.weekday != DateTime.monday) {
    //       startDate = startDate.add(Duration(days: 1));
    //     }
    //     for (int weekday in weekdays) {
    //       int offset = (weekday - 1) + (int.parse(currentweek) - 1) * 7;
    //       DateTime date = startDate.add(Duration(days: offset));
    //       oldDatesDone.add(date);
    //       print(oldDatesDone);
    //     }
    //   }
  }

  Widget setupAlertDialoadContainer(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.grey,
          height: 300.0, // Change as per your requirement
          width: 300.0, // Change as per your requirement
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allGortNames.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(allGortNames.elementAt(index)))),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        )
      ],
    );
  }

  void showInSnackBar(String value) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(value),
    // )
    // );
  }

  Future<void> initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration =
          PurchasesConfiguration('goog_IwHHndgVDAefoxrcalgTksZmSqF');
      // if (buildingForAmazon) {
      //   // use your preferred way to determine if this build is for Amazon store
      //   // checkout our MagicWeather sample for a suggestion
      //   configuration = AmazonConfiguration(<public_amazon_sdk_key>);
      // }
    } else if (Platform.isIOS) {
      configuration =
          PurchasesConfiguration('appl_JcMoSccethXXDUouIeXgIgGvQOh');
    }
    await Purchases.configure(configuration);
  }

  List<String> webimageList = [];
  List<String> webvideoList = [];
  final String _connectionStatus = 'Unknown';
  TextEditingController listNameController = TextEditingController();
  String url =
      'https://firebasestorage.googleapis.com/v0/b/gort-668f0.appspot.com/o/placeholder.png?alt=media&token=08976534-a647-48fe-92e6-6b3ae81bcdd8';

  void addToFirebase(List activity) async {
    setState(() {});

    if (_connectionStatus == "ConnectivityResult.none") {
      showInSnackBar("Ingen internetanslutning");
      setState(() {});
    } else {
      bool isExist = false;

      QuerySnapshot query =
          await FirebaseFirestore.instance.collection(currentuser.uid).get();

      for (var doc in query.docs) {
        if (listNameController.text.toString() == doc.id) {
          isExist = true;
        }
      }

      if (isExist == false && listNameController.text.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(currentuser.uid)
            .doc(listNameController.text.toString().trim().replaceAll('/', 'ô'))
            .set({
          "color": currentColor.value.toString(),
          "date": DateTime.now().millisecondsSinceEpoch,
          "currentDayIndex": currentDayIndex,
          "webimagelist": webimageList,
          "webvideolist": webvideoList,
          "days": '30',
          "documentId": createUniqueId(),
          "activities": activity,
          "currentweek": DateTime.now().weekOfYear.toString(),
          "imageurl": url,
          "endDate": 'true',
          "streak": '0',
          "record": '0'
        });

        listNameController.clear();
        await VideoCompress.deleteAllCache();
        if (!mounted) return;
        Navigator.of(context).pop();
      }
      if (isExist == true) {
        showInSnackBar("This list already exists");
        setState(() {});
      }
      if (listNameController.text.isEmpty) {
        showInSnackBar("Please enter a name");
        setState(() {});
      }
    }
  }

  Future changeWeek() async {
    setState(() {
      newweek = false;
    });
    var record1 = int.parse(record);
    var streak1 = int.parse(streak);
    var newstreak2 = (totalDaysDoneGortCount) + streak1;
    var newstreak = int.parse(streak) + (totalDaysDoneGortCount);

    if (totalDaysGortCount == totalDaysDoneGortCount) {
      FirebaseFirestore.instance
          .collection(currentuser.uid)
          .doc(documentName)
          .update({"streak": (newstreak.toString())});
      if (record1 < streak1) {
        FirebaseFirestore.instance
            .collection(currentuser.uid)
            .doc(documentName)
            .update({"record": (newstreak.toString())});
      }
    } else {
      if (record1 < newstreak2) {
        FirebaseFirestore.instance
            .collection(currentuser.uid)
            .doc(documentName)
            .update({"record": (newstreak2.toString())});
      }
      FirebaseFirestore.instance
          .collection(currentuser.uid)
          .doc(documentName)
          .update({"streak": 0.toString()});
    }
    final List<Map<String, dynamic>> act = [];
    // start a loop and update stuff
    for (int i = 0; i < newactivities.length; i++) {
      List<String> myData22 = [];
      List<Timestamp> oldDatesDone = [];
      List<Timestamp> oldDatesNotDone = [];
      List<Timestamp> finaloldDatesDone = [];
      List<Timestamp> finaloldDatesNotDone = [];

      // now check if current index is equal to loop index
      int year = DateTime.now().year;
      DateTime startDate = DateTime(year, 1, 1);
      while (startDate.weekday != DateTime.monday) {
        startDate = startDate.add(const Duration(days: 1));
      }
      for (String weekday in newactivities[i].daylistdone) {
        int offset = (int.parse(weekday)) + (int.parse(currentweek) - 1) * 7;
        DateTime donedate = startDate.add(Duration(days: offset));
        oldDatesDone.add(Timestamp.fromDate(donedate));
      }
      for (String weekday in newactivities[i].daylist) {
        int offset =
            (int.parse(weekday) - 1) + (int.parse(currentweek) - 1) * 7;
        DateTime notdonedate = startDate.add(Duration(days: offset));
        oldDatesNotDone.add(Timestamp.fromDate(notdonedate));
      }

      for (var i in oldDatesDone) {
        oldDatesNotDone.remove(i);
      }

      finaloldDatesDone = newactivities[i].weekdaysdone + oldDatesDone;
      finaloldDatesNotDone = newactivities[i].weekdaysnotdone + oldDatesNotDone;
      act.add({
        'title': newactivities[i].title,
        'days': newactivities[i].daylist,
        'notificationidnumber': newactivities[i].notificationidnumber,
        'daysdone': myData22,
        'weekdaysdone': finaloldDatesDone,
        'weekdaysnotdone': finaloldDatesNotDone,
        'timelist': newactivities[i].timelist,
        'time': newactivities[i].time
      });
    }
    await FirebaseFirestore.instance
        .collection(currentuser.uid)
        .doc(documentName)
        .update({"activities": act});

    await changeWeekNumber(DateTime.now().weekOfYear.toString());
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {}

  Future<void> _navigateAndDisplaySelectionai(BuildContext context) async {}

  changeColor(Color color) {
    FirebaseFirestore.instance
        .collection(currentuser.uid)
        .doc(documentName)
        .update({"color": color.value.toString()});
    setState(() {
      pickerColor = color;
      currentColor = color;
    });
  }

  changeWeekNumber(String currentweek) {
    FirebaseFirestore.instance
        .collection(currentuser.uid)
        .doc(documentName)
        .update({"currentweek": currentweek});
  }

  changeEndDate(String enddate) {
    FirebaseFirestore.instance
        .collection(currentuser.uid)
        .doc(documentName)
        .update({"endDate": enddate.toString()});
  }

  changeDate(String currentdayindex) {
    FirebaseFirestore.instance
        .collection(currentuser.uid)
        .doc(documentName)
        .update({"currentDayIndex": currentDayIndex.toString()});
  }

  changeWebimages() {
    FirebaseFirestore.instance
        .collection(currentuser.uid)
        .doc(documentName)
        .update({"webimagelist": webimages, "webvideolist": webvideos});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2025),
    );
    if (d != null) {
      setState(() {
        _selectedDate = DateFormat.yMMMMd("en_US").format(d);
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        final String formatted = formatter.format(d);
        currentDayIndex = formatted;

        changeDate(formatted);
      });
    }
  }

  // Future<void> deleteFile(File file) async {
  //   try {
  //     if (await file.exists()) {
  //       await file.delete();
  //     }
  //   } catch (e) {
  //     // Error in getting access to the file.
  //   }
  // }

  // void deleteFilesFromProject() async {
  //   directory = (await getApplicationDocumentsDirectory()).path;
  //   setState(() {
  //     final mediaFiles = io.Directory('$directory/')
  //         .listSync()
  //         .whereType<File>()
  //         .where((file) => file.path.split('/').last.contains(documentId));
  //     Iterable<File> files = mediaFiles.whereType<File>();
  //     for (final file in files) {
  //       deleteFile(file);
  //     }
  //   });
  // }

  // void _listofImagesM() async {
  //   directory = (await getApplicationDocumentsDirectory()).path;
  //   setState(() {
  //     final mediaFiles = io.Directory('$directory/')
  //         .listSync()
  //         .whereType<File>()
  //         .where((file) =>
  //             file.path.split('/').last.startsWith('imageM$documentId'));
  //     Iterable<File> files = mediaFiles.whereType<File>();
  //     for (final file in files) {
  //       _imageFileListM.add(file);
  //     }
  //   });
  // }

  // void _listofVideosM() async {
  //   directory = (await getApplicationDocumentsDirectory()).path;
  //   setState(() {
  //     final mediaFiles = io.Directory('$directory/')
  //         .listSync()
  //         .whereType<File>()
  //         .where((file) =>
  //             file.path.split('/').last.startsWith('videoM$documentId'));
  //     Iterable<File> files = mediaFiles.whereType<File>();
  //     for (final file in files) {
  //       _videoFileListM.add(file);
  //     }
  //   });
  // }

  Future<XFile> _fileFromImageUrl(String url) async {
    final response = await http.get(Uri.parse(url));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file =
        File(pt.join(documentDirectory.path, DateTime.now().toString()));

    file.writeAsBytesSync(response.bodyBytes);
    setState(() {
      imageFileListM.add(XFile(file.path));
    });

    return XFile(file.path);
  }

  void selectImages() async {
    final List<XFile> selectedMImages = await imagePicker.pickMultiImage(
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.width,
      imageQuality: 100,
    );
    if (selectedMImages.isNotEmpty) {
      imageFileListM.addAll(selectedMImages);
    }
    setState(() {});
  }

  void selectVideo() async {
    final XFile selectedMVideos =
        await imagePicker.pickVideo(source: ImageSource.gallery);
    if (selectedMVideos != null) {
      //  do something
      final info = await VideoCompress.compressVideo(
        selectedMVideos.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      setState(() {
        videoFileListM.add(XFile(info.path));
      });
    }
  }

  Future<List<String>> uploadImages(List<XFile> images) async {
    var imageUrls =
        await Future.wait(images.map((image) => uploadImage(image)));
    // print(imageUrls);
    newwebimages.addAll(imageUrls);
    return imageUrls;
  }

  Future<String> uploadImage(XFile image) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('${currentuser.uid}/${image.path}');
    UploadTask uploadTask = storageReference.putFile(File(image.path));
    final TaskSnapshot downloadUrl = (await uploadTask);
    final linkurl = await downloadUrl.ref.getDownloadURL();
    return linkurl;
  }

  Future<List<String>> uploadVideoFiles(List<XFile> videos) async {
    var videoUrls =
        await Future.wait(videos.map((image) => uploadVideo(image)));
    newwebvideos.addAll(videoUrls);
    return videoUrls;
  }

  Future<String> uploadVideo(XFile video) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('${currentuser.uid}/${video.path}');
    UploadTask uploadTask = storageReference.putFile(File(video.path));
    final TaskSnapshot downloadUrl = (await uploadTask);
    final linkurl = await downloadUrl.ref.getDownloadURL();
    return linkurl;
  }

  // writeMImage(XFile media, String mediaIndex, String doc) async {
  //   final Directory directory = await getApplicationDocumentsDirectory();
  //   final File file = File(
  //       '${directory.path}/imageM$doc${DateTime.now().toString().trim().replaceAll(RegExp('[^A-Za-z0-9]'), '').replaceAll(' ', '')}.jpg');
  //   await file.writeAsBytes(await media.readAsBytes());
  // }

  // Future saveMImages(String docName) async {
  //   int index = 0;
  //   for (var x in imageFileListM) {
  //     writeMImage(x, index.toString(), docName);
  //     index++;
  //   }
  //   reloadimages();
  // }

  // Future reloadimages() async {
  //   imageFileListM.clear();
  //   _imageFileListM.clear();

  //   Future.delayed(const Duration(seconds: 0, milliseconds: 600), () {
  //     _listofImagesM();
  //   });
  // }

  // Future reloadvideos() async {
  //   videoFileListM.clear();
  //   _videoFileListM.clear();

  //   Future.delayed(const Duration(seconds: 0, milliseconds: 600), () {
  //     _listofVideosM();
  //   });
  // }

  // writeMVideo(XFile media, String mediaIndex, String doc) async {
  //   final Directory directory = await getApplicationDocumentsDirectory();
  //   final File file = File(
  //       '${directory.path}/videoM$doc${DateTime.now().toString().trim().replaceAll(RegExp('[^A-Za-z0-9]'), '').replaceAll(' ', '')}.mp4');
  //   await file.writeAsBytes(await media.readAsBytes());
  // }

  // saveMVideos(String docName) {
  //   int index = 0;
  //   for (var x in videoFileListM) {
  //     writeMVideo(x, index.toString(), docName);
  //     index++;
  //   }
  //   reloadvideos();
  // }

  Future<DocumentSnapshot<Map<String, dynamic>>> getnotificationdata(
      String pload) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance
        .collection(currentUser.uid)
        .doc(pload)
        .get()
        .then((value) {
      if (value.exists) {
        print(value.data()['color'].toString());
        setState(() {
          pickerColor = Color(int.parse(value.data()['color'].toString()));
          currentColor = Color(int.parse(value.data()['color'].toString()));
          currentDayIndex = value.data()['currentDayIndex'].toString();
          createdDay = int.parse((value.data()['date'].toString()));
          DateTime date = DateTime.fromMillisecondsSinceEpoch(createdDay);
          DateTime dateTimeNow = DateTime.now();
          daysCheck = dateTimeNow.difference(date).inDays;
          daysleft = (DateTime.parse(currentDayIndex).difference(date).inDays) -
              daysCheck;
          documentId = (value.data()['documentId'].toString());
          totalDays = (DateTime.parse(currentDayIndex).difference(date).inDays);
          // _listofImagesM();
          // _listofVideosM();
          _selectedDate = currentDayIndex;
          documentName = pload;
          webimages = List<String>.from(value.data()['webimagelist']);
          webvideos = List<String>.from(value.data()['webvideolist']);
          currentweek = value.data()['currentweek'].toString();
          gortActivitiyDaysCount = widget.gortActivitiyDaysCount;
          gortActivitiyDaysDoneCount = widget.gortActivitiyDaysDoneCount;
          endDate = widget.endDate;
          streak = value.data()['streak'].toString();
          record = value.data()['record'].toString();

          if (currentweek == DateTime.now().weekOfYear.toString()) {
          } else {
            newweek = true;
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    initPlatformState();
    currentuser = FirebaseAuth.instance.currentUser;
    if (widget.color == null) {
      payload = widget.payload;
      getnotificationdata(payload);
    } else {
      pickerColor = Color(int.parse(widget.color));
      currentColor = Color(int.parse(widget.color));
      currentDayIndex = widget.dayindex;
      createdDay = widget.createdDate;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(createdDay);
      DateTime dateTimeNow = DateTime.now();
      daysCheck = dateTimeNow.difference(date).inDays;
      daysleft =
          (DateTime.parse(currentDayIndex).difference(date).inDays) - daysCheck;
      documentId = (widget.documentId);
      totalDays = (DateTime.parse(currentDayIndex).difference(date).inDays);
      // _listofImagesM();
      // _listofVideosM();
      _selectedDate = currentDayIndex;
      documentName = widget.docname;
      webimages = widget.webimages;
      webvideos = widget.webvideos;
      currentweek = widget.week;
      gortActivitiyDaysCount = widget.gortActivitiyDaysCount;
      gortActivitiyDaysDoneCount = widget.gortActivitiyDaysDoneCount;
      endDate = widget.endDate;
      streak = widget.streak;
      record = widget.record;
      allGortNames = widget.allGottNames;
      currentuser = widget.user;
      if (currentweek == DateTime.now().weekOfYear.toString()) {
      } else {
        newweek = true;
      }
    }
    // var frequencynumber = ["1", "2", "3", "4", "5", "6", "7"];
    // var lst1 = ["t1", "t2", "t3", "t4"];
    // List<String> lst2 = ["2", "4", "5"];
    // var set1 = Set.from(frequencynumber);
    // var set2 = Set.from(lst2);
    // print(List.from(Set.from(frequencynumber).difference(set2)));
  }

  List<String> checkedItemList = [];

  Color pickerColor;
  Color currentColor;
  String selectedDate;
  String documentName;
  String currentDayIndex;
  int createdDay;
  int daysleft;
  int daysCheck;
  String documentId;
  int totalDays;
  String _selectedDate = 'Tap to select date';
  final ImagePicker imagePicker = ImagePicker();
  bool isSwitched = false;
  List<String> webimages = [];
  List<String> newwebimages = [];
  List<String> webvideos = [];
  List<String> newwebvideos = [];
  String currentweek;
  String gortActivitiyDaysCount;
  String gortActivitiyDaysDoneCount;
  bool endDate;
  bool newweek = false;
  String streak;
  String record;
  List<String> allGortNames;
  User currentuser;
  String payload;

  String selectedDays;
  List<String> day = [];
  String directory;
  List filelist = [];
  final List<XFile> imageFileListM = [];
  final List<XFile> videoFileListM = [];

  final Map<String, List<ElementTask>> currentList = {};
  List<ElementTask> listElement = [];
  List<int> listElementDays = [];
  int daysweek = 1;
  String currentFrequencyIndex = '0';
  List<int> listnotificationdays = [];
  Map<String, bool> values = {};
  List<String> documentNames = [];

  Padding _getToolbar2(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 12.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(
                context,
              );
            },
            child: const Icon(Icons.arrow_back,
                size: 40.0, color: GortAppTheme.darkText),
          ),
        ]));
  }

  Padding _getToolbar(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 12.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(
                context,
              );
            },
            child: const Icon(Icons.arrow_back,
                size: 40.0, color: GortAppTheme.darkText),
          ),
          GestureDetector(
              onTap: () async {
                if (showsettings == false) {
                  setState(
                    () {
                      showsettings = true;
                      showcontent = false;
                    },
                  );
                } else if (showsettings == true) {
                  showsettings = false;
                  showcontent = true;
                  // saveMImages(documentId);
                  // saveMVideos(documentId);
                  await uploadImages(imageFileListM);
                  await uploadVideoFiles(videoFileListM);
                  webimages.addAll(newwebimages);
                  webvideos.addAll(newwebvideos);
                  changeWebimages();
                  newwebimages.clear();
                  newwebimages.clear();
                  newwebvideos.clear();
                  imageFileListM.clear();
                  videoFileListM.clear();
                  await VideoCompress.deleteAllCache();
                  setState(
                    () {},
                  );
                }
              },
              child: Icon(
                showcontent == true ? Icons.settings : Icons.done,
                size: 40,
                color: GortAppTheme.darkText,
              ))
        ]));
  }
}

class Activity {
  final String id;
  final String currentweek;
  final String time;
  final String title;
  final int notificationidnumber;
  List<String> daylist = [];
  List<String> daylistdone = [];
  List<String> timelist = [];
  List<Timestamp> weekdaysdone = [];
  List<Timestamp> weekdaysnotdone = [];

  Activity(
      {this.id,
      this.currentweek,
      this.time,
      this.title,
      this.notificationidnumber,
      this.daylist,
      this.daylistdone,
      this.weekdaysdone,
      this.weekdaysnotdone,
      this.timelist});
}

class ActivityCard extends StatefulWidget {
  final int index;
  final String userid;
  final Activity activity;
  final List<Activity> listActivities;
  const ActivityCard({
    Key key,
    @required this.index,
    @required this.userid,
    @required this.activity,
    @required this.listActivities,
  }) : super(key: key);

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  void onTimeChanged(TimeOfDay newTime) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    checkSubscription();
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  List<String> frequencyButtons = ["M", "T", "O", "T", "F", "L", "S"];

  showal() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.9), // Background color
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Scaffold(
            body: Column(
          children: <Widget>[
            Expanded(
                flex: 7,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'VECKA AVKLARAD',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      color: GortAppTheme.darkText,
                      height: 1,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'Checka av veckan och fortsätt',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ChipsChoice<String>.multiple(
                      value: widget.activity.daylistdone,
                      choiceStyle: C2ChipStyle.outlined(
                        padding: const EdgeInsets.all(4),
                        color: GortAppTheme.darkText,
                        borderWidth: 2,
                        foregroundStyle: const TextStyle(fontSize: 15),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        selectedStyle: C2ChipStyle.filled(color: Colors.green),
                      ),
                      onChanged: (List<String> val) {
                        /// First take a list of activities
                        final List<Map<String, dynamic>> act = [];
                        // start a loop and update stuff
                        for (int i = 0; i < widget.listActivities.length; i++) {
                          // now check if current index is equal to loop index
                          if (i == widget.index) {
                            act.add({
                              'title': widget.activity.title,
                              'days': widget.activity.daylist,
                              'notificationidnumber':
                                  widget.activity.notificationidnumber,
                              'daysdone': val,
                              'timelist': widget.activity.timelist,
                              'weekdaysdone': widget.activity.weekdaysdone,
                              'weekdaysnotdone':
                                  widget.activity.weekdaysnotdone,
                              'time': widget.activity.time
                            });
                          } else {
                            act.add({
                              'title': widget.listActivities[i].title,
                              'days': widget.listActivities[i].daylist,
                              'notificationidnumber':
                                  widget.listActivities[i].notificationidnumber,
                              'daysdone': widget.listActivities[i].daylistdone,
                              'weekdaysdone':
                                  widget.listActivities[i].weekdaysdone,
                              'weekdaysnotdone':
                                  widget.listActivities[i].weekdaysnotdone,
                              'timelist': widget.listActivities[i].timelist,
                              'time': widget.listActivities[i].time
                            });
                          }
                        }

                        FirebaseFirestore.instance
                            .collection(widget.userid)
                            .doc(widget.activity.id)
                            .update({"activities": act});
                      },
                      choiceItems: C2Choice.listFrom<String, String>(
                        source: frequencyButtons,
                        value: (i, v) => i.toString(),
                        label: (i, v) {
                          return frequencyButtons[i];
                        },
                        disabled: (i, v) {
                          var daylist = widget.activity.daylist;
                          return daylist
                                  .where(
                                      (element) => i == int.parse(element) - 1)
                                  .isEmpty
                              ? true
                              : false;
                        },
                        // disabled: (i, v) => [1, 4].contains(i),
                      ),
                    ),
                  ],
                )),
            Expanded(
              flex: 1,
              child: SizedBox.expand(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fortsätt'),
                ),
              ),
            ),
          ],
        ));
      },
    );
  }

  InterstitialAd _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  void checkSubscription() async {
    await Purchases.getCustomerInfo();
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.entitlements.all['premium_1m'] != null &&
        customerInfo.entitlements.all['premium_1m'].isActive == true) {
      // Grant user "pro" access
      setState(() {
        subscribeStatus = true;
      });
    }
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-1394145303258614/7920752813'
            : 'ca-app-pub-3940256099942544/4411468910',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < 5) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  double containerHeight;
  bool expanded = false;
  bool subscribeStatus = false;
  @override
  Widget build(BuildContext context) {
    List<String> frequencyButtons = ["M", "T", "O", "T", "F", "L", "S"];
    List<String> myData2 = [];
    List<String> myData3 = [];

    containerHeight = 110;
    List<String> updatedtimelist = widget.activity.timelist;
    TextEditingController listNameController = TextEditingController();
    bool edittext = true;
    return GestureDetector(
        onTap: () {
          listNameController.text = widget.activity.title;
          showCupertinoModalBottomSheet(
            enableDrag: false,
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context,
                    StateSetter setState /*You can rename this!*/) {
                  return Scaffold(
                      body: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 30.0),
                                ),
                                Visibility(
                                    visible: edittext,
                                    child: Flexible(
                                      child: Text(
                                        widget.activity.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )),
                                Visibility(
                                  visible: !edittext,
                                  child: Flexible(
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                fillColor: Colors.black,
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .circular(25),
                                                    borderSide:
                                                        const BorderSide(
                                                            color:
                                                                Colors.teal)),
                                                labelText: 'Activity name',
                                                // errorText: _validate
                                                // ? 'Value Can\'t Be Empty'
                                                // : null,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 16.0,
                                                        top: 2.0,
                                                        right: 16.0,
                                                        bottom: 5.0)),
                                            controller: listNameController,
                                            autofocus: false,
                                            style: const TextStyle(
                                              fontSize: 22.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            keyboardType: TextInputType.text,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            maxLength: 20,
                                          ))),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      if (edittext == true) {
                                        setState(() {
                                          edittext = false;
                                        });
                                      } else if (edittext == false) {
                                        setState(() {
                                          edittext = true;
                                        });
                                        final List<Map<String, dynamic>> act =
                                            [];
                                        // start a loop and update stuff
                                        for (int i = 0;
                                            i < widget.listActivities.length;
                                            i++) {
                                          // now check if current index is equal to loop index
                                          if (i == widget.index) {
                                            act.add({
                                              'title': listNameController.text,
                                              'days': widget.activity.daylist,
                                              'notificationidnumber': widget
                                                  .activity
                                                  .notificationidnumber,
                                              'daysdone':
                                                  widget.activity.daylistdone,
                                              'timelist':
                                                  widget.activity.timelist,
                                              'weekdaysdone':
                                                  widget.activity.weekdaysdone,
                                              'weekdaysnotdone': widget
                                                  .activity.weekdaysnotdone,
                                              'time': widget.activity.time
                                            });
                                          } else {
                                            act.add({
                                              'title': widget
                                                  .listActivities[i].title,
                                              'days': widget
                                                  .listActivities[i].daylist,
                                              'notificationidnumber': widget
                                                  .listActivities[i]
                                                  .notificationidnumber,
                                              'daysdone': widget
                                                  .listActivities[i]
                                                  .daylistdone,
                                              'weekdaysdone': widget
                                                  .listActivities[i]
                                                  .weekdaysdone,
                                              'weekdaysnotdone': widget
                                                  .listActivities[i]
                                                  .weekdaysnotdone,
                                              'timelist': widget
                                                  .listActivities[i].timelist,
                                              'time':
                                                  widget.listActivities[i].time
                                            });
                                          }
                                        }
                                        await FirebaseFirestore.instance
                                            .collection(widget.userid)
                                            .doc(widget.activity.id)
                                            .update({"activities": act});

                                        setState(() {});
                                      }
                                    },
                                    icon: Icon(
                                        edittext ? Icons.edit : Icons.done))
                              ],
                            ),
                          ),
                          // Text(
                          //   ('${widget.activity.daylistdone.length}/${widget.activity.daylist.length}'),
                          //   maxLines: 1,
                          //   style: const TextStyle(
                          //     color: Colors.black,
                          //     fontSize: 12.0,
                          //     fontWeight: FontWeight.w700,
                          //   ),
                          // ),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.close_rounded,
                                        size: 24, color: Colors.black))
                              ])),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChipsChoice<String>.multiple(
                            value: widget.activity.daylistdone,
                            choiceStyle: C2ChipStyle.outlined(
                              padding: const EdgeInsets.all(4),
                              color: GortAppTheme.darkText,
                              borderWidth: 2,
                              foregroundStyle: const TextStyle(fontSize: 15),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(25)),
                              selectedStyle:
                                  C2ChipStyle.filled(color: Colors.green),
                            ),
                            onChanged: (List<String> val) async {
                              if (subscribeStatus == false) {
                                _showInterstitialAd();
                              }

                              /// First take a list of activities
                              final List<Map<String, dynamic>> act = [];
                              // start a loop and update stuff
                              for (int i = 0;
                                  i < widget.listActivities.length;
                                  i++) {
                                // now check if current index is equal to loop index
                                if (i == widget.index) {
                                  act.add({
                                    'title': widget.activity.title,
                                    'days': widget.activity.daylist,
                                    'notificationidnumber':
                                        widget.activity.notificationidnumber,
                                    'daysdone': val,
                                    'timelist': widget.activity.timelist,
                                    'weekdaysdone':
                                        widget.activity.weekdaysdone,
                                    'weekdaysnotdone':
                                        widget.activity.weekdaysnotdone,
                                    'time': widget.activity.time
                                  });
                                } else {
                                  act.add({
                                    'title': widget.listActivities[i].title,
                                    'days': widget.listActivities[i].daylist,
                                    'notificationidnumber': widget
                                        .listActivities[i].notificationidnumber,
                                    'daysdone':
                                        widget.listActivities[i].daylistdone,
                                    'weekdaysdone':
                                        widget.listActivities[i].weekdaysdone,
                                    'weekdaysnotdone': widget
                                        .listActivities[i].weekdaysnotdone,
                                    'timelist':
                                        widget.listActivities[i].timelist,
                                    'time': widget.listActivities[i].time
                                  });
                                }
                              }

                              await FirebaseFirestore.instance
                                  .collection(widget.userid)
                                  .doc(widget.activity.id)
                                  .update({"activities": act});

                              setState(() {});
                            },
                            choiceItems: C2Choice.listFrom<String, String>(
                              source: frequencyButtons,
                              value: (i, v) => i.toString(),
                              label: (i, v) {
                                return frequencyButtons[i];
                              },
                              disabled: (i, v) {
                                var daylist = widget.activity.daylist;
                                return daylist
                                        .where((element) =>
                                            i == int.parse(element) - 1)
                                        .isEmpty
                                    ? true
                                    : false;
                              },
                              // disabled: (i, v) => [1, 4].contains(i),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 25, left: 15, right: 15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Add reminder',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              GortAppTheme.darkText),
                                    ),
                                    onPressed: () async {
                                      var time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now());

                                      if (time != null) {
                                        setState(() {
                                          // notificationTimes.add(pickedTime);
                                          updatedtimelist
                                              .add(time.format(context));
                                          // DateTime parsedTime = DateFormat.jm()
                                          //     .parse(pickedTime
                                          //         .format(context)
                                          //         .toString());
                                          // notificationTimesToString
                                          //     .add(parsedTime.toString());
                                        });

                                        for (var day
                                            in widget.activity.daylist) {
                                          createReminderNotification(
                                              widget.activity.id,
                                              widget.activity.title,
                                              widget.activity
                                                      .notificationidnumber +
                                                  int.parse(day +
                                                      time
                                                          .format(context)
                                                          .replaceAll(
                                                              RegExp(r':'),
                                                              '')),
                                              widget.activity.id,
                                              widget.activity.id +
                                                  widget.activity.title,
                                              NotificationWeekAndTime(
                                                dayOfTheWeek: int.parse(day),
                                                timeOfDay: time,
                                              ));
                                        }

                                        final List<Map<String, dynamic>> act =
                                            [];
                                        // start a loop and update stuff
                                        for (int i = 0;
                                            i < widget.listActivities.length;
                                            i++) {
                                          // now check if current index is equal to loop index
                                          if (i == widget.index) {
                                            act.add({
                                              'title': widget.activity.title,
                                              'days': widget.activity.daylist,
                                              'notificationidnumber': widget
                                                  .activity
                                                  .notificationidnumber,
                                              'daysdone':
                                                  widget.activity.daylistdone,
                                              'weekdaysdone':
                                                  widget.activity.weekdaysdone,
                                              'weekdaysnotdone': widget
                                                  .activity.weekdaysnotdone,
                                              'timelist': updatedtimelist,
                                              'time': widget.activity.time
                                            });
                                          } else {
                                            act.add({
                                              'title': widget
                                                  .listActivities[i].title,
                                              'days': widget
                                                  .listActivities[i].daylist,
                                              'notificationidnumber': widget
                                                  .listActivities[i]
                                                  .notificationidnumber,
                                              'daysdone': widget
                                                  .listActivities[i]
                                                  .daylistdone,
                                              'weekdaysdone': widget
                                                  .listActivities[i]
                                                  .weekdaysdone,
                                              'weekdaysnotdone': widget
                                                  .listActivities[i]
                                                  .weekdaysnotdone,
                                              'timelist': widget
                                                  .listActivities[i].timelist,
                                              'time':
                                                  widget.listActivities[i].time
                                            });
                                          }
                                        }

                                        await FirebaseFirestore.instance
                                            .collection(widget.userid)
                                            .doc(widget.activity.id)
                                            .update({"activities": act});
                                        setState(() {});
                                      } else {}
                                    },
                                  ),
                                  ElevatedButton.icon(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              GortAppTheme.darkText),
                                    ),
                                    onPressed: () async {
                                      Dialogs.materialDialog(
                                          msg: '',
                                          title: "Change Days",
                                          color: Colors.white,
                                          context: context,
                                          customViewPosition: CustomViewPosition
                                              .BEFORE_MESSAGE,
                                          customView: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: MultiSelectContainer(
                                                  textStyles:
                                                      const MultiSelectTextStyles(
                                                          selectedTextStyle:
                                                              TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                          textStyle: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black)),
                                                  itemsDecoration:
                                                      MultiSelectDecorations(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        border: Border.all(
                                                            color: Colors.black,
                                                            width: 2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    selectedDecoration:
                                                        BoxDecoration(
                                                            gradient:
                                                                const LinearGradient(
                                                                    colors: [
                                                                  Colors
                                                                      .blueAccent,
                                                                  Colors
                                                                      .blueAccent
                                                                ]),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                    disabledDecoration:
                                                        BoxDecoration(
                                                            color: Colors.grey,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey[500]),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                  ),
                                                  items: [
                                                    MultiSelectCard(
                                                        value: '1', label: 'M'),
                                                    MultiSelectCard(
                                                        value: '2', label: 'T'),
                                                    MultiSelectCard(
                                                        value: '3', label: 'O'),
                                                    MultiSelectCard(
                                                        value: '4', label: 'T'),
                                                    MultiSelectCard(
                                                        value: '5', label: 'F'),
                                                    MultiSelectCard(
                                                        value: '6', label: 'L'),
                                                    MultiSelectCard(
                                                        value: '7', label: 'S'),
                                                  ],
                                                  onChange: (allSelectedItems,
                                                      selectedItem) {
                                                    myData2 = allSelectedItems;
                                                    myData2.sort();
                                                  })),
                                          actions: [
                                            IconsOutlineButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              text: 'Cancel',
                                              iconData: Icons.cancel_outlined,
                                              textStyle: const TextStyle(
                                                  color: Colors.grey),
                                              iconColor: Colors.grey,
                                            ),
                                            IconsOutlineButton(
                                              onPressed: () async {
                                                await cancelAllGroupScheduledNotifications(
                                                    widget.activity.id +
                                                        widget.activity.title);
                                                final List<Map<String, dynamic>>
                                                    act = [];
                                                // start a loop and update stuff
                                                for (int i = 0;
                                                    i <
                                                        widget.listActivities
                                                            .length;
                                                    i++) {
                                                  // now check if current index is equal to loop index
                                                  if (i == widget.index) {
                                                    act.add({
                                                      'title':
                                                          widget.activity.title,
                                                      'days': myData2,
                                                      'notificationidnumber': widget
                                                          .activity
                                                          .notificationidnumber,
                                                      'daysdone': myData3,
                                                      'weekdaysdone': widget
                                                          .activity
                                                          .weekdaysdone,
                                                      'weekdaysnotdone': widget
                                                          .activity
                                                          .weekdaysnotdone,
                                                      'timelist': widget
                                                          .activity.timelist,
                                                      'time':
                                                          widget.activity.time
                                                    });
                                                  } else {
                                                    act.add({
                                                      'title': widget
                                                          .listActivities[i]
                                                          .title,
                                                      'days': widget
                                                          .listActivities[i]
                                                          .daylist,
                                                      'notificationidnumber': widget
                                                          .listActivities[i]
                                                          .notificationidnumber,
                                                      'daysdone': widget
                                                          .listActivities[i]
                                                          .daylistdone,
                                                      'timelist': widget
                                                          .listActivities[i]
                                                          .timelist,
                                                      'weekdaysdone': widget
                                                          .listActivities[i]
                                                          .weekdaysdone,
                                                      'weekdaysnotdone': widget
                                                          .listActivities[i]
                                                          .weekdaysnotdone,
                                                      'time': widget
                                                          .listActivities[i]
                                                          .time
                                                    });
                                                  }
                                                }

                                                await FirebaseFirestore.instance
                                                    .collection(widget.userid)
                                                    .doc(widget.activity.id)
                                                    .update(
                                                        {"activities": act});

                                                setState(() {});
                                                if (!mounted) return;
                                                Navigator.pop(context);

                                                await Future.delayed(
                                                    const Duration(seconds: 2),
                                                    () {});
                                                for (var day in widget
                                                    .activity.daylist) {
                                                  for (var time in widget
                                                      .activity.timelist) {
                                                    createReminderNotification(
                                                        widget.activity.id,
                                                        widget.activity.title,
                                                        widget.activity
                                                                .notificationidnumber +
                                                            int.parse(day +
                                                                time.replaceAll(
                                                                    RegExp(
                                                                        r':'),
                                                                    '')),
                                                        widget.activity.id,
                                                        widget.activity.id +
                                                            widget
                                                                .activity.title,
                                                        NotificationWeekAndTime(
                                                          dayOfTheWeek:
                                                              int.parse(day),
                                                          timeOfDay: TimeOfDay(
                                                              hour: int.parse(
                                                                  time.split(
                                                                      ":")[0]),
                                                              minute: int.parse(
                                                                  time.split(
                                                                      ":")[1])),
                                                        ));
                                                  }
                                                  setState(() {});
                                                }
                                              },
                                              text: 'Save',
                                              iconData: Icons.check,
                                              color: Colors.green,
                                              textStyle: const TextStyle(
                                                  color: Colors.white),
                                              iconColor: Colors.white,
                                            ),
                                          ]);
                                    },

                                    icon: const Icon(
                                      Icons.settings,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Change days',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ), // <-- Text
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     IconButton(
                              //         onPressed: () {}, icon: Icon(Icons.settings))
                              //   ],
                              // ),

                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 10),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: widget.activity.timelist.length,
                                    itemBuilder: (BuildContext ctx, int index) {
                                      return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: ListTile(
                                                  leading: Text(
                                                      widget.activity.timelist
                                                          .elementAt(index),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                      )),
                                                  trailing: IconButton(
                                                    onPressed: () async {
                                                      await cancelAllGroupScheduledNotifications(
                                                          widget.activity.id +
                                                              widget.activity
                                                                  .title);

                                                      updatedtimelist
                                                          .removeAt(index);
                                                      for (var day in widget
                                                          .activity.daylist) {
                                                        for (var time
                                                            in updatedtimelist) {
                                                          createReminderNotification(
                                                              widget
                                                                  .activity.id,
                                                              widget.activity
                                                                  .title,
                                                              widget.activity
                                                                      .notificationidnumber +
                                                                  int.parse(day +
                                                                      time.replaceAll(
                                                                          RegExp(
                                                                              r':'),
                                                                          '')),
                                                              widget
                                                                  .activity.id,
                                                              widget.activity
                                                                      .id +
                                                                  widget
                                                                      .activity
                                                                      .title,
                                                              NotificationWeekAndTime(
                                                                dayOfTheWeek:
                                                                    int.parse(
                                                                        day),
                                                                timeOfDay: TimeOfDay(
                                                                    hour: int.parse(
                                                                        time.split(":")[
                                                                            0]),
                                                                    minute: int.parse(
                                                                        time.split(
                                                                            ":")[1])),
                                                              ));
                                                        }
                                                        setState(() {});
                                                      }

                                                      final List<
                                                              Map<String,
                                                                  dynamic>>
                                                          act = [];
                                                      // start a loop and update stuff
                                                      for (int i = 0;
                                                          i <
                                                              widget
                                                                  .listActivities
                                                                  .length;
                                                          i++) {
                                                        // now check if current index is equal to loop index
                                                        if (i == widget.index) {
                                                          act.add({
                                                            'title': widget
                                                                .activity.title,
                                                            'days': widget
                                                                .activity
                                                                .daylist,
                                                            'notificationidnumber':
                                                                widget.activity
                                                                    .notificationidnumber,
                                                            'daysdone': widget
                                                                .activity
                                                                .daylistdone,
                                                            'weekdaysdone': widget
                                                                .activity
                                                                .weekdaysdone,
                                                            'weekdaysnotdone':
                                                                widget.activity
                                                                    .weekdaysnotdone,
                                                            'timelist':
                                                                updatedtimelist,
                                                            'time': widget
                                                                .activity.time
                                                          });
                                                        } else {
                                                          act.add({
                                                            'title': widget
                                                                .listActivities[
                                                                    i]
                                                                .title,
                                                            'days': widget
                                                                .listActivities[
                                                                    i]
                                                                .daylist,
                                                            'notificationidnumber': widget
                                                                .listActivities[
                                                                    i]
                                                                .notificationidnumber,
                                                            'daysdone': widget
                                                                .listActivities[
                                                                    i]
                                                                .daylistdone,
                                                            'timelist': widget
                                                                .listActivities[
                                                                    i]
                                                                .timelist,
                                                            'weekdaysdone': widget
                                                                .listActivities[
                                                                    i]
                                                                .weekdaysdone,
                                                            'weekdaysnotdone': widget
                                                                .listActivities[
                                                                    i]
                                                                .weekdaysnotdone,
                                                            'time': widget
                                                                .listActivities[
                                                                    i]
                                                                .time
                                                          });
                                                        }
                                                      }

                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              widget.userid)
                                                          .doc(widget
                                                              .activity.id)
                                                          .update({
                                                        "activities": act
                                                      });

                                                      setState(() {});
                                                    },
                                                    icon: const Icon(
                                                      Icons.delete_rounded,
                                                      color: Colors.red,
                                                    ),
                                                  ))));
                                    },
                                  )),
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: CalendarPage2(
                                    presentDates: widget.activity.weekdaysdone,
                                    absentDates:
                                        widget.activity.weekdaysnotdone,
                                  )),
                            ],
                          )),
                    ],
                  ));
                },
              );
            },
          );
          setState(() {
            expanded = !expanded;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: GortAppTheme.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: GortAppTheme.grey.withOpacity(0.2),
                  offset: const Offset(1.1, 1.1),
                  blurRadius: 10.0),
            ],
          ),
          height: containerHeight,
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 30.0),
                        ),
                        Flexible(
                          child: Text(
                            widget.activity.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ('${widget.activity.daylistdone.length}/${widget.activity.daylist.length}'),
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Icon(
                            expanded == true
                                ? Icons.keyboard_arrow_right
                                : Icons.keyboard_arrow_right,
                            size: 24,
                            color: expanded == false
                                ? Colors.black
                                : Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
              ChipsChoice<String>.multiple(
                value: widget.activity.daylistdone,
                choiceStyle: C2ChipStyle.outlined(
                  padding: const EdgeInsets.all(4),
                  color: GortAppTheme.darkText,
                  borderWidth: 2,
                  foregroundStyle: const TextStyle(fontSize: 15),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  selectedStyle: C2ChipStyle.filled(color: Colors.green),
                ),
                onChanged: (List<String> val) {
                  if (subscribeStatus == false) {
                    _showInterstitialAd();
                  }

                  /// First take a list of activities
                  final List<Map<String, dynamic>> act = [];
                  // start a loop and update stuff
                  for (int i = 0; i < widget.listActivities.length; i++) {
                    // now check if current index is equal to loop index
                    if (i == widget.index) {
                      act.add({
                        'title': widget.activity.title,
                        'days': widget.activity.daylist,
                        'notificationidnumber':
                            widget.activity.notificationidnumber,
                        'daysdone': val,
                        'timelist': widget.activity.timelist,
                        'weekdaysdone': widget.activity.weekdaysdone,
                        'weekdaysnotdone': widget.activity.weekdaysnotdone,
                        'time': widget.activity.time
                      });
                    } else {
                      act.add({
                        'title': widget.listActivities[i].title,
                        'days': widget.listActivities[i].daylist,
                        'notificationidnumber':
                            widget.listActivities[i].notificationidnumber,
                        'daysdone': widget.listActivities[i].daylistdone,
                        'weekdaysdone': widget.listActivities[i].weekdaysdone,
                        'weekdaysnotdone':
                            widget.listActivities[i].weekdaysnotdone,
                        'timelist': widget.listActivities[i].timelist,
                        'time': widget.listActivities[i].time
                      });
                    }
                  }

                  FirebaseFirestore.instance
                      .collection(widget.userid)
                      .doc(widget.activity.id)
                      .update({"activities": act});
                },
                choiceItems: C2Choice.listFrom<String, String>(
                  source: frequencyButtons,
                  value: (i, v) => i.toString(),
                  label: (i, v) {
                    return frequencyButtons[i];
                  },
                  disabled: (i, v) {
                    var daylist = widget.activity.daylist;
                    return daylist
                            .where((element) => i == int.parse(element) - 1)
                            .isEmpty
                        ? true
                        : false;
                  },
                  // disabled: (i, v) => [1, 4].contains(i),
                ),
              ),
            ],
          ),
        ));
  }
}

class CalendarPage2 extends StatefulWidget {
  final List<Timestamp> presentDates;
  final List<Timestamp> absentDates;

  const CalendarPage2({Key key, this.presentDates, this.absentDates})
      : super(key: key);

  @override
  CalendarPage2State createState() => CalendarPage2State();
}

List<Timestamp> presentDates = [];
List<Timestamp> absentDates = [];

class CalendarPage2State extends State<CalendarPage2> {
  static Widget _presentIcon(String day) => CircleAvatar(
        backgroundColor: Colors.green,
        child: Text(
          day,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );
  static Widget _absentIcon(String day) => CircleAvatar(
        backgroundColor: Colors.red,
        child: Text(
          day,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );

  final EventList<Event> _markedDateMap = EventList<Event>(
    events: {},
  );

  @override
  Widget build(BuildContext context) {
    presentDates = widget.presentDates;
    absentDates = widget.absentDates;
    for (int i = 0; i < presentDates.length; i++) {
      setState(() {
        _markedDateMap.add(
          presentDates[i].toDate(),
          Event(
            date: presentDates[i].toDate(),
            title: 'Event 5',
            icon: _presentIcon(
              presentDates[i].toDate().day.toString(),
            ),
          ),
        );
      });
    }

    for (int i = 0; i < absentDates.length; i++) {
      setState(() {
        _markedDateMap.add(
          absentDates[i].toDate(),
          Event(
            date: absentDates[i].toDate(),
            title: 'Event 5',
            icon: _absentIcon(
              absentDates[i].toDate().day.toString(),
            ),
          ),
        );
      });
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CalendarCarousel<Event>(
            isScrollable: false,
            pageScrollPhysics: const NeverScrollableScrollPhysics(),
            height: MediaQuery.of(context).size.height * 0.62,
            todayButtonColor: Colors.blue[200],
            markedDatesMap: _markedDateMap,
            markedDateShowIcon: true,
            markedDateIconMaxShown: 1,
            firstDayOfWeek: 1,
            // daysTextStyle: TextStyle(color: Colors.white),
            // weekdayTextStyle: TextStyle(color: Colors.black87),
            // nextDaysTextStyle: TextStyle(color: Colors.white),
            // prevDaysTextStyle: TextStyle(color: Colors.white),
            // weekendTextStyle: const TextStyle(color: Colors.white),
            markedDateMoreShowTotal:
                null, // null for not showing hidden events indicator
            markedDateIconBuilder: (event) {
              return event.icon;
            },
          )
        ],
      ),
    );
  }
}
