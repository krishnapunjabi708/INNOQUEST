import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyCKNos9aiQ_tMfSrRD-FaSkZnC7gWOHeLY")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
