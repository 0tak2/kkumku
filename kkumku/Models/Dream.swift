//
//  Dream.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import Foundation

struct Dream: Hashable {
    var id = UUID()
    var startAt: Date
    var endAt: Date
    var memo: String
    var dreamClass: DreamClass
    var isLucid: Bool
    var tags: [String] = []
    var custom: [String: String] = [:]
    
    mutating func setStartDateWithSetting() {
        let settings = UserSettings.shared
        let calendar = Calendar.current
        let bedTimeStrFallback = Date.fromHourAndMinute(hour: 22, minute: 00)!.toISOString()
        let bedTimeRaw = settings.string(.bedTime, or: bedTimeStrFallback)
        let userBedTime = Date.fromISOString(isoString: bedTimeRaw)!
        let (hour, minute) = (userBedTime.toHourAndMinute()[0], userBedTime.toHourAndMinute()[1])
        
        var bedTimeToShow = Date.now
        if let todayBedTime = Date.fromHourAndMinute(hour: hour, minute: minute) {
            if todayBedTime <= Date.now { // 오늘 일자의 취침 시각이 현재보다 과거라면 바로 적용
                bedTimeToShow = todayBedTime
            } else { // 오늘 일자의 취침 시간이 현재보다 미래라면 어제의 취침 시간을 적용
                let yesterDayBedTime = calendar.date(byAdding: .day, value: -1, to: todayBedTime)
                bedTimeToShow = yesterDayBedTime ?? Date.now
            }
        }
        
        self.startAt = bedTimeToShow
    }
}

struct DreamEncodable: Hashable, Encodable {
    var id = UUID()
    var startAt: Date
    var endAt: Date
    var memo: String
    var dreamClass: String
    var isLucid: Bool
    var tags: [String] = []
    var custom: [String: String] = [:]
    
    init(from model: Dream) {
        self.id = model.id
        self.startAt = model.startAt
        self.endAt = model.endAt
        self.memo = model.memo
        self.dreamClass = model.dreamClass.descriptionFull()
        self.isLucid = model.isLucid
        self.tags = model.tags
        self.custom = model.custom
    }
}
