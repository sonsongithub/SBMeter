//
//  BLEController.swift
//  SwitchBotLogger
//
//  Created by sonson on 2021/01/17.
//

import Foundation
import CoreBluetooth

struct Meter {
    let uuid: String
    let humidity: Float
    let temperture: Float
    let battery: Float
}

private extension Data {
    
    func extractPayload() -> (Float, Float, Float)? {
        guard self.count == 6 else { return nil }
        return self.withUnsafeBytes { rawBufferPointer -> (Float, Float, Float) in
            let rawPtr = rawBufferPointer.baseAddress!
            let bytes: [UInt8] = (0..<6).map { (i: Int) -> UInt8 in
               return rawPtr.advanced(by: i).load(as: UInt8.self)
            }
            let temperture = Float(bytes[3] & 15) / 10.0 + Float(bytes[4] & 127)
            let humidity = Float(bytes[5] & 127)
            let battery = Float(bytes[2] & 127)
            
            return (temperture, humidity, battery)
        }
    }
    
}

class BLEController: NSObject, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager?
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
        switch central.state {
        case .poweredOn:
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
            break
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        guard let uuidList = advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID] else { return }
        
        guard let uuid = uuidList.first else { return }
        
        guard uuid.uuidString == "CBA20D00-224D-11E6-9FB8-0002A5D5C51B" else { return }
        
        guard let dictionary = advertisementData["kCBAdvDataServiceData"] as? [CBUUID: Data] else { return }
        
        guard let data = dictionary[CBUUID(string: "0D00")] else { return }
        
        guard let (temperture, humidity, battery) = data.extractPayload() else { return }
        
        let meter = Meter(uuid: peripheral.identifier.uuidString, humidity: humidity, temperture: temperture, battery: battery)
        
        print("UUID: " + peripheral.identifier.uuidString)
        print("temperture: " + String(temperture))
        
        let userInfo: [String: Meter] = ["Info": meter]
        
        NotificationCenter.default.post(name: Notification.Name("Loaded"), object: nil, userInfo: userInfo)
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}
