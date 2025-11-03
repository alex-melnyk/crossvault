import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
    
    // Modern window style without title bar
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)
    
    // Optional: Enable traffic light buttons (close, minimize, maximize)
    self.standardWindowButton(.closeButton)?.isHidden = false
    self.standardWindowButton(.miniaturizeButton)?.isHidden = false
    self.standardWindowButton(.zoomButton)?.isHidden = false
    
    // Set minimum window size
    self.minSize = NSSize(width: 800, height: 600)
    
    // Center window on screen
    self.center()
    
    // Enable window to be resizable
    self.isMovableByWindowBackground = true
  }
}
