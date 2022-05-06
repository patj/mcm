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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
        guard let pid: Int32 = NSWorkspace.shared.frontmostApplication?.processIdentifier else {
            return
        }

        let targetWindow: NSDictionary? = getWindowList( pid:pid )?[0]

        if( targetWindow != nil ){

            let Height: Double? = ( ( targetWindow?[ kCGWindowBounds ] as? NSDictionary)?["Height"] ) as? Double
            let Width: Double? = ( ( targetWindow?[ kCGWindowBounds ] as? NSDictionary)?["Width"] ) as? Double
            let x: Double? = ( ( targetWindow?[ kCGWindowBounds ] as? NSDictionary)?["X"] ) as? Double
            let y: Double? = ( ( targetWindow?[ kCGWindowBounds ] as? NSDictionary)?["Y"] ) as? Double

            let pointX: Double = ( x ?? 0 ) + ( ( Width ?? 0 ) / 2 )
            let pointY: Double = ( y ?? 0 ) + ( ( Height ?? 0 ) / 2 )
            CGWarpMouseCursorPosition( CGPoint( x: pointX, y: pointY ) )
        }
    }

    func getWindowList( pid:Int32 ) -> [NSDictionary]? {
        guard let windowList: NSArray = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) else {
            return nil
        }

        let tmpWindowList = windowList as! [NSDictionary]

        let appWindowList = tmpWindowList.filter { (windowInfo: NSDictionary) -> Bool in
            return windowInfo[kCGWindowOwnerPID] as! Int == pid
        }

        return appWindowList
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

