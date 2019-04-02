#import "SimpleImagePlugin.h"
#import "Foundation/Foundation.h"
#import "CoreGraphics/CoreGraphics.h"

@implementation SimpleImagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"simple_image"
                                     binaryMessenger:[registrar messenger]];
    SimpleImagePlugin* instance = [[SimpleImagePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (BOOL)resizeAndSave:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.arguments isKindOfClass:[NSDictionary class]]) {
        NSDictionary *args = (NSDictionary *)call.arguments;
        
        CGFloat quality = [[args objectForKey:@"quality"] floatValue] / 100;
        
        // Source image
        NSString *sourceFile = [args objectForKey:@"sourceFile"];
        UIImage *sourceImage = [[UIImage alloc] initWithContentsOfFile:sourceFile];
        
        // Target image
        NSString *targetFile = [args objectForKey:@"targetFile"];
        
        // Sizes
        NSDictionary *targetRect = [args objectForKey:@"targetRect"];
        NSDictionary *sourceRect = [args objectForKey:@"sourceRect"];
        
        CGRect trect;
        CGRect srect;
        
        if (sourceRect != nil) {
            srect = CGRectMake(
               [[targetRect objectForKey:@"x"] floatValue],
               [[targetRect objectForKey:@"y"] floatValue],
               [[targetRect objectForKey:@"width"] floatValue],
               [[targetRect objectForKey:@"height"] floatValue]
               );
        } else {
            srect = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
        }
        
        if (targetRect != nil) {
            trect = CGRectMake(
               [[targetRect objectForKey:@"x"] floatValue],
               [[targetRect objectForKey:@"y"] floatValue],
               [[targetRect objectForKey:@"width"] floatValue],
               [[targetRect objectForKey:@"height"] floatValue]
               );
        } else {
            trect = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
        }
        
        // Process and resize image
        UIGraphicsBeginImageContextWithOptions(trect.size, NO, 0.0);
        
        [sourceImage drawInRect:trect];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        NSData *jpeg = UIImageJPEGRepresentation(newImage, quality);
        UIGraphicsEndImageContext();
        
        return [jpeg writeToFile:targetFile atomically:true];
    } else {
        return NO;
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"resizeAndSave" isEqualToString:call.method]) {
        result(@([self resizeAndSave:call result:result]));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
