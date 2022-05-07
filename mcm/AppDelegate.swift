//
//  AppDelegate.swift
//  mcm
//
//  Created by tommy on 2022/05/06.
//

import Cocoa


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @discardableResult
    func acquirePrivileges() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled {
            print("Access Not Enabled")
        }
        return accessEnabled
    }

    private func copyAttributeValue(_ element: AXUIElement, attribute: String) -> CFTypeRef? {
        var ref: CFTypeRef? = nil
        let error = AXUIElementCopyAttributeValue(element, attribute as CFString, &ref)
        if error == .success {
            return ref
        }
        return .none
    }
    
    private func getFocusedWindow(pid: pid_t) -> AXUIElement? {
        let element = AXUIElementCreateApplication(pid)
        if let window = self.copyAttributeValue(element, attribute: kAXFocusedWindowAttribute) {
            return (window as! AXUIElement)
        }
        return nil
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        acquirePrivileges()

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        
        let size = NSMakeSize(22, 22)
        let image = NSImage(named:"statusbaricon")
        image?.size = size
        statusItem.button?.image = image
        
        
        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                          selector: #selector(appChanged(_:)),
                                                          name: NSWorkspace.didActivateApplicationNotification,
                                                          object: nil)

    }

    
    @objc func appChanged(_ notification: NSNotification) {

        guard let app = NSWorkspace.shared.runningApplications.first(where: { $0.isActive }),
              let window = self.getFocusedWindow(pid: app.processIdentifier)
        else {
            return
        }

        let axPositionValue: AXValue = self.copyAttributeValue(window, attribute: "AXPosition") as! AXValue
        var position: CGPoint = CGPoint.zero
        AXValueGetValue(axPositionValue, AXValueType.cgPoint, &position)

        let axSizeValue: AXValue = self.copyAttributeValue(window, attribute: "AXSize") as! AXValue
        var size: CGSize = CGSize.zero
        AXValueGetValue(axSizeValue, AXValueType.cgSize, &size)

        let pointX: Double = position.x + ( size.width / 2 )
        let pointY: Double = position.y + ( size.height / 2 )
            CGWarpMouseCursorPosition( CGPoint( x: pointX, y: pointY ) )

    }

    @objc func quit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

