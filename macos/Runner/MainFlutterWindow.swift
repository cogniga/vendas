import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    // Abre sempre maximizada: ocupa toda a área útil da tela (sem cobrir a
    // barra de menus nem o Dock), como o botão verde com Option.
    let areaUtil = (self.screen ?? NSScreen.main)?.visibleFrame ?? self.frame
    self.setFrame(areaUtil, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
