//
//  Helper.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/9/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Helper: UIView {
    
    static var date = Date()
    static var dateFormatter = DateFormatter()
    
    static func setupDateFormatter() {
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+6") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
    }
    
    
    static func connectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return (isReachable && !needsConnection)
    }
    
    
    
    static func displayMonthDayYear(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    
    static func displayWeekDayMonth(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM "
        
        return dateFormatter.string(from: date).uppercased()
    }
    
    static func displayDayMonth(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        return dateFormatter.string(from: date)
    }
    
    static func displayDayOfMonth(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "d"
        
        return dateFormatter.string(from: date)
    }
    
    static func displayMonth(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        return dateFormatter.string(from: date)
    }
    
    static func displayDayOfMonth(timestamp: Int) -> Int {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "d"
        
        return Int(dateFormatter.string(from: date))!
    }
    
    static func display24HourTime(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
    static func display12HourTime(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    static func displayDate12HourFull(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "hh:mm a, MMM d"
        
        return dateFormatter.string(from: date)
    }
    
    static func displayDate24HourFull(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        setupDateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMM d"
        
        return dateFormatter.string(from: date)
    }
    
    
    static func displayHourMinuteTimestamp(timestamp: Int) -> Int {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let hours = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)
        
        return (hours==0 ? 24 : hours)*3600 + minutes*60
    }
    
    static func display12HourTimeGMT0(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    static func display24HourTimeGMT0(timestamp: Int) -> String {
        date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
    
    
    
    
    static func getReverse(timestamp: Int) -> String {
        let diff = Int(Date().timeIntervalSince1970) - timestamp
        if diff < 60 {
            return "\(diff)s ago"
        } else if diff < 60*60 {
            return "\(diff/60)min ago"
        } else if diff < 60*60*24 {
            return "\(diff/3600)h ago"
        } else if diff < 60*60*7*24 {
            return "\(diff/(60*60*24))d ago"
        } else if diff < 60*60*24*28 {
            return "\(diff/(60*60*24*7))w ago"
        } else if diff < 60*60*24*365 {
            return "\(diff/(60*60*24*30))mon ago"
        } else {
            return "\(diff/(60*60*24*365))y ago"
        }
    }
    
}


extension Helper: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        completionHandler()
    }
    
    func scheduleNotification(identifier: String, content: UNMutableNotificationContent, dateComponents: DateComponents, repeats: Bool) {
           
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}



//MARK: GET UICOLOR BY HEXCODE
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    // MARK: Initialization

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb)else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Computed Properties

    var toHex: String? {
        return toHex()
    }

    // MARK: - From UIColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
