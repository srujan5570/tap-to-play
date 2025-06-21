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
    
    // Set up method channel with crash protection
    setupMethodChannel()
    
    GeneratedPluginRegistrant.register(with: self)
    logMessage("✅ App launch completed")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - Method Channel Setup with Crash Protection
  
  private func setupMethodChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      logMessage("❌ Failed to get FlutterViewController")
      return
    }
    
    let castarChannel = FlutterMethodChannel(name: "com.castarsdk.flutter/castar",
                                              binaryMessenger: controller.binaryMessenger)
    
    castarChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else {
        result(FlutterError(code: "DEALLOCATED", message: "AppDelegate was deallocated", details: nil))
        return
      }
      
      self.logMessage("📱 Method called: \(call.method)")
      
      // Wrap all method calls in crash protection
      self.handleMethodCall(call, result: result)
    }
  }
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startCastarSdk":
      handleStartCastarSdk(call, result: result)
    case "stopCastarSdk":
      handleStopCastarSdk(result: result)
    case "getCastarStatus":
      handleGetCastarStatus(result: result)
    default:
      self.logMessage("⚠️ Unknown method: \(call.method)")
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func handleStartCastarSdk(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let clientId = args["clientId"] as? String else {
      self.logMessage("❌ Invalid arguments for startCastarSdk")
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Client ID is required", details: nil))
      return
    }
    
    self.logMessage("🔧 Starting CastarSDK with client ID: \(clientId)")
    
    // Start Castar SDK in background thread with crash protection
    DispatchQueue.global(qos: .background).async { [weak self] in
      guard let self = self else { return }
      
      do {
        // Create CastarSDK instance with client ID
        self.logMessage("🔧 Creating CastarSDK instance...")
        
        // Add crash protection around CastarSDK calls
        let instance = Castar.createInstance(withDevKey: clientId)
        
        if let instance = instance {
          self.logMessage("✅ CastarSDK instance created successfully")
          
          // Start the SDK with crash protection
          self.logMessage("🔧 Starting CastarSDK...")
          instance.start()
          
          self.logMessage("✅ CastarSDK started successfully")
          
          DispatchQueue.main.async {
            self.castarInstance = instance
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
  }
  
  private func handleStopCastarSdk(result: @escaping FlutterResult) {
    self.logMessage("🛑 Stopping CastarSDK...")
    
    // Stop Castar SDK with crash protection
    if let instance = castarInstance {
      do {
        instance.stop()
        castarInstance = nil
        self.logMessage("✅ CastarSDK stopped successfully")
        result("Castar SDK stopped successfully")
      } catch {
        self.logMessage("❌ Exception during CastarSDK stop: \(error)")
        result(FlutterError(code: "SDK_STOP_EXCEPTION", message: "Exception: \(error)", details: nil))
      }
    } else {
      self.logMessage("⚠️ CastarSDK was not running")
      result("Castar SDK was not running")
    }
  }
  
  private func handleGetCastarStatus(result: @escaping FlutterResult) {
    if let instance = castarInstance {
      do {
        let status = [
          "running": instance.isRunning,
          "devKey": instance.getDevKey(),
          "devSn": instance.getDevSn()
        ]
        self.logMessage("📊 SDK Status: \(status)")
        result(status)
      } catch {
        self.logMessage("❌ Exception getting SDK status: \(error)")
        result(FlutterError(code: "SDK_STATUS_EXCEPTION", message: "Exception: \(error)", details: nil))
      }
    } else {
      let status = ["running": false, "devKey": "", "devSn": ""]
      self.logMessage("📊 SDK Status: \(status)")
      result(status)
    }
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
      do {
        instance.stop()
        castarInstance = nil
        logMessage("✅ CastarSDK stopped on app termination")
      } catch {
        logMessage("❌ Exception stopping CastarSDK on termination: \(error)")
      }
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
  
  // MARK: - Compatible Logging (Keep in Release)
  
  private func logMessage(_ message: String) {
    // Use NSLog for iOS 13+ compatibility - KEEP IN RELEASE
    NSLog("[CastarSDK] %@", message)
    
    // Also print to console for debugging - KEEP IN RELEASE
    print("[CastarSDK] \(message)")
  }
}
