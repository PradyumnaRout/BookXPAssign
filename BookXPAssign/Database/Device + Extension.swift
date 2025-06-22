//
//  Device + Extension.swift
//  BookXPAssign
//
//  Created by vikash kumar on 21/06/25.
//

import Foundation
import CoreData

@objc(Device)
public class Device: NSManagedObject {
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var detailData: Data?
}

extension Device {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }
    
    var detail: DeviceData? {
        get {
            guard let data = detailData else { return nil }
            return try? JSONDecoder().decode(DeviceData.self, from: data)
        } set {
            detailData = try? JSONEncoder().encode(newValue)
            
        }
    }
}

extension Device: Identifiable {
    
}
