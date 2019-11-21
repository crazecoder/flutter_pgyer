#import "FlutterPgyerPlugin.h"
#import <PgySDK/PgyManager.h>
#import <PgyUpdate/PgyUpdateManager.h>

@implementation FlutterPgyerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"crazecoder/flutter_pgyer"
            binaryMessenger:[registrar messenger]];
  FlutterPgyerPlugin* instance = [[FlutterPgyerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initSdk" isEqualToString:call.method]) {
      NSString *appId = call.arguments[@"appId"];
      BOOL b = [self isBlankString:appId];
      NSString * json;
      if(!b){
          //启动基本SDK
          [[PgyManager sharedPgyManager] startManagerWithAppId:appId];
          //启动更新检查SDK
          [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:appId];
          NSDictionary * dict = @{@"message":@"初始化成功", @"isSuccess":@YES};
          NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
          json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      }else{
          NSDictionary * dict = @{@"message":@"初始化失败", @"isSuccess":@NO};
          NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
          json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      }
     result(json);
  } else if ([@"reportException" isEqualToString:call.method]) {
     NSString *crash_detail = call.arguments[@"crash_detail"];
     NSString *crash_message = call.arguments[@"crash_message"];
     if ([self isBlankString:crash_detail]) {
         crash_message = @"";
     }
     NSException* ex = [[NSException alloc]initWithName:crash_message
                                            reason:crash_detail
                                            userInfo:nil];
     [[PgyManager sharedPgyManager] reportException:ex];
     result(nil);
  } else if ([@"setEnableFeedback" isEqualToString:call.method]) {
     BOOL enable = call.arguments[@"enable"];
     BOOL isThreeFingersPan = call.arguments[@"isThreeFingersPan"];
     double shakingThreshold = [call.arguments[@"shakingThreshold"] doubleValue];
     [[PgyManager sharedPgyManager] setEnableFeedback:enable];
     if(enable){
            NSString *colorHex = call.arguments[@"colorHex"];
            BOOL b = [self isBlankString:colorHex];
            if(!b){
                UIColor *color = [self hexStringToColor:colorHex];
                [[PgyManager sharedPgyManager] setThemeColor:color];
            }

            if(isThreeFingersPan){
                // 设置用户反馈界面激活方式为三指拖动
                [[PgyManager sharedPgyManager] setFeedbackActiveType:kPGYFeedbackActiveTypeThreeFingersPan];
            }else{
                // 设置用户反馈界面激活方式为摇一摇
                [[PgyManager sharedPgyManager] setFeedbackActiveType:kPGYFeedbackActiveTypeShake];
                [[PgyManager sharedPgyManager] setShakingThreshold:shakingThreshold];
            }
     }
     result(nil);
  } else if ([@"showFeedbackView" isEqualToString:call.method]) {
     [[PgyManager sharedPgyManager] showFeedbackView];
     result(nil);
  } else if ([@"checkUpdate" isEqualToString:call.method]) {
     [[PgyUpdateManager sharedPgyManager] checkUpdate];
//     [[PgyUpdateManager sharedPgyManager] checkUpdateWithDelegete:self selector:@selector(updateMethod:)];
     result(nil);
  } else {
     result(FlutterMethodNotImplemented);
  }
}
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
    
}
- (UIColor *) hexStringToColor: (NSString *) stringToConvert
    {
          NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
          // String should be 6 or 8 characters
        
          if ([cString length] < 6) return [UIColor blackColor];
          // strip 0X if it appears
          if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
          if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
          if ([cString length] != 6) return [UIColor blackColor];
        
          // Separate into r, g, b substrings
        
          NSRange range;
          range.location = 0;
          range.length = 2;
          NSString *rString = [cString substringWithRange:range];
          range.location = 2;
          NSString *gString = [cString substringWithRange:range];
          range.location = 4;
          NSString *bString = [cString substringWithRange:range];
          // Scan values
          unsigned int r, g, b;
        
          [[NSScanner scannerWithString:rString] scanHexInt:&r];
          [[NSScanner scannerWithString:gString] scanHexInt:&g];
          [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
          return [UIColor colorWithRed:((float) r / 255.0f)
                                     green:((float) g / 255.0f)
                                      blue:((float) b / 255.0f)
                                     alpha:1.0f];
    }
@end
