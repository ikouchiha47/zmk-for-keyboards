import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler, NSWindowDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    var statusItem: NSStatusItem!
    let posKey = "PiPKeymapWindowFrame"

    // Layer signal detection: ZMK macros tap F13-F18 on layer activate, F19 on deactivate
    // F13=media, F14=sym, F15=num, F16=nav, F17=fun, F18=mouse, F19=base
    let signalToLayer: [UInt16: String] = [
        105: "media",  // F13
        107: "sym",    // F14
        113: "num",    // F15
        106: "nav",    // F16
        64:  "fun",    // F17
        79:  "mouse",  // F18
        80:  "base"    // F19
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Clear stale saved position from previous broken version
        let defaultFrame = NSRect(x: 200, y: 200, width: 660, height: 300)
        let frame: NSRect
        if let saved = UserDefaults.standard.string(forKey: posKey) {
            let r = NSRectFromString(saved)
            // Sanity check: must be reasonable size
            if r.width >= 320 && r.height >= 140 && r.width < 3000 && r.height < 2000 {
                frame = r
            } else {
                frame = defaultFrame
            }
        } else {
            frame = defaultFrame
        }

        // Titled window with transparent titlebar = native drag + resize + close
        window = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.appearance = NSAppearance(named: .darkAqua)
        window.isOpaque = false
        window.backgroundColor = NSColor(red: 26/255, green: 26/255, blue: 46/255, alpha: 0.95)
        window.hasShadow = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.minSize = NSSize(width: 360, height: 160)
        window.title = "PiP Keymap"

        // Hide miniaturize and zoom buttons, keep close
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        // Corner radius
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 12
        window.contentView?.layer?.masksToBounds = true

        // WebView configuration with message handler for close
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        config.userContentController.add(self, name: "pipControl")

        webView = WKWebView(frame: window.contentView!.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.setValue(false, forKey: "drawsBackground")

        // Load local HTML
        let htmlPath = findHTMLFile()
        let htmlURL = URL(fileURLWithPath: htmlPath)
        webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())

        window.contentView?.addSubview(webView)
        window.delegate = self
        window.makeKeyAndOrderFront(nil)

        // Menu bar status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "PiP Keymap")
        }
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Keymap", action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu

        // Save position on move/resize
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification, object: window, queue: nil
        ) { [weak self] _ in self?.savePosition() }
        NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification, object: window, queue: nil
        ) { [weak self] _ in self?.savePosition() }

        // Global hotkeys (when app is NOT focused)
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleGlobalKey(event)
            self?.handleLayerSignal(event)
        }
        // Local hotkeys (when app IS focused)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleGlobalKey(event)
            self?.handleLayerSignal(event)
            return event
        }
    }

    // Handle messages from JavaScript
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? String else { return }
        if body == "close" {
            window.orderOut(nil)
        }
    }

    func findHTMLFile() -> String {
        let bundle = Bundle.main.bundlePath
        let dir = (bundle as NSString).deletingLastPathComponent
        let candidates = [
            "\(dir)/pip-keymap.html",
            "\(dir)/../pip-keymap/pip-keymap.html",
            "\(dir)/pip-keymap/pip-keymap.html"
        ]
        for path in candidates {
            let resolved = (path as NSString).standardizingPath
            if FileManager.default.fileExists(atPath: resolved) {
                return resolved
            }
        }
        return "\(dir)/pip-keymap.html"
    }

    func savePosition() {
        UserDefaults.standard.set(NSStringFromRect(window.frame), forKey: posKey)
    }

    func handleGlobalKey(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let ctrlShift: NSEvent.ModifierFlags = [.control, .shift]
        guard flags.contains(ctrlShift) else { return }

        switch event.keyCode {
        case 40: // K - toggle visibility
            toggleVisibility()
        case 30: // ] - next layer
            webView.evaluateJavaScript("cycleLayer(1)", completionHandler: nil)
        case 33: // [ - prev layer
            webView.evaluateJavaScript("cycleLayer(-1)", completionHandler: nil)
        default:
            break
        }
    }

    func handleLayerSignal(_ event: NSEvent) {
        guard let layer = signalToLayer[event.keyCode] else { return }
        webView.evaluateJavaScript("switchLayer('\(layer)')", completionHandler: nil)
    }

    func toggleVisibility() {
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // Close button hides to menu bar instead of quitting
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }

    @objc func showWindow() {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

// --- Main ---
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
