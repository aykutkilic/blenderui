import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  static weak var shared: MainFlutterWindow?
  private var applicationLifecycleChannel: FlutterMethodChannel?
  private var nativeDawBridge: NativeDawBridge?

  override func awakeFromNib() {
    MainFlutterWindow.shared = self
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    applicationLifecycleChannel = FlutterMethodChannel(
      name: "blender_ui/application_lifecycle",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    nativeDawBridge = NativeDawBridge(
      messenger: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }

  func requestPreferences() {
    applicationLifecycleChannel?.invokeMethod("preferencesRequested", arguments: nil)
  }
}
