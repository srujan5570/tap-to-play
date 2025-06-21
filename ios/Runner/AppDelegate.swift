import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let castarChannel = FlutterMethodChannel(name: "com.castarsdk.flutter/castar",
                                              binaryMessenger: controller.binaryMessenger)
    
    castarChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      switch call.method {
      case "startCastarSdk":
        guard let args = call.arguments as? [String: Any],
              let clientId = args["clientId"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Client ID is required", details: nil))
          return
        }
        
        // TODO: Add CastarSdk.framework to your iOS project
        // For now, we'll simulate the SDK start
        DispatchQueue.global(qos: .background).async {
          // Simulate Castar SDK start
          print("CastarSdk.Start(application, \(clientId))")
          
          DispatchQueue.main.async {
            result("Castar SDK started successfully with client ID: \(clientId)")
          }
        }
        
      case "stopCastarSdk":
        // TODO: Add CastarSdk.framework to your iOS project
        // For now, we'll simulate the SDK stop
        print("CastarSdk.Stop()")
        result("Castar SDK stopped successfully")
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
