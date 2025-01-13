//
//  Notification.swift
//  kkumku
//
//  Created by 임영택 on 1/13/25.
//

import NotificationCenter

final class NotificationSupport {
    static let shared = NotificationSupport()
    
    private init() { }
    
    private let center = UNUserNotificationCenter.current()
    
    func isAuthorized() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
        
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    func registerDailyNotification(hour: Int, minute: Int, title: String, body: String) async throws {
        // 내용 지정
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // 시간 지정
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = hour
        dateComponents.minute = minute
           
        // 트리거 지정
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: true)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)


        // 알림 요청 등록
        do {
            let authorized = try await isAuthorized()
            if !authorized {
                throw NSError(domain: "알림 권한을 획득할 수 없습니다.", code: -1)
            }
            
            try await center.add(request)
            Log.info("알림 요청을 잘 등록했습니다. hour=\(hour) minute: \(minute) title: \(title) body: \(body)", for: .system)
        } catch let error as NSError {
            Log.error("알림 요청 등록에 실패했습니다. hour=\(hour) minute: \(minute) title: \(title) body: \(body) error: \(error.description) \(error.domain) \(error.userInfo)", for: .system)
            throw error
        }
    }
    
    func removeAll() {
        center.removeAllPendingNotificationRequests()
    }
}
