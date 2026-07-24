import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  static weak var shared: MainFlutterWindow?
  private var applicationLifecycleChannel: FlutterMethodChannel?
  private var nativeDawBridge: NativeDawBridge?
  private var quitRequestInFlight = false
  private var pendingWindowClose = false
  private var allowWindowCloseOnce = false

  override func awakeFromNib() {
    MainFlutterWindow.shared = self
    delegate = self
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    applicationLifecycleChannel = FlutterMethodChannel(
      name: "blender_ui/application_lifecycle",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    applicationLifecycleChannel?.setMethodCallHandler { [weak self] call, result in
      if call.method == "requestQuit" {
        NSApp.terminate(nil)
        result(nil)
        return
      }
      guard call.method == "quitDecision", let decision = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      let shouldTerminate = decision == "save" || decision == "discard"
      self?.quitRequestInFlight = false
      if self?.pendingWindowClose == true {
        self?.pendingWindowClose = false
        if shouldTerminate {
          self?.allowWindowCloseOnce = true
          self?.close()
        }
      } else {
        NSApp.reply(toApplicationShouldTerminate: shouldTerminate)
      }
      result(nil)
    }
    nativeDawBridge = NativeDawBridge(
      messenger: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }

  func requestPreferences() {
    applicationLifecycleChannel?.invokeMethod("preferencesRequested", arguments: nil)
  }

  @discardableResult
  func requestApplicationQuit(windowClose: Bool = false) -> Bool {
    guard let applicationLifecycleChannel, !quitRequestInFlight else { return false }
    quitRequestInFlight = true
    pendingWindowClose = windowClose
    applicationLifecycleChannel.invokeMethod("quitRequested", arguments: nil)
    return true
  }

  @objc(windowShouldClose:)
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    if allowWindowCloseOnce {
      allowWindowCloseOnce = false
      return true
    }
    requestApplicationQuit(windowClose: true)
    return false
  }
}
