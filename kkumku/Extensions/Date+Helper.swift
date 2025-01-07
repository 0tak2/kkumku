//
//  Date+Helper.swift
//  kkumku
//
//  Created by 임영택 on 1/7/25.
//

import Foundation

extension Date {
    static func firstDayOfMonth(year: Int, month: Int) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components)
    }
    
    static func lastDayOfMonth(year: Int, month: Int) -> Date? {
        let calendar = Calendar.current
        
        // 다음달 1일에서 하루를 뺌
        var components = DateComponents()
        components.year = year
        components.month = month + 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard let firstDayOfNextMonth = calendar.date(from: components) else {
            return nil
        }
        
        return calendar.date(byAdding: .day, value: -1, to: firstDayOfNextMonth)
    }
}
