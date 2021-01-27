//
//  Sensor.swift
//  SwitchBotLogger
//
//  Created by sonson on 2021/01/17.
//

import Foundation
import Cocoa

struct Sensor {
    var uuid: String
    var name: String
    var timestamp: Date
    var temperture: Float
    var humidity: Float
    var battery: Float
}


extension NSMenuItem {
    
    private class var iconWidth: CGFloat {
        let label = NSTextField()
        label.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 44))
        label.stringValue = "􀛨"
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        label.backgroundColor = .clear
        label.isBezeled = false
        label.isEditable = false
        label.sizeToFit()
        return label.frame.size.width
    }
    
    private class func menuItem(with icon: String, string: String) -> NSMenuItem {
        let menuItem = NSMenuItem()
        
//        let leftMargin = CGFloat(12)
//        let bottomAndTopMargin = CGFloat(4)
        
        let label = NSTextField()
        label.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        label.stringValue = string
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        label.backgroundColor = .clear
        label.isBezeled = false
        label.isEditable = false
        label.sizeToFit()
        
        let iconLabel = NSTextField()
        iconLabel.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        iconLabel.stringValue = icon
        iconLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        iconLabel.backgroundColor = .clear
        iconLabel.isBezeled = false
        iconLabel.isEditable = false
        iconLabel.sizeToFit()
        iconLabel.alignment = .center
        
        let textHeight = label.frame.size.height + 4
        
        let view = NSView(frame: NSRect.zero)
        view.addSubview(label)
        view.addSubview(iconLabel)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        iconLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
        iconLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 2).isActive = true
        
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 2).isActive = true
        
        iconLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        label.leftAnchor.constraint(equalTo: iconLabel.rightAnchor, constant: 0).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 12).isActive = true
            
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        iconLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
                
        menuItem.view = view
        
        return menuItem
    }
    
    class func tempertureMenuItem(with sensor: Sensor) -> NSMenuItem {
        return NSMenuItem.menuItem(with: "􀇬", string: String(sensor.temperture) + "°")
    }
    
    class func humidityItem(with sensor: Sensor) -> NSMenuItem {
        return NSMenuItem.menuItem(with: "􀠑", string: String(sensor.humidity) + "%")
    }
    
    class func batteryMenuItem(with sensor: Sensor) -> NSMenuItem {
        return NSMenuItem.menuItem(with: "􀛨", string: String(sensor.battery) + "%")
    }
}

class SensorManager {
    var nameTable: [String: String] = [:]
    var sensors: [String: Sensor] = [:]
    
    func updateNameTable(newName: String, for uuid: String) {
        nameTable[uuid] = newName
        
        let applicationSupportDirectories = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        if let applicationSupportDirectory = applicationSupportDirectories.first {
            
            let jsonPath = applicationSupportDirectory.appendingPathComponent("nameTable.json")
            
            do {
                let data = try JSONSerialization.data(withJSONObject: nameTable, options: .fragmentsAllowed)
                try data.write(to: jsonPath)
            } catch {
                print(error)
            }
        }
        
        
        guard let meter = sensors[uuid] else { return }
        
        sensors[meter.uuid] = Sensor(uuid: uuid, name: newName, timestamp: meter.timestamp, temperture: meter.temperture, humidity: meter.humidity, battery: meter.battery  )
        NotificationCenter.default.post(name: Notification.Name("Updated"), object: self, userInfo: nil)
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMeter(notification:)), name: Notification.Name("Loaded"), object: nil)
        
        let applicationSupportDirectories = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        guard let applicationSupportDirectory = applicationSupportDirectories.first else { return }
        
        let jsonPath = applicationSupportDirectory.appendingPathComponent("nameTable.json")
        
        do {
            let data = try Data(contentsOf: jsonPath)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let temp = json as? [String: String] {
                temp.forEach { (key, value) in
                    nameTable[key] = value
                }
            }
        } catch {
            print(error)
        }
    }
    
    @objc func didReceiveMeter(notification : Notification) {
        
        guard let userInfo = notification.userInfo as? [String: Meter] else { return }
        
        guard let meter = userInfo["Info"] else { return }
        
        var name = ""
        
        if let registeredName = nameTable[meter.uuid] {
            name = registeredName
        } else {
            name = meter.uuid
            nameTable[meter.uuid] = meter.uuid
        }
        
        sensors[meter.uuid] = Sensor(uuid: meter.uuid, name: name, timestamp: Date(), temperture: meter.temperture, humidity: meter.humidity, battery: meter.battery)
        
        NotificationCenter.default.post(name: Notification.Name("Updated"), object: self, userInfo: userInfo)
    }
    
}
