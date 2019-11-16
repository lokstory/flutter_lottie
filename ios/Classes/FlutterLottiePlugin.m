#import "FlutterLottiePlugin.h"
#import <mark922_flutter_lottie/mark922_flutter_lottie-Swift.h>

@implementation FlutterLottiePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLottiePlugin registerWithRegistrar:registrar];
}
@end
