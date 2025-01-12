//
//  UserSettings.swift
//  kkumku
//
//  Created by 임영택 on 1/12/25.
//

import Foundation

final class UserSettings {
    static let shared = UserSettings()
    
    private let _u = UserDefaults.standard
    
    private init() { }
    
    func string(_ item: UserDefaultsItem, or defaultValue: String) -> String {
        let key = item.getKey()
        
        if let value = _u.string(forKey: key) {
            return value
        }
        
        _u.set(defaultValue, forKey: key)
        return defaultValue
    }
    
    func array(_ item: UserDefaultsItem, or defaultValue: [Any]) -> [Any] {
        let key = item.getKey()
        
        if let value = _u.array(forKey: key) {
            return value
        }
        
        _u.set(defaultValue, forKey: key)
        return defaultValue
    }
    
    func dictionary(_ item: UserDefaultsItem, or defaultValue: [String: Any]) -> [String: Any] {
        let key = item.getKey()
        
        if let value = _u.dictionary(forKey: key) {
            return value
        }
        
        _u.set(defaultValue, forKey: key)
        return defaultValue
    }
    
    func data(_ item: UserDefaultsItem, or defaultValue: Data) -> Data {
        let key = item.getKey()
        
        if let value = _u.data(forKey: key) {
            return value
        }
        
        _u.set(defaultValue, forKey: key)
        return defaultValue
    }
    
    func integer(_ item: UserDefaultsItem) -> Int {
        let key = item.getKey()
        
        return _u.integer(forKey: key)
    }
    
    func float(_ item: UserDefaultsItem) -> Float {
        let key = item.getKey()
        
        return _u.float(forKey: key)
    }
    
    func double(_ item: UserDefaultsItem) -> Double {
        let key = item.getKey()
        
        return _u.double(forKey: key)
    }
    
    func bool(_ item: UserDefaultsItem) -> Bool {
        let key = item.getKey()
        
        return _u.bool(forKey: key)
    }
    
    func set(_ value: Any, for item: UserDefaultsItem) {
        _u.set(value, forKey: item.getKey())
    }
}

enum UserDefaultsItem {
    case wakingTime
    case bedTime
    case notificationEnabled
    
    func getKey() -> String {
        switch self {
        case .wakingTime: "wakingTime"
        case .bedTime: "bedTime"
        case .notificationEnabled: "notificationEnabled"
        }
    }
}
