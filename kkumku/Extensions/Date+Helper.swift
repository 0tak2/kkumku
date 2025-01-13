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
    
    static func fromHourAndMinute(hour: Int, minute: Int) -> Date? {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.year, .month, .day], from: Date.now)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        return calendar.date(from: components)
    }
    
    /**
     Date 객체로부터 시간과 분을 반환한다.
     @return Array<Int> [시간, 분]
        시간과 분을 객체로부터 알아낼 수 없으면, [0, 0]을 반환한다.
     */
    func toHourAndMinute() -> [Int] {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.hour, .minute], from: self)
        
        return [components.hour ?? 0, components.minute ?? 0]
    }
    
    func toISOString() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    static func fromISOString(isoString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: isoString)
    }
}
