#import "CamcodePlugin.h"
#if __has_include(<camcode/camcode-Swift.h>)
#import <camcode/camcode-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "camcode-Swift.h"
#endif

@implementation CamcodePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCamcodePlugin registerWithRegistrar:registrar];
}
@end
