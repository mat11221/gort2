//@dart=2.1
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gort/gort_app_theme.dart';
import 'package:gort/utils/color_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gort/ui/utilities.dart';
import 'package:gort/ui/video.dart';
import 'package:gort/model/element.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:video_compress/video_compress.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as pt;

class NewTaskPage extends StatefulWidget {
  final User user;
  const NewTaskPage({Key key, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  io.File _image;
  String documentId;
  bool endDate = true;
  List<String> webimageList = [];
  List<String> webvideoList = [];
  List<XFile> imageFileListM = [];
  List<XFile> videoFileListM = [];
  List<ElementTask> listElement = [];

  List<Map<String, dynamic>> myData = [];
  final ImagePicker imagePicker = ImagePicker();
  final Map<String, List<ElementTask>> currentList = {};
  TextEditingController itemController = TextEditingController();
  TextEditingController listNameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String url =
      'https://firebasestorage.googleapis.com/v0/b/gort-668f0.appspot.com/o/placeholder.png?alt=media&token=08976534-a647-48fe-92e6-6b3ae81bcdd8';
  List<NotificationWeekAndTime> notificationtimelist = [];
  List<int> notificationidlist = [];
  List<String> notificationrubriklist = [];
  List<String> notificationbeskrivninglist = [];
  bool _validate = false;
  Color pickerColor = (Colors.blue);
  Color currentColor = Colors.blue;
  String currentDayIndex = DateFormat('yyyy-MM-dd').format(DateTime(
      DateTime.now().year, DateTime.now().month + 3, DateTime.now().day));
  String _selectedDate = DateFormat.yMMMMd("en_US").format(DateTime(
      DateTime.now().year, DateTime.now().month + 3, DateTime.now().day));
  bool _saving = false;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<void> _selectDate(BuildContext context) async {
    var datenow = DateTime.now();
    final DateTime d = await showRoundedDatePicker(
      theme: ThemeData(primarySwatch: currentColor),
      context: context,
      initialDate: DateTime(datenow.year, datenow.month + 3, datenow.day),
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (d != null) {
      setState(() {
        _selectedDate = DateFormat.yMMMMd("en_US").format(d);
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        final String formatted = formatter.format(d);
        currentDayIndex = formatted;
      });
    }
  }

  Future getImage() async {
    var image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 200,
        maxWidth: 200,
        imageQuality: 50);
    setState(() {
      _image = io.File(image.path);
    });
  }

  Future<List<String>> uploadFiles(List<XFile> images) async {
    var imageUrls = await Future.wait(images.map((image) => uploadFile(image)));
    webimageList.addAll(imageUrls);
    return imageUrls;
  }

  Future<String> uploadFile(XFile image) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('${widget.user.uid}/${image.path}');
    UploadTask uploadTask = storageReference.putFile(File(image.path));
    final TaskSnapshot downloadUrl = (await uploadTask);
    final linkurl = await downloadUrl.ref.getDownloadURL();
    return linkurl;
  }

  Future<List<String>> uploadVideoFiles(List<XFile> videos) async {
    var videoUrls = await Future.wait(videos.map((image) => uploadFile(image)));
    webvideoList.addAll(videoUrls);
    return videoUrls;
  }

  Future<String> uploadVideoFile(XFile video) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('${widget.user.uid}/${video.path}');
    UploadTask uploadTask = storageReference.putFile(File(video.path));
    final TaskSnapshot downloadUrl = (await uploadTask);
    final linkurl = await downloadUrl.ref.getDownloadURL();
    return linkurl;
  }

  void selectMImages() async {
    final List<XFile> selectedMImages = await imagePicker.pickMultiImage(
      maxWidth: 480,
      maxHeight: 640,
      imageQuality: 80,
    );
    if (selectedMImages.isNotEmpty) {
      imageFileListM.addAll(selectedMImages);
    }
    setState(() {});
  }

  void selectMVideo() async {
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

  Future uploadPic(String name) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child('${widget.user.uid}/$name');
    final UploadTask uploadTask = storageReference.putFile(_image);
    final TaskSnapshot downloadUrl = (await uploadTask);
    url = await downloadUrl.ref.getDownloadURL();
  }

  void addToFirebase() async {
    setState(() {
      _saving = true;
    });

    if (_connectionStatus == "ConnectivityResult.none") {
      showInSnackBar("Ingen internetanslutning");
      setState(() {
        _saving = false;
      });
    } else {
      bool isExist = false;
      QuerySnapshot query =
          await FirebaseFirestore.instance.collection(widget.user.uid).get();
      for (var doc in query.docs) {
        if (listNameController.text.toString() == doc.id) {
          isExist = true;
        }
      }

      if (isExist == false && listNameController.text.isNotEmpty) {
        if (_image != null) {
          await uploadPic(widget.user.uid +
              listNameController.text.toString().trim().replaceAll('/', 'ô'));
        }
        await uploadFiles(imageFileListM);
        await uploadVideoFiles(videoFileListM);
        await FirebaseFirestore.instance
            .collection(widget.user.uid)
            .doc(listNameController.text.toString().trim().replaceAll('/', 'ô'))
            .set({
          "color": currentColor.value.toString(),
          "date": DateTime.now().millisecondsSinceEpoch,
          "currentDayIndex": currentDayIndex,
          "webimagelist": webimageList,
          "webvideolist": webvideoList,
          "days": '30',
          "documentId": documentId,
          "activities": [],
          "currentweek": DateTime.now().weekOfYear.toString(),
          "imageurl": url,
          "endDate": endDate.toString(),
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
        setState(() {
          _saving = false;
        });
      }
      if (listNameController.text.isEmpty) {
        showInSnackBar("Please enter a name");
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
        theme: const PieTheme(
          pointerSize: 0,
          delayDuration: Duration.zero,
        ),
        child: Scaffold(
            extendBodyBehindAppBar: false,
            key: _scaffoldKey,
            body: ModalProgressHUD(
              inAsyncCall: _saving,
              child: Container(
                  decoration:
                      const BoxDecoration(color: GortAppTheme.background),
                  child: Stack(
                    children: <Widget>[
                      ListView(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, left: 20.0, right: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Icon(Icons.close,
                                      size: 40.0, color: GortAppTheme.darkText),
                                ),
                                const Text(
                                  'New Gört',
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30.0),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Icon(Icons.close,
                                      size: 40.0,
                                      color: GortAppTheme.background),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                      radius: 50,
                                      backgroundColor: GortAppTheme.darkText,
                                      child: ClipOval(
                                        child: SizedBox(
                                          width: 90.0,
                                          height: 90.0,
                                          child: (_image != null)
                                              ? Image.file(_image,
                                                  fit: BoxFit.fill)
                                              : Image.asset(
                                                  "assets/placeholder.png",
                                                  fit: BoxFit.fill),
                                        ),
                                      )),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 60, left: 55),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    onPressed: () {
                                      getImage();
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, left: 20.0, right: 20.0),
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
                                const SizedBox(height: 10),
                                TextFormField(
                                  decoration: InputDecoration(
                                      fillColor: Colors.black,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          borderSide: const BorderSide(
                                              color: Colors.teal)),
                                      labelText: "Gört name",
                                      errorText: _validate
                                          ? 'Value Can\'t Be Empty'
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
                                const SizedBox(height: 15),
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
                                const SizedBox(height: 10),
                                EasyColorPicker(
                                  selected: currentColor,
                                  colorSelectorSize: 40,
                                  colorSelectorBorderRadius: 20,
                                  onChanged: (color) =>
                                      setState(() => currentColor = color),
                                  key: null,
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  children: const [
                                    Text(
                                      'Target date',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      decoration: BoxDecoration(
                                          color: endDate == true
                                              ? currentColor
                                              : Colors.black12,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            InkWell(
                                              child: Text(_selectedDate,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255))),
                                              onTap: () {
                                                _selectDate(context);
                                              },
                                            ),
                                            Switch(
                                              value: endDate,
                                              onChanged: (value) {
                                                setState(() {
                                                  endDate = value;
                                                });
                                              },
                                              activeTrackColor:
                                                  Colors.lightGreenAccent,
                                              activeColor: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  children: const [
                                    Text(
                                      'Visualize your Gört success',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 100,
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        children: [
                                          ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder:
                                                (BuildContext ctx, int index) {
                                              return SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                  child: Card(
                                                    elevation: 0,
                                                    color: Colors.transparent,
                                                    surfaceTintColor:
                                                        Colors.transparent,
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0)),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Image.file(
                                                            File(imageFileListM[
                                                                    index]
                                                                .path),
                                                            fit:
                                                                BoxFit.contain),
                                                      ),
                                                    ),
                                                  ));
                                            },
                                            itemCount: imageFileListM.length,
                                          ),
                                          ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder:
                                                (BuildContext ctx, int index) {
                                              return SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                  child: Card(
                                                    elevation: 0,
                                                    color: Colors.transparent,
                                                    surfaceTintColor:
                                                        Colors.transparent,
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Image.network(
                                                            webimageList[index],
                                                            fit:
                                                                BoxFit.contain),
                                                      ),
                                                    ),
                                                  ));
                                            },
                                            itemCount: webimageList.length,
                                          ),
                                          ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemBuilder:
                                                (BuildContext ctx, int index) {
                                              return SizedBox(
                                                  height: 100,
                                                  width: 100,
                                                  child: VideoFilePlay(
                                                      pathh: File(
                                                          videoFileListM[index]
                                                              .path)));
                                            },
                                            itemCount: videoFileListM.length,
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
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                  decoration: BoxDecoration(
                                                      color: currentColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: PieMenu(
                                                    actions: [
                                                      PieAction(
                                                        tooltip: 'Photo',
                                                        onSelect: () {
                                                          selectMImages();
                                                        },
                                                        child: const Icon(
                                                            Icons.photo),
                                                      ),
                                                      PieAction(
                                                        buttonTheme:
                                                            const PieButtonTheme(
                                                                backgroundColor:
                                                                    Colors.red,
                                                                iconColor:
                                                                    Colors
                                                                        .white),
                                                        tooltip: 'Video',
                                                        onSelect: () {
                                                          selectMVideo();
                                                        },
                                                        child: const Icon(Icons
                                                            .video_camera_back),
                                                      ),
                                                      PieAction(
                                                        buttonTheme:
                                                            const PieButtonTheme(
                                                                backgroundColor:
                                                                    Color
                                                                        .fromRGBO(
                                                                            76,
                                                                            175,
                                                                            80,
                                                                            1),
                                                                iconColor: Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        1)),
                                                        tooltip: 'Search',
                                                        onSelect: () {
                                                          _navigateAndDisplaySelection(
                                                              context);
                                                        },
                                                        child: const Icon(
                                                            Icons.search),
                                                      ),
                                                      PieAction(
                                                        buttonTheme:
                                                            const PieButtonTheme(
                                                                backgroundColor:
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            134,
                                                                            28),
                                                                iconColor: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255)),
                                                        tooltip: 'Search AI',
                                                        onSelect: () {
                                                          _navigateAndDisplaySelectionai(
                                                              context);
                                                        },
                                                        child: const Icon(
                                                            Icons.search_off),
                                                      ),
                                                    ],
                                                    child: const Icon(
                                                        Icons.add_a_photo,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              )),
                                        ],
                                      )),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      listNameController.text.isEmpty
                                          ? _validate = true
                                          : _validate = false;
                                      addToFirebase();
                                      setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: currentColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        elevation: 15.0),
                                    child: const Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Text('Create Gört',
                                          style: TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10)
                        ],
                      ),
                    ],
                  )),
            )));
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {}

  Future<void> _navigateAndDisplaySelectionai(BuildContext context) async {}

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

  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result.toString();
      });
    });
    documentId = createUniqueId().toString();
  }

  void showInSnackBar(String value) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(value),
    // )
    // );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, left: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 231, 231, 231),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(13.0),
                    bottomLeft: Radius.circular(13.0),
                    topLeft: Radius.circular(13.0),
                    topRight: Radius.circular(13.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: TextFormField(
                          style: const TextStyle(
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromARGB(255, 82, 82, 82),
                          ),
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Gört name',
                            border: InputBorder.none,
                            helperStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: GortAppTheme.lightText,
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.2,
                              color: GortAppTheme.lightText,
                            ),
                          ),
                          onEditingComplete: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
