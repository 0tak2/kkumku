//
//  Date+Log.swift
//  kkumku
//
//  Created by 임영택 on 1/5/25.
//

import Foundation

extension Date {
    var timeStampForLog: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        return dateFormatter.string(from: self)
    }
}
