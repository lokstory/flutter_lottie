#import "FlutterLottiePlugin.h"
#import <lokstory_flutter_lottie/lokstory_flutter_lottie-Swift.h>

@implementation FlutterLottiePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLottiePlugin registerWithRegistrar:registrar];
}
@end
