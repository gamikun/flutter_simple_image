package com.example.simple_image;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.util.HashMap;

/** SimpleImagePlugin */
public class SimpleImagePlugin implements MethodCallHandler {
    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "simple_image");
        channel.setMethodCallHandler(new SimpleImagePlugin());
    }

    private void resizeAndSave(MethodCall call, Result result) {
        int quality = (int) call.argument("quality");
        String sourceFile = (String) call.argument("sourceFile");
        String targetFile = (String) call.argument("targetFile");
        HashMap<String, Object> targetRect = call.argument("targetRect");
        HashMap<String, Object> sourceRect = call.argument("sourceRect");
        Bitmap bitmap;

        try {
            // TODO: calculate size first: inJustDecodeBounds
            // TODO: use inSampleSize to improve the resize
            bitmap = BitmapFactory.decodeFile(sourceFile);
        } catch (OutOfMemoryError ex) {
            result.error("OUT_OF_MEMORY", ex.getMessage(), ex.toString());
            return;
        }

        android.graphics.Rect trect;
        android.graphics.Rect srect;

        if (targetRect != null) {
            trect = new android.graphics.Rect(
                  (int)(double)targetRect.get("x"),
                  (int)(double)targetRect.get("y"),
                  (int)(double)targetRect.get("width"),
                  (int)(double)targetRect.get("height")
            );
        } else {
            trect = new android.graphics.Rect(
                  0,
                  0,
                  bitmap.getWidth(),
                  bitmap.getHeight()
            );
        }

        if (sourceRect != null) {
            srect = new android.graphics.Rect(
                  (int)(double)sourceRect.get("x"),
                  (int)(double)sourceRect.get("y"),
                  (int)(double)sourceRect.get("width"),
                  (int)(double)sourceRect.get("height")
            );
        } else {
            srect = new android.graphics.Rect(
                  0,
                  0,
                  bitmap.getWidth(),
                  bitmap.getHeight()
            );
        }

        // Crop and paste
        Bitmap targetBitmap = Bitmap.createBitmap(
                trect.width(),
                trect.height(),
                Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas();
        canvas.setBitmap(targetBitmap);
        canvas.drawBitmap(bitmap, srect, trect, null);

        // Convertir a JPEG
        try {
            FileOutputStream writer = new FileOutputStream(targetFile);
            System.out.println("Quality: " + quality);
            targetBitmap.compress(Bitmap.CompressFormat.JPEG, quality, writer);
        } catch (FileNotFoundException ex) {
            result.error("CANNOT_SAVE_IMAGE", ex.getMessage(), ex.getMessage());
            return;
        }

        result.success(true);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("resizeAndSave")) {
            resizeAndSave(call, result);
        } else {
            result.notImplemented();
        }
    }
}



