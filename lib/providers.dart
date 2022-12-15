import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_sharing_app/bloc/connectivity_bloc.dart';
import 'package:flutter_video_sharing_app/bloc/video_bloc.dart';

final videoBloc = ChangeNotifierProvider<VideoBloc>((ref) {
  return VideoBloc();
});

final connectivityBlocProvider = ChangeNotifierProvider<ConnectivityBloc>((ref) {
  return ConnectivityBloc();
});

final databaseProvider = StreamProvider.autoDispose<QuerySnapshot>((ref)  {
  return FirebaseFirestore.instance.collection("videos").orderBy("timeStamp", descending: true).snapshots();
});
