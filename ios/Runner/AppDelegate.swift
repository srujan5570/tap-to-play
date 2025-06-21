import UIKit
import Flutter
import CastarSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var castarInstance: Castar?
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
  
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
          self.castarInstance = Castar.createInstance(withDevKey: clientId)
          
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
        
      case "getCastarStatus":
        if let instance = self.castarInstance {
          let status = [
            "running": instance.running,
            "devKey": instance.getDevKey(),
            "devSn": instance.getDevSn()
          ]
          result(status)
        } else {
          result(["running": false, "devKey": "", "devSn": ""])
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - App Lifecycle Management
  
  override func applicationWillResignActive(_ application: UIApplication) {
    print("🔄 App will resign active - keeping CastarSDK running")
    // Keep CastarSDK running when app goes to background
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    print("📱 App entered background - starting background task")
    
    // Start background task to keep app alive
    backgroundTask = application.beginBackgroundTask(withName: "CastarSDKBackgroundTask") {
      // Background task expiration handler
      print("⚠️ Background task expired")
      self.endBackgroundTask()
    }
    
    // Keep CastarSDK running in background
    if let instance = castarInstance {
      print("🔄 Keeping CastarSDK running in background")
    }
  }
  
  override func applicationWillEnterForeground(_ application: UIApplication) {
    print("📱 App will enter foreground")
    endBackgroundTask()
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    print("📱 App became active")
    endBackgroundTask()
  }
  
  override func applicationWillTerminate(_ application: UIApplication) {
    print("🛑 App will terminate - stopping CastarSDK")
    
    // Stop CastarSDK when app terminates
    if let instance = castarInstance {
      instance.stop()
      castarInstance = nil
    }
    
    endBackgroundTask()
  }
  
  // MARK: - Background Task Management
  
  private func endBackgroundTask() {
    if backgroundTask != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
      print("✅ Background task ended")
    }
  }
}
