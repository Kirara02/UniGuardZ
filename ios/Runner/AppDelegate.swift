import Flutter
import UIKit
import GoogleMaps
import flutter_local_notifications
import flutter_background_service_ios

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.uniguard.uniguard_z.background_service"
    
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
        GMSServices.provideAPIKey(apiKey)
    } else {
        print("⚠️ Google Maps API Key not found in Info.plist")
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
