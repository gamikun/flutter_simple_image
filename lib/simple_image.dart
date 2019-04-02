import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('simple_image');

Future<bool> resizeAndSave({
  String sourceFile, String targetFile,
  Rect sourceRect, Rect targetRect,
  int quality: 90
}) async {
  assert(sourceFile != null);
  assert(targetFile != null);

  return _channel.invokeMethod('resizeAndSave', <String, dynamic> {
    "sourceFile": sourceFile,
    "sourceRect": sourceRect,
    "targetFile": targetFile,
    "targetRect": targetRect != null ? <String, dynamic> {
      "x": targetRect.left,
      "y": targetRect.top,
      "width": targetRect.width,
      "height": targetRect.height
    } : null,
    "quality": quality
  });
}