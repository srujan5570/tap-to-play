import UIKit
import Flutter
import CastarSDK
import os.log

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var castarInstance: Castar?
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
  private let logger = Logger(subsystem: "com.example.myTime", category: "CastarSDK")
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    logger.info("🚀 App launching...")
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let castarChannel = FlutterMethodChannel(name: "com.castarsdk.flutter/castar",
                                              binaryMessenger: controller.binaryMessenger)
    
    castarChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      self.logger.info("📱 Method called: \(call.method)")
      
      switch call.method {
      case "startCastarSdk":
        guard let args = call.arguments as? [String: Any],
              let clientId = args["clientId"] as? String else {
          self.logger.error("❌ Invalid arguments for startCastarSdk")
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Client ID is required", details: nil))
          return
        }
        
        self.logger.info("🔧 Starting CastarSDK with client ID: \(clientId)")
        
        // Start Castar SDK in background thread
        DispatchQueue.global(qos: .background).async {
          do {
            // Create CastarSDK instance with client ID
            self.logger.info("🔧 Creating CastarSDK instance...")
            self.castarInstance = Castar.createInstance(withDevKey: clientId)
            
            if let instance = self.castarInstance {
              self.logger.info("✅ CastarSDK instance created successfully")
              
              // Start the SDK
              self.logger.info("🔧 Starting CastarSDK...")
              instance.start()
              
              self.logger.info("✅ CastarSDK started successfully")
              
              DispatchQueue.main.async {
                result("Castar SDK started successfully with client ID: \(clientId)")
              }
            } else {
              self.logger.error("❌ Failed to create CastarSDK instance")
              DispatchQueue.main.async {
                result(FlutterError(code: "SDK_INIT_FAILED", message: "Failed to initialize CastarSDK", details: nil))
              }
            }
          } catch {
            self.logger.error("❌ Exception during CastarSDK initialization: \(error)")
            DispatchQueue.main.async {
              result(FlutterError(code: "SDK_EXCEPTION", message: "Exception: \(error)", details: nil))
            }
          }
        }
        
      case "stopCastarSdk":
        self.logger.info("🛑 Stopping CastarSDK...")
        
        // Stop Castar SDK
        if let instance = self.castarInstance {
          instance.stop()
          self.castarInstance = nil
          self.logger.info("✅ CastarSDK stopped successfully")
          result("Castar SDK stopped successfully")
        } else {
          self.logger.warning("⚠️ CastarSDK was not running")
          result("Castar SDK was not running")
        }
        
      case "getCastarStatus":
        if let instance = self.castarInstance {
          let status = [
            "running": instance.isRunning,
            "devKey": instance.getDevKey(),
            "devSn": instance.getDevSn()
          ]
          self.logger.info("📊 SDK Status: \(status)")
          result(status)
        } else {
          let status = ["running": false, "devKey": "", "devSn": ""]
          self.logger.info("📊 SDK Status: \(status)")
          result(status)
        }
        
      default:
        self.logger.warning("⚠️ Unknown method: \(call.method)")
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    logger.info("✅ App launch completed")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - App Lifecycle Management
  
  override func applicationWillResignActive(_ application: UIApplication) {
    logger.info("🔄 App will resign active - keeping CastarSDK running")
    // Keep CastarSDK running when app goes to background
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    logger.info("📱 App entered background - starting background task")
    
    // Start background task to keep app alive
    backgroundTask = application.beginBackgroundTask(withName: "CastarSDKBackgroundTask") {
      // Background task expiration handler
      self.logger.warning("⚠️ Background task expired")
      self.endBackgroundTask()
    }
    
    // Keep CastarSDK running in background
    if let instance = castarInstance {
      logger.info("🔄 Keeping CastarSDK running in background")
    } else {
      logger.warning("⚠️ No CastarSDK instance to keep running")
    }
  }
  
  override func applicationWillEnterForeground(_ application: UIApplication) {
    logger.info("📱 App will enter foreground")
    endBackgroundTask()
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    logger.info("📱 App became active")
    endBackgroundTask()
  }
  
  override func applicationWillTerminate(_ application: UIApplication) {
    logger.info("🛑 App will terminate - stopping CastarSDK")
    
    // Stop CastarSDK when app terminates
    if let instance = castarInstance {
      instance.stop()
      castarInstance = nil
      logger.info("✅ CastarSDK stopped on app termination")
    }
    
    endBackgroundTask()
  }
  
  // MARK: - Background Task Management
  
  private func endBackgroundTask() {
    if backgroundTask != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
      logger.info("✅ Background task ended")
    }
  }
  
  // MARK: - Exception Handling
  
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    logger.error("❌ Failed to register for remote notifications: \(error)")
  }
  
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    logger.info("📱 Received remote notification")
    completionHandler(.newData)
  }
}
