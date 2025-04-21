import Flutter
import UIKit
import GoogleMaps
import flutter_local_notifications
import flutter_background_service_ios
import CoreLocation
import CoreBluetooth

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let CHANNEL = "com.uniguard.ugz_app/uniguard_service"
  private let locationManager = CLLocationManager()
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    locationManager.requestAlwaysAuthorization()

    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.uniguard.uniguardz"
    
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
        GMSServices.provideAPIKey(apiKey)
    } else {
        print("⚠️ Google Maps API Key not found in Info.plist")
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard let self = self else { return }
        
        switch call.method {
        case "initializeService":
            if let headers = call.arguments as? [String: String] {
                self.initializeService(headers: headers)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Headers must be a Map<String, String>",
                                  details: nil))
            }
            
        case "startBeaconService":
            BeaconService.shared.startService()
            result(nil)
            
        case "stopBeaconService":
            BeaconService.shared.stopService()
            result(nil)
            
        case "isBeaconServiceRunning":
            result(BeaconService.shared.isScanning)
            
        case "startLocationUploadService":
            if let interval = call.arguments as? NSNumber {
                LocationService.shared.startService(interval: interval.doubleValue)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Interval must be a number",
                                  details: nil))
            }
            
        case "stopLocationUploadService":
            LocationService.shared.stopService()
            result(nil)
            
        case "isLocationUploadServiceRunning":
            result(LocationService.shared.isServiceRunning)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func initializeService(headers: [String: String]) {
    APIClient.shared.updateHeaders(headers)
  }
}
