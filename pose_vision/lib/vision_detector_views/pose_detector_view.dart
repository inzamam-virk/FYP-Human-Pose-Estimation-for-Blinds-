import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'camera_view.dart';
import 'painters/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  String activity = "";

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      activity: activity,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }

    // Fetching pose data
    if (poses.isNotEmpty) {
      final pose = poses.first;
      activity = getActivityFromPose(pose);
      print("Activity-----> $activity");

      print('Pose Landmarks:');
      pose.landmarks.forEach((landmarkType, landmark) {
        final landmarkTypeStr = describeEnum(landmarkType);
        final x = landmark.x;
        final y = landmark.y;
        print('Landmark Type: $landmarkTypeStr');
        print('Landmark Position: x=$x, y=$y');
      });
    } else {
      print("$poses is empty");
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

// inal leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  String getActivityFromPose(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    // final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final nose = pose.landmarks[PoseLandmarkType.nose];

    final shoulderHipRatio = calculateDistance(leftShoulder, rightShoulder) /
        calculateDistance(leftHip, rightHip);
    final kneeAnkleRatio = calculateDistance(leftKnee, rightKnee) /
        calculateDistance(leftAnkle, rightAnkle);
    final wristNoseDistance = calculateDistance(leftWrist, nose);

     if (shoulderHipRatio > 1.4) {
      return 'Standing!';
    } else if (shoulderHipRatio <= 1.4 && kneeAnkleRatio > 1.0) {
      return 'Walking!';
    } else if (shoulderHipRatio <= 1.4 &&
        kneeAnkleRatio <= 1.0 &&
        wristNoseDistance > 0.2) {
      return 'Sitting on a Chair!';
    } else if (shoulderHipRatio <= 1.4 &&
        kneeAnkleRatio <= 1.0 &&
        wristNoseDistance <= 0.2) {
      return 'Sitting on the Ground!';
    }

    return 'Unknown!';
  }

  double calculateDistance(PoseLandmark? landmark1, PoseLandmark? landmark2) {
    if (landmark1 != null && landmark2 != null) {
      final dx = landmark1.x - landmark2.x;
      final dy = landmark1.y - landmark2.y;
      final dz = landmark1.z - landmark2.z;
      return sqrt(dx * dx + dy * dy + dz * dz);
    }
    return 0.0;
  }
}
