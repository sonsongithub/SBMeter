//
//  AppDelegate.swift
//  SBMeter
//
//  Created by sonson on 2021/01/19.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem = NSStatusBar.system.statusItem(withLength: -1)
    let bleController = BLEController()
    let sensorManager = SensorManager()
    
    var editMenuItemTable: [String: NSMenuItem] = [:]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let menu = NSMenu()
        if let button = self.statusItem.button {
            button.image = NSImage.init(systemSymbolName: "thermometer", accessibilityDescription: nil)
        }
        self.statusItem.menu = menu
        
        do {
            let menuItem = NSMenuItem()
            menuItem.title = "About SBMeter"
            menuItem.action = #selector(AppDelegate.about(sender:))
            menu.addItem(menuItem)
        }
        
        let menuItem = NSMenuItem()
        menuItem.title = "Quit"
        menuItem.action = #selector(AppDelegate.quit(sender:))
        menu.addItem(menuItem)
    
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdate(notification:)), name: Notification.Name("Updated"), object: nil)
    }
    
    @objc func didUpdate(notification : Notification) {
        
        guard let object = notification.object as? SensorManager else { return }
        guard object === sensorManager else { return }

        guard let menu = self.statusItem.menu else { return }
        
        menu.removeAllItems()
        editMenuItemTable.removeAll()
        
        if let button = self.statusItem.button {
            button.image = NSImage.init(systemSymbolName: "thermometer", accessibilityDescription: nil)
        }
        
        sensorManager.sensors.forEach { (key, value) in
            
            let subMenu = NSMenu()
            
            let nameItem = NSMenuItem()
            nameItem.title = value.name
            
            let menuItem = NSMenuItem()
            menuItem.title = "Edit name"
            menuItem.action = #selector(AppDelegate.editName(sender:))
            subMenu.addItem(menuItem)
            menu.addItem(nameItem)
            menu.setSubmenu(subMenu, for: nameItem)
            
            editMenuItemTable[key] = menuItem
            
            menu.addItem(NSMenuItem.tempertureMenuItem(with: value))
            menu.addItem(NSMenuItem.humidityItem(with: value))
            menu.addItem(NSMenuItem.batteryMenuItem(with: value))
            menu.addItem(NSMenuItem.separator())
        }
        do {
            let menuItem = NSMenuItem()
            menuItem.title = "About SBMeter"
            menuItem.action = #selector(AppDelegate.about(sender:))
            menu.addItem(menuItem)
        }
        do {
            let menuItem = NSMenuItem()
            menuItem.title = "Quit"
            menuItem.action = #selector(AppDelegate.quit(sender:))
            menu.addItem(menuItem)
        }
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func quit(sender: NSButton) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func about(sender: NSButton) {
        let str = NSMutableAttributedString(string: "Yuichi Yoshida, all rights reserved.\nhttps://github.com/sonsongithub/SBMeter")
        str.addAttribute(.link, value: URL(string: "https://github.com/sonsongithub/SBMeter")!, range: NSRange(location: 37, length: 39))
        let info = [NSApplication.AboutPanelOptionKey.credits: str]
        NSApp.orderFrontStandardAboutPanel(options: info)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func editName(sender: Any) {
        
        guard let menuItem = sender as? NSMenuItem else { return }
        
        let matchedEntries = editMenuItemTable.filter { (element) -> Bool in
            return (element.value === menuItem)
        }
        
        guard let uuid = matchedEntries.first?.key else { return }
        
        print(uuid)
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateController(withIdentifier: "NameEditWindowController") as? NameEditWindowController {
            if let window = controller.window {
                if let nameEditViewController = controller.contentViewController as? NameEditViewController {
                    nameEditViewController.uuidLabel?.stringValue = uuid
                }
                switch NSApp.runModal(for: window) {
                case .OK:
                    if let newName = controller.inputName() {
                        sensorManager.updateNameTable(newName: newName, for: uuid)
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
}
