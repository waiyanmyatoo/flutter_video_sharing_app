import 'package:cloud_firestore/cloud_firestore.dart';

class VideoVO {
  String id;

  String videoUrl;

  int timeStamp;

  VideoVO({
    required this.id,
    required this.videoUrl,
    required this.timeStamp,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "videoUrl": videoUrl,
        "timeStamp": timeStamp,
      };

  static VideoVO fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return VideoVO(
      id: snapshot['id'],
      videoUrl: snapshot['videoUrl'],
      timeStamp: snapshot['timeStamp'],
    );
  }
}
