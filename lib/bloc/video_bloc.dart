import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_video_sharing_app/data/vos/video_vo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class VideoBloc extends ChangeNotifier {
  XFile? video;
  UploadTask? uploadTask;

  final ImagePicker _picker = ImagePicker();

  final Uuid uuid = Uuid();

  final Reference storage = FirebaseStorage.instance.ref();

  final firestore = FirebaseFirestore.instance;

  VideoBloc() {
    video = null;
    notifyListeners();
  }

  Future<String> pickVideo() async {
    // Use the ImagePicker plugin to pick a video
    video = null;
    final XFile? pickedVideo =
        await _picker.pickVideo(source: ImageSource.gallery);
    // Set the picked video as the state of the widget
    if (pickedVideo != null) {
      video = pickedVideo;
      notifyListeners();
    }
    notifyListeners();
    return Future.value(video?.path);
  }

  Future<String> uploadFileToStorage(String id, String path) async {
    File file = File(video!.path);

    final storage = FirebaseStorage.instance.ref().child(path);
    uploadTask = storage.putFile(file);
    notifyListeners();

    final snap = await uploadTask!.whenComplete(() => {});

    String downloadUrl = await snap.ref.getDownloadURL();

    print(downloadUrl);
    notifyListeners();
    return Future.value(downloadUrl);
  }

  Future uploadVideoToFirestore() async {
    var allVids = await firestore.collection('videos').get();
    int len = allVids.docs.length;
    String videoID = uuid.v4();
    final path = 'videos/${videoID}';

    String videourl = await uploadFileToStorage(videoID, path);

    VideoVO video = VideoVO(
      id: videoID,
      videoUrl: videourl,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    );

    await firestore
        .collection('videos')
        .doc('Video $len')
        .set(video.toJson());
  }
}
