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
}
