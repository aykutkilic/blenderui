import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
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

    super.awakeFromNib()
  }
}
