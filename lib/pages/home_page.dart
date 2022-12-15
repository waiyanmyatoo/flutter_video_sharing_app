import 'package:better_video_player/better_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_sharing_app/data/vos/video_vo.dart';
import 'package:flutter_video_sharing_app/pages/video_upload_page.dart';
import 'package:flutter_video_sharing_app/providers.dart';
import 'package:flutter_video_sharing_app/widgets/video_player_iten.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final connectivity = ref.watch(
      connectivityBlocProvider.select((value) => value.connectivityResult),
    );
    final videoStream = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: connectivity.name != 'none'
            ? videoStream.when(
                data: (data) {
                  return data.docs.length > 0
                      ? PageView.builder(
                          itemCount: data.docs.length,
                          controller: PageController(
                              initialPage: 0, viewportFraction: 1),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            final VideoVO video =
                                VideoVO.fromSnap(data.docs[index]);
                            // int milliseconds = int.parse(video.timeStamp);
                            final timeStamp =timeago.format(DateTime.fromMillisecondsSinceEpoch(video.timeStamp)); 
                            print(timeStamp);
                            print(video.videoUrl);
                            return Stack(
                              children: [
                                VideoPlayerItem(
                                  videoUrl: video.videoUrl,
                                ),
                                Column(
                                  children: [
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                left: 20,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    "${timeStamp}",
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Wai Yan",
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Hello World!",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.music_note,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        "ABC",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 100,
                                            margin: EdgeInsets.only(
                                                top: size.height / 5),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                VideoStatusItemView(
                                                  icon: Icons.favorite,
                                                  count: "1",
                                                  iconColor: Colors.redAccent,
                                                ),
                                                VideoStatusItemView(
                                                  icon: Icons.comment,
                                                  count: "0",
                                                ),
                                                VideoStatusItemView(
                                                  icon: Icons.reply,
                                                  count: "0",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        )
                      : Text("There is no video alailable right now!");
                },
                error: (error, stackTrace) {
                  return Center(
                    child: Text(error.toString()),
                  );
                },
                loading: (() => CircularProgressIndicator()),
              )
            : Text("You are offline!"),
      ),
      floatingActionButton: Visibility(
        visible: connectivity != 'none',
        child: FloatingActionButton(
          onPressed: (() async {
            // await ref.read(homePageProvider).pickVideo();
            // Get.to(VideoUploadPage());
            await ref.read(videoBloc).pickVideo().then(
              (value) {
                if (value != null) {
                  Get.to(
                    VideoUploadPage(
                      pickedVideoPath: value,
                    ),
                  );
                } else {
                  Get.snackbar(
                    "Alert",
                    "You didn't choose a video!",
                    colorText: Colors.white,
                  );
                }
              },
            ).catchError((error) {
              Get.snackbar(
                'Alert',
                "You didn't choose a video file!",
                colorText: Colors.white,
              );
            });
          }),
          tooltip: 'Increment',
          backgroundColor: Colors.redAccent,
          child: const Icon(
            Icons.upload,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class VideoStatusItemView extends StatelessWidget {
  const VideoStatusItemView({
    Key? key,
    required this.icon,
    required this.count,
    this.iconColor,
  }) : super(key: key);

  final IconData icon;
  final String count;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Icon(
            icon,
            size: 40,
            color: iconColor ?? Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}
