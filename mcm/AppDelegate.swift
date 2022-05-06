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
        menu.addItem(NSMenuItem(title: "quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        
        statusItem.button?.title = "MCM"
    }
    
    @objc func quit(_ sender: NSMenuItem) {
        print("quit")
        NSApplication.shared.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

