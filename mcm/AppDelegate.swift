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
    var locationOfApps: [ String: CGPoint ] = [:]
    
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
                                                          name: NSWorkspace.didDeactivateApplicationNotification,
                                                          object: nil)

    }

    @objc func appChanged(_ notification: NSNotification) {

        guard let prevApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let prevAppIdentifier: String = prevApp.bundleIdentifier
        else{
            return
        }
        guard let app = NSWorkspace.shared.runningApplications.first(where: { $0.isActive }),
              let appIdentifier = app.bundleIdentifier,
              let window = self.getFocusedWindow(pid: app.processIdentifier)
        else {
            return
        }

       
        let mouseLocEvent = CGEvent.init(source: nil)
        let currentLocation: CGPoint = mouseLocEvent!.location

        let axFrameValueCFType: CFTypeRef? = self.copyAttributeValue(window, attribute: "AXFrame")
        if(  axFrameValueCFType == nil ){
            return
        }
        let axFrameValue: AXValue = axFrameValueCFType as! AXValue
        var currentWindowRect: CGRect = CGRect.zero
        AXValueGetValue(axFrameValue, AXValueType.cgRect, &currentWindowRect)
        
        // マウスカーソルの位置が新しいアプリのウィンドウの範囲内(クリックでアプリ切り替えをしたと見なす)の場合は何もしない
        if( currentWindowRect.contains( currentLocation ) == true ){
            return
        }

        var newLocation: CGPoint = CGPoint.zero

        if( locationOfApps[ appIdentifier ] != nil ){
            newLocation = locationOfApps[ appIdentifier ] as! CGPoint
        }else{
            let axPositionValue: AXValue = self.copyAttributeValue(window, attribute: "AXPosition") as! AXValue
            var position: CGPoint = CGPoint.zero
            AXValueGetValue(axPositionValue, AXValueType.cgPoint, &position)

            var size: CGSize = CGSize.zero
            let axSizeValue: AXValue = self.copyAttributeValue(window, attribute: "AXSize") as! AXValue
            AXValueGetValue(axSizeValue, AXValueType.cgSize, &size)

            let pointX: Double = position.x + ( size.width / 2 )
            let pointY: Double = position.y + ( size.height / 2 )

            newLocation = CGPoint( x: pointX, y: pointY )
        }

        if( prevAppIdentifier != nil ){
            // 切り替え前のアプリに紐づかせて、マウスカーソル位置を保存
            locationOfApps[ prevAppIdentifier ] = currentLocation
        }
        
        CGWarpMouseCursorPosition( newLocation )
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

