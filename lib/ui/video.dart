import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class VideoPlay extends StatefulWidget {
  String? pathh;

  @override
  VideoPlayState createState() => VideoPlayState();

  VideoPlay({
    Key? key,
    this.pathh, // Video from assets folder
  }) : super(key: key);
}

class VideoPlayState extends State<VideoPlay> {
  ValueNotifier<VideoPlayerValue?> currentPosition = ValueNotifier(null);
  VideoPlayerController? controller;
  late Future<void> futureController;

  initVideo() {
    controller = VideoPlayerController.network(widget.pathh!);

    futureController = controller!.initialize();
  }

  @override
  void initState() {
    initVideo();
    controller!.addListener(() {
      if (controller!.value.isInitialized) {
        currentPosition.value = controller!.value;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureController,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.3,
                child: Stack(children: [
                  Positioned.fill(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: VideoPlayer(controller!))),
                  Positioned.fill(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: IconButton(
                                    icon: Icon(
                                      controller!.value.isPlaying
                                          ? Icons.pause_circle
                                          : Icons.play_circle,
                                      color: controller!.value.isPlaying
                                          ? Colors.transparent
                                          : Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (controller!.value.isPlaying) {
                                          controller!.pause();
                                        } else {
                                          controller!.play();
                                        }
                                      });
                                    },
                                  )),
                            ],
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: ValueListenableBuilder(
                                  valueListenable: currentPosition,
                                  builder: (context,
                                      VideoPlayerValue? videoPlayerValue, w) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    );
                                  }),
                            ))
                      ],
                    ),
                  ),
                ])),
          );
        }
      },
    );
  }
}

// ignore: must_be_immutable
class VideoFilePlay extends StatefulWidget {
  File? pathh;

  @override
  VideoFilePlayState createState() => VideoFilePlayState();

  VideoFilePlay({
    Key? key,
    this.pathh, // Video from assets folder
  }) : super(key: key);
}

class VideoFilePlayState extends State<VideoFilePlay> {
  ValueNotifier<VideoPlayerValue?> currentPosition = ValueNotifier(null);
  VideoPlayerController? controller;
  late Future<void> futureController;

  initVideo() {
    controller = VideoPlayerController.file(widget.pathh!);

    futureController = controller!.initialize();
  }

  @override
  void initState() {
    initVideo();
    controller!.addListener(() {
      if (controller!.value.isInitialized) {
        currentPosition.value = controller!.value;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureController,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.3,
                child: Stack(children: [
                  Positioned.fill(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: VideoPlayer(controller!))),
                  Positioned.fill(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: IconButton(
                                    icon: Icon(
                                      controller!.value.isPlaying
                                          ? Icons.pause_circle
                                          : Icons.play_circle,
                                      color: controller!.value.isPlaying
                                          ? Colors.transparent
                                          : Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (controller!.value.isPlaying) {
                                          controller!.pause();
                                        } else {
                                          controller!.play();
                                        }
                                      });
                                    },
                                  )),
                            ],
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: ValueListenableBuilder(
                                  valueListenable: currentPosition,
                                  builder: (context,
                                      VideoPlayerValue? videoPlayerValue, w) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    );
                                  }),
                            ))
                      ],
                    ),
                  ),
                ])),
          );
        }
      },
    );
  }
}
