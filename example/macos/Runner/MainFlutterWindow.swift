import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  static weak var shared: MainFlutterWindow?
  private var applicationLifecycleChannel: FlutterMethodChannel?
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

    let windowChromeChannel = FlutterMethodChannel(
      name: "blender_ui/window_chrome",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    windowChromeChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setAppearance", let appearance = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.appearance = NSAppearance(
        named: appearance == "light" ? .aqua : .darkAqua)
      result(nil)
    }

    let lifecycleChannel = FlutterMethodChannel(
      name: "blender_ui/application_lifecycle",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    lifecycleChannel.setMethodCallHandler { [weak self] call, result in
      if call.method == "requestQuit" {
        NSApp.terminate(nil)
        result(nil)
        return
      }
      guard call.method == "quitDecision" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let decision = call.arguments as? String else {
        result(FlutterError(code: "invalid_decision", message: nil, details: nil))
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
      self?.applicationLifecycleChannel = lifecycleChannel
      result(nil)
    }
    applicationLifecycleChannel = lifecycleChannel

    super.awakeFromNib()

    if let requestedSize = ProcessInfo.processInfo.environment["BLENDERUI_WINDOW_SIZE"] {
      let dimensions = requestedSize.lowercased().split(separator: "x", maxSplits: 1)
      if dimensions.count == 2,
         let width = Double(dimensions[0]),
         let height = Double(dimensions[1]),
         width > 0,
         height > 0 {
        self.isRestorable = false
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          self.setContentSize(NSSize(width: width, height: height))
          NSLog(
            "BlenderUI verification window requested %@; applied %@",
            requestedSize,
            NSStringFromRect(self.frame))
        }
      }
    }
  }

  @discardableResult
  func requestApplicationQuit(windowClose: Bool = false) -> Bool {
    guard let applicationLifecycleChannel, !quitRequestInFlight else {
      return false
    }
    quitRequestInFlight = true
    pendingWindowClose = windowClose
    applicationLifecycleChannel.invokeMethod("quitRequested", arguments: nil)
    return true
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    if allowWindowCloseOnce {
      allowWindowCloseOnce = false
      return true
    }
    requestApplicationQuit(windowClose: true)
    return false
  }
}
