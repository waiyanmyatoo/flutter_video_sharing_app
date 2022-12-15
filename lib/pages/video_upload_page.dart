import 'dart:ui';

import 'package:better_video_player/better_video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_sharing_app/providers.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoUploadPage extends ConsumerStatefulWidget {
  const VideoUploadPage({super.key, this.pickedVideoPath});

  final String? pickedVideoPath;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VideoUploadPageState();
}

class _VideoUploadPageState extends ConsumerState<VideoUploadPage> {
  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(
        connectivityBlocProvider.select((value) => value.connectivityResult));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Upload Video'),
        centerTitle: true,
      ),
      body: Center(
        child: connectivity.name != 'none'
            ? Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      widget.pickedVideoPath != null
                          ? AspectRatio(
                              aspectRatio: 16 / 9,
                              child: BetterVideoPlayer(
                                controller: BetterVideoPlayerController(),
                                dataSource: BetterVideoPlayerDataSource(
                                  BetterVideoPlayerDataSourceType.file,
                                  widget.pickedVideoPath.toString(),
                                ),
                                configuration: BetterVideoPlayerConfiguration(
                                  autoPlay: false,
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                      SizedBox(
                        height: 20,
                      ),
                      Visibility(
                        visible: widget.pickedVideoPath != null,
                        child: MaterialButton(
                          onPressed: (() async {
                            
                            ref
                                .read(videoBloc)
                                .uploadVideoToFirestore()
                                .then((value) {
                              Get.back();
                            }).catchError((error) {
                              Get.snackbar(
                                'Error Uploading Video',
                                error.toString(),
                                colorText: Colors.white,
                              );
                            });
                          }),
                          child: Text(
                            "Share video",
                            style: TextStyle(color: Colors.white),
                          ),
                          height: 50,
                          minWidth: 70,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: StreamBuilder<TaskSnapshot>(
                      stream: ref.watch(
                        videoBloc.select(
                            (value) => value.uploadTask?.snapshotEvents),
                      ),
                      builder: (BuildContext context,
                          AsyncSnapshot<TaskSnapshot> snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data!;
                          double progress =
                              data.bytesTransferred / data.totalBytes;

                          return SizedBox(
                            height: 50,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                LinearProgressIndicator(
                                  value: progress,
                                  color: Colors.greenAccent,
                                  backgroundColor: Colors.grey,
                                ),
                                Center(
                                  child: Text(
                                    '${100 * progress.roundToDouble()}%',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  )
                ],
              )
            : Text("You are offline!"),
      ),
    );
  }
}
