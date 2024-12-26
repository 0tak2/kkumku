//
//  Date+Localized.swift
//  kkumku
//
//  Created by 임영택 on 12/26/24.
//

import Foundation

extension Date {
    var localizedString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        let calendar = NSCalendar.current.dateComponents([.year], from: self)
        let calendarNow = NSCalendar.current.dateComponents([.year], from: Date.now)
        if calendar.year != calendarNow.year {
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분"
        } else {
            dateFormatter.dateFormat = "MM월 dd일 a hh시 mm분"
        }
        
        return dateFormatter.string(from: self)
    }
}
