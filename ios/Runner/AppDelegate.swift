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
    
    logMessage("🚀 App launching...")
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let castarChannel = FlutterMethodChannel(name: "com.castarsdk.flutter/castar",
                                              binaryMessenger: controller.binaryMessenger)
    
    castarChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      self.logMessage("📱 Method called: \(call.method)")
      
      switch call.method {
      case "startCastarSdk":
        guard let args = call.arguments as? [String: Any],
              let clientId = args["clientId"] as? String else {
          self.logMessage("❌ Invalid arguments for startCastarSdk")
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Client ID is required", details: nil))
          return
        }
        
        self.logMessage("🔧 Starting CastarSDK with client ID: \(clientId)")
        
        // Start Castar SDK in background thread
        DispatchQueue.global(qos: .background).async {
          do {
            // Create CastarSDK instance with client ID
            self.logMessage("🔧 Creating CastarSDK instance...")
            self.castarInstance = Castar.createInstance(withDevKey: clientId)
            
            if let instance = self.castarInstance {
              self.logMessage("✅ CastarSDK instance created successfully")
              
              // Start the SDK
              self.logMessage("🔧 Starting CastarSDK...")
              instance.start()
              
              self.logMessage("✅ CastarSDK started successfully")
              
              DispatchQueue.main.async {
                result("Castar SDK started successfully with client ID: \(clientId)")
              }
            } else {
              self.logMessage("❌ Failed to create CastarSDK instance")
              DispatchQueue.main.async {
                result(FlutterError(code: "SDK_INIT_FAILED", message: "Failed to initialize CastarSDK", details: nil))
              }
            }
          } catch {
            self.logMessage("❌ Exception during CastarSDK initialization: \(error)")
            DispatchQueue.main.async {
              result(FlutterError(code: "SDK_EXCEPTION", message: "Exception: \(error)", details: nil))
            }
          }
        }
        
      case "stopCastarSdk":
        self.logMessage("🛑 Stopping CastarSDK...")
        
        // Stop Castar SDK
        if let instance = self.castarInstance {
          instance.stop()
          self.castarInstance = nil
          self.logMessage("✅ CastarSDK stopped successfully")
          result("Castar SDK stopped successfully")
        } else {
          self.logMessage("⚠️ CastarSDK was not running")
          result("Castar SDK was not running")
        }
        
      case "getCastarStatus":
        if let instance = self.castarInstance {
          let status = [
            "running": instance.isRunning,
            "devKey": instance.getDevKey(),
            "devSn": instance.getDevSn()
          ]
          self.logMessage("📊 SDK Status: \(status)")
          result(status)
        } else {
          let status = ["running": false, "devKey": "", "devSn": ""]
          self.logMessage("📊 SDK Status: \(status)")
          result(status)
        }
        
      default:
        self.logMessage("⚠️ Unknown method: \(call.method)")
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    logMessage("✅ App launch completed")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - App Lifecycle Management
  
  override func applicationWillResignActive(_ application: UIApplication) {
    logMessage("🔄 App will resign active - keeping CastarSDK running")
    // Keep CastarSDK running when app goes to background
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    logMessage("📱 App entered background - starting background task")
    
    // Start background task to keep app alive
    backgroundTask = application.beginBackgroundTask(withName: "CastarSDKBackgroundTask") {
      // Background task expiration handler
      self.logMessage("⚠️ Background task expired")
      self.endBackgroundTask()
    }
    
    // Keep CastarSDK running in background
    if let instance = castarInstance {
      logMessage("🔄 Keeping CastarSDK running in background")
    } else {
      logMessage("⚠️ No CastarSDK instance to keep running")
    }
  }
  
  override func applicationWillEnterForeground(_ application: UIApplication) {
    logMessage("📱 App will enter foreground")
    endBackgroundTask()
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    logMessage("📱 App became active")
    endBackgroundTask()
  }
  
  override func applicationWillTerminate(_ application: UIApplication) {
    logMessage("🛑 App will terminate - stopping CastarSDK")
    
    // Stop CastarSDK when app terminates
    if let instance = castarInstance {
      instance.stop()
      castarInstance = nil
      logMessage("✅ CastarSDK stopped on app termination")
    }
    
    endBackgroundTask()
  }
  
  // MARK: - Background Task Management
  
  private func endBackgroundTask() {
    if backgroundTask != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
      logMessage("✅ Background task ended")
    }
  }
  
  // MARK: - Exception Handling
  
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    logMessage("❌ Failed to register for remote notifications: \(error)")
  }
  
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    logMessage("📱 Received remote notification")
    completionHandler(.newData)
  }
  
  // MARK: - Compatible Logging
  
  private func logMessage(_ message: String) {
    // Use NSLog for iOS 13+ compatibility
    NSLog("[CastarSDK] %@", message)
    
    // Also print to console for debugging
    print("[CastarSDK] \(message)")
  }
}
