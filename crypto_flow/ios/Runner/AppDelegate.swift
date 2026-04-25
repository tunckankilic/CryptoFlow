import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var apnsChannel: FlutterMethodChannel?
  private var pendingToken: String?
  private var pendingLaunchPayload: [AnyHashable: Any]?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Wire up MethodChannel to Flutter side (notifications package).
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "cryptoflow/apns",
        binaryMessenger: controller.binaryMessenger
      )
      apnsChannel = channel
      channel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else { return }
        switch call.method {
        case "getApnsToken":
          result(self.pendingToken)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // Capture cold-launch payload (if any).
    if let remote = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
      pendingLaunchPayload = remote
      apnsChannel?.invokeMethod("onLaunchMessage", arguments: remote)
    }

    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    pendingToken = token
    apnsChannel?.invokeMethod("onTokenReceived", arguments: token)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("APNs registration failed: \(error.localizedDescription)")
  }

  // Foreground delivery — show banner and forward to Flutter.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    apnsChannel?.invokeMethod(
      "onForegroundMessage",
      arguments: notification.request.content.userInfo
    )
    completionHandler([.banner, .badge, .sound])
  }

  // User tapped a notification — forward to Flutter for navigation.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    apnsChannel?.invokeMethod(
      "onMessageOpenedApp",
      arguments: response.notification.request.content.userInfo
    )
    completionHandler()
  }
}
