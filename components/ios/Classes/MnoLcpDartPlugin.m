#import "MnoLcpDartPlugin.h"
#if __has_include(<mno_lcp_dart/mno_lcp_dart-Swift.h>)
#import <mno_lcp_dart/mno_lcp_dart-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mno_lcp_dart-Swift.h"
#endif

@implementation MnoLcpDartPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMnoLcpDartPlugin registerWithRegistrar:registrar];
}
@end
