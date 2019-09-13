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
//    var selectedWeekDays :
//    var currentNotification : (hour: Int, mintue: Int, weekday: [Int])?
    
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
    
    
    var currentNotification : (hour: Int, mintue: Int, weekdayArray: [Int])? {
        didSet {
            print(currentNotification?.weekdayArray)
        }
    }
    
    
    override func viewDidLoad() {
        //set hour dropdown
        setOutletValues()
        getCurrentNotification()
        hourDropDown.removeAllItems()
        for hour in 1...12 {
            hourDropDown.addItem(withTitle: String(hour))
        }
        
        minuteDropdown.removeAllItems()
        for min in 0...60 {
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
 
    }
    
    override func viewWillAppear() {
        super .viewWillAppear()
        
    }
    
    @IBAction func hourDropdownValueSelected(_ sender: Any) {
        hourDropDown.title = hourDropDown.titleOfSelectedItem!
    }
    
    @IBAction func closeButtonPushed(_ sender: Any) {
        self.dismiss(sender)
    }
    
    
    @IBAction func saveButtonPushed(_ sender: Any) {
        
        var selectedHour : Int = hourDropDown.indexOfSelectedItem + 1
        var selectedMinute : Int = minuteDropdown.indexOfSelectedItem * 5
        
        if amPmDropdown.indexOfSelectedItem == 1 && selectedHour != 12 {
            selectedHour = selectedHour + 12
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
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "It's time to clean up"
                notificationContent.body = "Click to start Cleaning"
                notificationContent.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(identifier: "tidi_Reminder_Notification", content: notificationContent, trigger: trigger)
                
                notificationCenter.add(request) {(error) in
                    if let error = error {
                        print(error)
                        //TODO: Set alert there was an error saving
                    }
                }
            }
            
        } else {
            print("No Date Set")
            //TODO: Set Alert that user needs to select a day before saving
        }
        
        print("Save")
        self.dismiss(sender)

    }
    
    func removeAllScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["tidi_Reminder_Notification"])
    }
    
    func setOutletValues() {
        sundayButtonOutlet.tag = 1
        mondayButtonOutlet.tag = 2
        tuesdayButtonOutlet.tag = 3
        wednesdayButtonOutlet.tag = 4
        thursdayButtonOutlet.tag = 5
        fridayButtonOutlet.tag = 6
        saturdayButtonOutlet.tag = 7
    }
    
    func getButtonValues() -> [Int] {
        var activeDaysArray : [Int] = []
        let dayButtonArray = [sundayButtonOutlet, mondayButtonOutlet, tuesdayButtonOutlet, wednesdayButtonOutlet, thursdayButtonOutlet, fridayButtonOutlet, saturdayButtonOutlet, sundayButtonOutlet]
        
        for day in dayButtonArray {
            if day?.state == .on {
                activeDaysArray.append(day!.tag)
            }
            
        }
        
        return activeDaysArray
    }
    
    func getCurrentNotification() {
        var hour : Int?
        var minute : Int?
        var weekdayArray : [Int]? = []
        var isSet : Bool?
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            let pendingNotifications : [UNNotificationRequest] = notifications
            for notification in pendingNotifications {
                let notificationTrigger  = notification.trigger as? UNCalendarNotificationTrigger
                let dateComponents = notificationTrigger?.dateComponents
                hour = dateComponents?.hour
                minute = dateComponents?.minute
                weekdayArray?.append((dateComponents?.weekday)!)
                print(dateComponents?.weekday)
                isSet = true
            }
            if isSet == true {
                self.currentNotification = (hour!, minute!, weekdayArray!)
            }
            
        }
    }

}
