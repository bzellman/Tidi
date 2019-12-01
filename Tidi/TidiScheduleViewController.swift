//
//  TidiScheduleViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 9/9/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa
import UserNotifications

class TidiScheduleViewController: NSViewController {
    
    var selectedHour : Int?
    var selectedMinute : Int?
    var selectedAMPM : String?
    var isNotificationSet : Bool = false
    var standardNotificationIdentiferString : String = "tidi_Reminder_Notification"
    
    @IBOutlet weak var hourDropDown: NSPopUpButton!
    @IBOutlet weak var minuteDropdown: NSPopUpButton!
    @IBOutlet weak var amPmDropdown: NSPopUpButton!
    
    
    @IBOutlet weak var sundayButtonOutlet: NSButton!
    @IBOutlet weak var mondayButtonOutlet: NSButton!
    @IBOutlet weak var tuesdayButtonOutlet: NSButton!
    @IBOutlet weak var wednesdayButtonOutlet: NSButton!
    @IBOutlet weak var thursdayButtonOutlet: NSButton!
    @IBOutlet weak var fridayButtonOutlet: NSButton!
    @IBOutlet weak var saturdayButtonOutlet: NSButton!
    
    override func viewDidLoad() {
        setOutletValues()
        getCurrentNotification()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeAllScheduledNotifications), name: NSNotification.Name("clearWeeklyReminderClickedNotification"), object: nil)

    }
    
    @IBAction func hourDropdownValueSelected(_ sender: Any) {
        hourDropDown.title = hourDropDown.titleOfSelectedItem!
    }
    
    
    @IBAction func minuteDropdownValueSelected(_ sender: Any) {
        minuteDropdown.title = minuteDropdown.titleOfSelectedItem!
    }
    
    @IBAction func amPmDropdownValueSelected(_ sender: Any) {
        amPmDropdown.title = amPmDropdown.titleOfSelectedItem!
    }
    
    
    @IBAction func closeButtonPushed(_ sender: Any) {
        self.dismiss(sender)
    }
    
    
    @IBAction func saveButtonPushed(_ sender: Any) {
        
        var hourString = String(hourDropDown.itemTitle(at: hourDropDown.indexOfSelectedItem))
        selectedHour = Int(hourString)
        
        var minString = String(minuteDropdown.itemTitle(at: minuteDropdown.indexOfSelectedItem))
        minString = minString.replacingOccurrences(of: ":", with: "")
        selectedMinute = Int(minString)
        

        var isPM : Bool = false
        
        if amPmDropdown.indexOfSelectedItem == 2 && selectedHour != 12 {
            isPM = true
            selectedHour = selectedHour! + 12
        }

        removeAllScheduledNotifications()
        let activeDaysArray = getButtonValues()
        
        if activeDaysArray.count > 0 {
            let notificationCenter = UNUserNotificationCenter.current()
            for day in activeDaysArray {
                
                var dateComponents = DateComponents()
                dateComponents.hour = selectedHour
                dateComponents.minute = selectedMinute
                dateComponents.weekday = day
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "It's Time To Clean Up"
                notificationContent.body = "Click To Start Cleaning"
                notificationContent.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(identifier: standardNotificationIdentiferString, content: notificationContent, trigger: trigger)
                
                notificationCenter.add(request) {(error) in
                    if let error = error {
                        print(error)
                        //TODO: Set alert there was an error saving
                    }
                }
            }
            
            StorageManager().setNotificationPlist(hour : selectedHour!, minute : selectedMinute!, isPM : isPM, daysSetArray : activeDaysArray, isSet : true)
        } else {
            print("No Date Set")
            //TODO: Set Alert that user needs to select a day before saving
        }
        
        getCurrentNotificationsFromNotificationCenter()
        self.dismiss(sender)

    }
    
    @objc func removeAllScheduledNotifications() {
        var notificationCount : Int = 0
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [standardNotificationIdentiferString])
    }
    
    
    
    func setOutletValues() {
        sundayButtonOutlet.tag = 1
        mondayButtonOutlet.tag = 2
        tuesdayButtonOutlet.tag = 3
        wednesdayButtonOutlet.tag = 4
        thursdayButtonOutlet.tag = 5
        fridayButtonOutlet.tag = 6
        saturdayButtonOutlet.tag = 7
        
        hourDropDown.removeAllItems()
        minuteDropdown.removeAllItems()
        
        hourDropDown.insertItem(withTitle: "Hour", at: 0)
        for hour in 1...12 {
            hourDropDown.addItem(withTitle: String(hour))
        }
        
        
        minuteDropdown.insertItem(withTitle: "Min", at: 0)
        for min in 0...55 {
            if min % 5 == 0 {
                var minStringToAdd : String?
                if min < 10 {
                    minStringToAdd = ":0"
                } else {
                    minStringToAdd = ":"
                }
                let minvalue = String(min)
                let fullMinuteString = minStringToAdd! + minvalue
                minuteDropdown.addItem(withTitle: fullMinuteString)
            }
        }
        
        amPmDropdown.insertItem(withTitle: "AM ", at: 0)
        amPmDropdown.insertItem(withTitle: "AM", at: 1)
        amPmDropdown.insertItem(withTitle: "PM", at: 2)
    }
    
    func getButtonValues() -> [Int] {
        var activeDaysArray : [Int] = []
        let dayButtonArray = [sundayButtonOutlet, mondayButtonOutlet, tuesdayButtonOutlet, wednesdayButtonOutlet, thursdayButtonOutlet, fridayButtonOutlet, saturdayButtonOutlet]
        
        for day in dayButtonArray {
            if day?.state == .on {
                activeDaysArray.append(day!.tag)
            }
            
        }
        
        return activeDaysArray
    }
    
    func getCurrentNotificationsFromNotificationCenter() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            var notificationIds:[UNNotificationRequest] = []
            for notification in notifications {
                if notification.identifier == "tidi_Reminder_Notification"{
                    notificationIds.append(notification)
                }
            }
            
            for notification in notificationIds {
                print("Notification: ", notification.trigger)
            }
            
        })
    }
    
    
    
    
    func getCurrentNotification() {
        var notificationDetails = StorageManager().getNotificationPlist()
        var minuteString : String = ""
        if notificationDetails?.isSet != false && notificationDetails != nil {
            isNotificationSet = true
            if notificationDetails!.hour > 12 {
               notificationDetails!.hour = notificationDetails!.hour - 12
            }
            
            hourDropDown.title = String(notificationDetails!.hour)
            hourDropDown.selectItem(at: notificationDetails!.hour)
            if notificationDetails!.minute == 0 {
                minuteString = ":00"
            } else if notificationDetails?.minute == 5 {
                minuteString = ":05"
            } else {
                minuteString = ":" + String(notificationDetails!.minute)
            }
            
            minuteDropdown.title = minuteString

            minuteDropdown.selectItem(at: notificationDetails!.minute/5 + 1)
            if notificationDetails!.isPM {
                amPmDropdown.title = "PM"
            } else {
                amPmDropdown.title = "AM"
            }
            
            for day in notificationDetails!.daysSetArray {
                let button = self.view.viewWithTag(day) as? NSButton
                button!.state = .on
            }
            
        }
        
        getCurrentNotificationsFromNotificationCenter()
    }

}
