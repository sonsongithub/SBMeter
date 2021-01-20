//
//  NameEditWindowController.swift
//  SBMeter
//
//  Created by sonson on 2021/01/19.
//

import Cocoa

class NameEditWindowController: NSWindowController {
    
    func inputName() -> String? {
        if let viewController = self.window?.contentViewController as? NameEditViewController {
            if let textField = viewController.textField {
                return textField.stringValue
            }
        }
        return nil
    }
    
    deinit {
        print("deinit NameEditWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.makeKey()
        self.window?.makeKeyAndOrderFront(self)
        self.window?.makeMain()
        print(#function)
    }
    
    override func close() {
        super.close()
        print(#function)
    }
    
    override func dismissController(_ sender: Any?) {
        super.dismissController(sender)
        print(#function)
        
    }
}

class NameEditViewController: NSViewController {
    
    @IBOutlet var textField: NSTextField?
    @IBOutlet var uuidLabel: NSTextField?
    
    @IBAction func didPushOK(_ sender: Any) {
        NSApp.stopModal(withCode: NSApplication.ModalResponse.OK)
        self.view.window?.orderOut(nil)
    }
    
    @IBAction func didPushCancel(_ sender: Any) {
        NSApp.stopModal(withCode: NSApplication.ModalResponse.cancel)
        self.view.window?.orderOut(nil)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        print(#function)
        self.view.window?.title = "Edit name"
    }
    
}
