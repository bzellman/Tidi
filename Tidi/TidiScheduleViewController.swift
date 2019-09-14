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
    
    
//    var currentNotification : (hour: Int, mintue: Int, weekdayArray: [Int])? {
//        didSet {
//            var minString = String(currentNotification?.hour)
//            var hourString = String(currentNotification?.mintue)
//            hourDropDown.setTitle(minString)
//            minuteDropdown.setTitle(hourString)
//        }
//    }
    
    
    override func viewDidLoad() {
        //set hour dropdown
        setOutletValues()
        hourDropDown.removeAllItems()
        for hour in 1...12 {
            hourDropDown.addItem(withTitle: String(hour))
        }
        
        minuteDropdown.removeAllItems()
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
        
       getCurrentNotification()
 
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
        var isPM :Bool = false
        
        if amPmDropdown.indexOfSelectedItem == 1 && selectedHour != 12 {
            isPM = true
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
                notificationContent.title = "It's Time To Clean Up"
                notificationContent.body = "Click To Start Cleaning"
                notificationContent.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(identifier: "tidi_Reminder_Notification", content: notificationContent, trigger: trigger)
                
                notificationCenter.add(request) {(error) in
                    if let error = error {
                        print(error)
                        //TODO: Set alert there was an error saving
                    }
                }
            }
            
            StorageManager().setNotificationPlist(hour : selectedHour, minute : selectedMinute, isPM : isPM, daysSetArray : activeDaysArray, isSet : true)
        } else {
            print("No Date Set")
            //TODO: Set Alert that user needs to select a day before saving
        }
        
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
        var notificationDetails = StorageManager().getNotificationPlist()
        if notificationDetails?.isSet != false || notificationDetails != nil {
            
            if notificationDetails!.hour > 12 {
               notificationDetails!.hour = notificationDetails!.hour - 12
            }
            
            hourDropDown.title = String(notificationDetails!.hour)
            minuteDropdown.title = String(notificationDetails!.minute)
            
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
        
    }

}
