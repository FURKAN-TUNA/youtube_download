import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path/path.dart' as path;
// import 'package:flutter_youtube_view/flutter_youtube_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState("https://www.youtube.com/");
}

class _HomePageState extends State<HomePage> {
  var url = "https://www.youtube.com/";
  bool a;
  String currentUrl;
  String videoUrl = "https://m.youtube.com/watch?v";
  final key = UniqueKey();
  _HomePageState(this.url);
  WebViewController controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      a = true;
    });
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  void fonk() async {
    var tempUrl = await controller.currentUrl();
    if (tempUrl.length >= 29) {
      if (tempUrl.substring(0, 29) == videoUrl) {
        Alert(
            context: context,
            style: AlertStyle(),
            title: "Ne olarak inecek",
            buttons: [
              DialogButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.video_call), Text("Video")],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    currentUrl = tempUrl;
                  });
                  var yt = YoutubeExplode();
                  var video = await yt.videos.get(currentUrl);
                  var title = video.title;
                  var duration = video.duration;
                  var videoId = video.id;
                  // print(currentUrl +
                  //     " " +
                  //     title +
                  //     " " +
                  //     duration.toString());
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            'Title: ${video.title}, Duration: ${video.duration}'),
                      );
                    },
                  );
                  await Permission.storage.request();
                  var manifest =
                      await yt.videos.streamsClient.getManifest(videoId);
                  var v = manifest.muxed.withHighestBitrate();

                  var audio = manifest.audioOnly.last;
                  var dir = await DownloadsPathProvider.downloadsDirectory;
                  var filePath = path.join(dir.uri.toFilePath(),
                      '${video.title}.${v.container.name}');
                  var file = File(filePath);
                  var fileStream = file.openWrite();
                  await yt.videos.streamsClient.get(v).pipe(fileStream);
                  await fileStream.flush();
                  await fileStream.close();

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            'Download completed and saved to: ${filePath}'),
                      );
                    },
                  );
                },
              ),
              DialogButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.music_note), Text("Müzik")],
                ),
                onPressed: () async {
                  var tempUrl = await controller.currentUrl();
                  Navigator.pop(context);
                  setState(() {
                    currentUrl = tempUrl;
                  });
                  var yt = YoutubeExplode();
                  var video = await yt.videos.get(currentUrl);
                  var title = video.title;
                  var duration = video.duration;
                  var videoId = video.id;
                  // print(currentUrl +
                  //     " " +
                  //     title +
                  //     " " +
                  //     duration.toString());
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            'Title: ${video.title}, Duration: ${video.duration}'),
                      );
                    },
                  );
                  await Permission.storage.request();
                  var manifest =
                      await yt.videos.streamsClient.getManifest(videoId);
                  var v = manifest.audioOnly.withHighestBitrate();

                  var audio = manifest.audioOnly.last;
                  var dir = await DownloadsPathProvider.downloadsDirectory;
                  var filePath =
                      path.join(dir.uri.toFilePath(), '${video.title}.mp3');
                  var file = File(filePath);
                  var fileStream = file.openWrite();
                  await yt.videos.streamsClient.get(v).pipe(fileStream);
                  await fileStream.flush();
                  await fileStream.close();

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            'Download completed and saved to: ${filePath}'),
                      );
                    },
                  );
                },
              )
            ]).show();
      }
    } else {
      Alert(
        context: context,
        style: AlertStyle(),
        title: "Video açık değil",
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Stack(
      children: <Widget>[
        Scaffold(
          body: WebView(
            key: key,
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              controller = webViewController;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 50, left: 15),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              tooltip: 'Geri',
              child: Icon(Icons.rotate_left_outlined),
              backgroundColor: Colors.cyanAccent,
              onPressed: () => {controller.goBack()},
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 50, right: 15),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              tooltip: 'İndir',
              child: Icon(Icons.download_sharp),
              backgroundColor: Colors.green,
              onPressed: fonk,
            ),
          ),
        ),
      ],
    );
  }
}
