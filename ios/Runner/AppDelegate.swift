import Flutter
import UIKit

// Conditional import - will work when framework is properly added
#if canImport(CastarSdk)
import CastarSdk
#endif

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
        
        #if canImport(CastarSdk)
        // Start Castar SDK in background thread
        DispatchQueue.global(qos: .background).async {
          CastarSdk.Start(application, clientId)
          
          DispatchQueue.main.async {
            result("Castar SDK started successfully with client ID: \(clientId)")
          }
        }
        #else
        // Fallback when framework is not available
        DispatchQueue.global(qos: .background).async {
          print("CastarSdk.Start(application, \(clientId)) - Framework not available")
          
          DispatchQueue.main.async {
            result(FlutterError(code: "SDK_NOT_AVAILABLE", message: "Castar SDK framework not found. Please add CastarSdk.framework to the Xcode project.", details: nil))
          }
        }
        #endif
        
      case "stopCastarSdk":
        #if canImport(CastarSdk)
        // Stop Castar SDK
        CastarSdk.Stop()
        result("Castar SDK stopped successfully")
        #else
        // Fallback when framework is not available
        print("CastarSdk.Stop() - Framework not available")
        result(FlutterError(code: "SDK_NOT_AVAILABLE", message: "Castar SDK framework not found. Please add CastarSdk.framework to the Xcode project.", details: nil))
        #endif
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
