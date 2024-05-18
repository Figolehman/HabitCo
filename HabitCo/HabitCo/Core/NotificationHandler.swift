//
//  NotificationHandler.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 15/04/24.
//

import Foundation
import UserNotifications

class NotificationHandler {
    
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isSuccess, error in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendNotification(date: Date, weekdays: [Int], title: String, body: String, withIdentifier id: String) {
//        removeAllNotification()
        removeNotification(withIdentifier: id)
        
        for day in weekdays {
            var dateComponents = date.get(.hour, .minute)
            dateComponents.weekday = day
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: "\(id)-\(day)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in }
    }
//    
//    func sendNotification(date: Date, habitWeekdays: [Int], title: String, body: String, withIdentifier id: String) {
//        for habitDay in habitWeekdays {
//            let dateComponents = date.get(.hour, .minute)
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//            
//            let content = UNMutableNotificationContent()
//            content.title = title
//            content.body = body
//            content.sound = UNNotificationSound.default
//            
//            let request = UNNotificationRequest(identifier: "\(id)", content: content, trigger: trigger)
//            
//            UNUserNotificationCenter.current().add(request)
//        }
//        
//    }
    
    func sendNotification(timeInterval: Double = 10, title: String, body: String) {
        var trigger: UNNotificationTrigger?
        
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "journal", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeNotification(withIdentifier: String) {
        var identifiers = [String]()
        for i in 1...7 {
            identifiers.append("\(withIdentifier)-\(i)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeAllNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func replaceNotification(withIdentifier id: String) {
        // ngambil notif yang idnya sama
        var selectedNotification = [UNNotificationRequest]()
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            selectedNotification = notifications.filter {
                $0.identifier.starts(with: "\(id)-")
            }
            if selectedNotification.count == 0 {
                return
            }
            
            var weekdays = [Int]()
            let trigger = selectedNotification.first!.trigger as! UNCalendarNotificationTrigger
            
            for notification in selectedNotification {
                let currentTrigger = notification.trigger as! UNCalendarNotificationTrigger
                weekdays.append(currentTrigger.nextTriggerDate()!.get(.weekday))
            }
            
            self.sendNotification(date: trigger.nextTriggerDate()!, weekdays: weekdays, title: "KEGANTI GA?", body: "UDAH GANTI SI", withIdentifier: id)
            
        }
        
    }
    
}
