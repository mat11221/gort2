//@dart=2.1

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:gort/ui/notification.dart';
import 'package:gort/ui/utilities.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:async';

class ActivityPage extends StatefulWidget {
  final User user;
  final Color color;
  final String documentName;

  const ActivityPage({Key key, this.user, this.documentName, this.color})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  TextEditingController itemController = TextEditingController();
  TextEditingController listNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            backgroundColor: currentColor,
            body: Container(
                decoration: BoxDecoration(color: currentColor),
                child: ListView(
                  children: [
                    _getToolbar(context),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 0.0, left: 20.0, right: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(
                                        'New Activity',
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 50.0, left: 20.0, right: 20.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: const [
                                    Text(
                                      'Title',
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
                                TextFormField(
                                  decoration: InputDecoration(
                                      fillColor: Colors.black,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          borderSide: const BorderSide(
                                              color: Colors.teal)),
                                      labelText: "Activity name",
                                      errorText: _validate
                                          ? 'Please enter a name'
                                          : null,
                                      contentPadding: const EdgeInsets.only(
                                          left: 16.0,
                                          top: 20.0,
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
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0, left: 0.0, right: 0.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: const [
                                            Text(
                                              'Target day',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: MultiSelectContainer(
                                        textStyles: const MultiSelectTextStyles(
                                            selectedTextStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        itemsDecoration: MultiSelectDecorations(
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          selectedDecoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    Colors.white
                                                  ]),
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          disabledDecoration: BoxDecoration(
                                              color: Colors.grey,
                                              border: Border.all(
                                                  color: Colors.grey[500]),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
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
                                        onChange:
                                            (allSelectedItems, selectedItem) {
                                          myData2 = allSelectedItems;
                                          // myData3 = List.from(Set.from(
                                          //         frequencyButtons)
                                          //     .difference(
                                          //         Set.from(allSelectedItems)));
                                          selectedNotificationDays =
                                              allSelectedItems;
                                          myData2.sort();
                                          // myData3.sort();
                                        })),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 0, left: 0, top: 40),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        'Reminder chosen days at',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          size: 24.0,
                                          color: Colors.black,
                                        ),
                                        label: const Text(
                                          'Add reminder',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                        ),
                                        onPressed: () async {
                                          var time = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now());

                                          if (time != null) {
                                            setState(() {
                                              notificationTimes.add(time);
                                              notificationTimesToString
                                                  .add(time.format(context));
                                            });
                                          }
                                        })
                                  ],
                                ),
                                notificationTimes.isNotEmpty
                                    ? ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext ctx, int index) {
                                          return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color
                                                              .fromARGB(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  255),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                  child: ListTile(
                                                      leading: Text(
                                                          notificationTimes
                                                              .elementAt(index)
                                                              .format(context),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    0,
                                                                    0,
                                                                    0),
                                                          )),
                                                      trailing: IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            notificationTimes
                                                                .removeAt(
                                                                    index);
                                                            notificationTimesToString
                                                                .removeAt(
                                                                    index);
                                                          });
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete_rounded,
                                                          color: Colors.red,
                                                        ),
                                                      ))));
                                        },
                                        itemCount: notificationTimes.length,
                                      )
                                    : Container(),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 80.0),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              if (myData2.isNotEmpty) {
                                                for (var i = 0;
                                                    i <
                                                        selectedNotificationDays
                                                            .length;
                                                    i++) {}
                                                addToFirebase();

                                                listNameController.text.isEmpty
                                                    ? _validate = true
                                                    : _validate = false;
                                              }
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
                                                'Save activity',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (_isBannerAdReady &&
                                            subscribeStatus == false)
                                          SizedBox(
                                            width:
                                                _bannerAd.size.width.toDouble(),
                                            height: _bannerAd.size.height
                                                .toDouble(),
                                            child: AdWidget(ad: _bannerAd),
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ))
                      ],
                    )
                  ],
                ))));
  }

  void addToFirebase() async {
    setState(() {});

    if (_connectionStatus == "ConnectivityResult.none") {
      showInSnackBar("Ingen internetanslutning");
      setState(() {});
    } else {
      bool isExist = false;

      final QuerySnapshot<Map<String, dynamic>> query =
          await FirebaseFirestore.instance.collection(widget.user.uid).get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in query.docs) {
        if (listNameController.text.toString() == doc.id) {
          isExist = true;
        }
      }

      if (isExist == false && listNameController.text.isNotEmpty) {
        notificationidnumber = createUniqueId();
        FirebaseFirestore.instance
            .collection(widget.user.uid)
            .doc(documentName)
            .update({
          "activities": FieldValue.arrayUnion([
            {
              'title': listNameController.text,
              'days': myData2,
              'weekdaysdone': presentDates,
              'weekdaysnotdone': absentDates,
              'notificationidnumber': notificationidnumber,
              'daysdone': myData22,
              'time': (DateFormat('HH:mm').format(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  selectedTime.hour,
                  selectedTime.minute))),
              'timelist': notificationTimesToString,
            },
          ]),
        });

        if (notificationTimes.isNotEmpty) {
          for (var selectedDay in selectedNotificationDays) {
            for (var reminder in notificationTimes) {
              var hrstring = reminder.hour.toString();
              var mrstring = reminder.minute.toString();
              var uniqid = int.parse(selectedDay + hrstring + mrstring);
              createReminderNotification(
                  documentName,
                  listNameController.text.toString(),
                  notificationidnumber + uniqid,
                  documentName,
                  documentName + listNameController.text.toString(),
                  NotificationWeekAndTime(
                    dayOfTheWeek: int.parse(selectedDay),
                    timeOfDay: reminder,
                  ));
            }
          }
        }

        listNameController.clear();
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

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();

  Future initConnectivity() async {
    String connectionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException {
      connectionStatus = 'Failed to get connectivity.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
  }

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

  @override
  void dispose() {
    super.dispose();
    // _inlineBannerAd.dispose();
    // _interstitialAd.dispose();
  }

  BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  // final _inlineAdIndex = 3;

  // BannerAd _inlineBannerAd;

  // bool _isInlineBannerAdLoaded = false;

  List<DateTime> presentDates = [];
  List<DateTime> absentDates = [];

  List<String> selectedNotificationDays = [];
  List<String> myData2 = [];
  List<String> myData3 = [];
  List<String> myData22 = [];

  final values1 = List.filled(7, true);
  List<Map<String, dynamic>> myData = [];
  String documentName;
  List<NotificationWeekAndTime> notificationtimelist = [];
  List<int> notificationidlist = [];
  List<String> notificationrubriklist = [];
  List<String> notificationbeskrivninglist = [];
  List<TimeOfDay> notificationTimes = [];
  List<String> notificationTimesToString = [];
  bool _validate = false;

  bool isSwitched = false;
  bool showcontent = true;
  bool showsettings = false;
  bool subscribeStatus = false;

  int notificationidnumber;

  TimeOfDay remindertime = TimeOfDay.fromDateTime(DateTime.now());
  List<int> timeindex = [];

  void showInSnackBar(String value) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(value),
    // ));
  }

  @override
  void initState() {
    super.initState();
    checkSubscription();
    // _createInterstitialAd();
    documentName = (widget.documentName);
    currentColor = widget.color;
  }

  TimeOfDay selectedTime = TimeOfDay.now();

  Color pickerColor;
  Color currentColor;
  List<String> frequencyButtons = ["1", "2", "3", "4", "5", "6", "7"];

  Padding _getToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 12.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            size: 40.0,
            color: Colors.black,
          ),
        ),
        GestureDetector(
            onTap: () {
              if (showsettings == false) {
                setState(() {
                  showsettings = true;
                  showcontent = false;
                });
              } else if (showsettings == true) {
                setState(() {
                  showsettings = false;
                  showcontent = true;
                });
              }
            },
            child: Container())
      ]),
    );
  }
}
