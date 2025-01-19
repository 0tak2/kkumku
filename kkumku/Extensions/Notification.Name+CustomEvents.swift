//
//  File.swift
//  kkumku
//
//  Created by 임영택 on 1/19/25.
//

import Foundation

extension Notification.Name {
    static var dreamAdded: Notification.Name {
        return .init(rawValue: "com.youngtaek.kkumku.events.dreamAdded")
    }
    
    static var dreamEdited: Notification.Name {
        return .init(rawValue: "com.youngtaek.kkumku.events.dreamEdited")
    }
}
