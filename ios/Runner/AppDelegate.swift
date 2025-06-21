import UIKit
import Flutter
import CastarSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var castarInstance: CSDK?
  
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
        
        // Start Castar SDK in background thread
        DispatchQueue.global(qos: .background).async {
          // Create CastarSDK instance with client ID
          self.castarInstance = CSDK.createInstance(withDevKey: clientId)
          
          if let instance = self.castarInstance {
            // Start the SDK
            instance.start()
            
            DispatchQueue.main.async {
              result("Castar SDK started successfully with client ID: \(clientId)")
            }
          } else {
            DispatchQueue.main.async {
              result(FlutterError(code: "SDK_INIT_FAILED", message: "Failed to initialize CastarSDK", details: nil))
            }
          }
        }
        
      case "stopCastarSdk":
        // Stop Castar SDK
        if let instance = self.castarInstance {
          instance.stop()
          self.castarInstance = nil
          result("Castar SDK stopped successfully")
        } else {
          result("Castar SDK was not running")
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
