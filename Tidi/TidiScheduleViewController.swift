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
    var dayOfWeekButtonArray : [NSButton] = []
    let standardNotificationIdentiferString : String = "tidi_Reminder_Notification"
    let notificationManger = TidiNotificationManager()
    let storageManager = StorageManager()
    let alertManager = AlertManager()
    var shouldRecheckForSettingPermission : Bool = false
    var isOnboarding : Bool = false
    
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
    @IBOutlet weak var debugMinText: NSTextField!
    
    override func viewDidLoad() {
        
        #if DEBUG
            self.debugMinText.isHidden = false
        #endif
        
        setOutletValues()
        getCurrentNotification()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeAllScheduledNotificationsPressed), name: NSNotification.Name("clearWeeklyReminderClickedNotification"), object: nil)
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
        if isOnboarding {
            //To-do: need to set as delegate
            let mainWindowContainerViewController = self.presentingViewController as! MainWindowContainerViewController
            mainWindowContainerViewController.completedReminder()
        } else {
            self.dismiss(sender)
        }
        
    }
    
    @IBAction func resetButtonPushed(_ sender: Any) {
        removeAllScheduledNotificationsPressed()
    }
    
    
    @IBAction func saveButtonPushed(_ sender: Any) {
        
        var saveWasSuccessful: Bool = false
        if self.notificationManger.removeAllScheduledNotifications() == true {
            var debugMinOverrideString : String = ""
            var isDaySet : Bool = false
            
            for dayButton in dayOfWeekButtonArray {
                if dayButton.state == .on {
                   isDaySet = true
                   break
                }
            }
            
            if debugMinText.stringValue != "" {
                debugMinOverrideString = debugMinText.stringValue
                minuteDropdown.title = "DEBUG"
            }
                   
            if hourDropDown.title == "Hour" || minuteDropdown.title == "Min" || isDaySet == false {
                alertManager.showSheetAlertWithOnlyDismissButton(messageText: "UhOh.. Looks like your missing something. \n\nPlease make sure to select at least one day of the week and a time you want to be remided to clean up on.", buttonText: "Okay", presentingView: self.view.window!)

            } else {
               let hourString = String(hourDropDown.itemTitle(at: hourDropDown.indexOfSelectedItem))
               selectedHour = Int(hourString)
                       

                
                if debugMinOverrideString != "" {
                    selectedMinute = Int(debugMinOverrideString)
                } else {
                    var minString = String(minuteDropdown.itemTitle(at: minuteDropdown.indexOfSelectedItem))
                    minString = minString.replacingOccurrences(of: ":", with: "")
                    selectedMinute = Int(minString)
                }
               
               

               var isPM : Bool = false
               
               if amPmDropdown.title == "PM" && selectedHour != 12 {
                   isPM = true
                   selectedHour = selectedHour! + 12
               } else if amPmDropdown.title == "AM" && selectedHour == 12 {
                   selectedHour = 0
                }

               
               let activeDaysArray = getButtonValues()
               

                notificationManger.checkForNotificationPermission()
               if activeDaysArray.count > 0 {
                   
                   for day in activeDaysArray {
                       
                       var dateComponents = DateComponents()
                       dateComponents.hour = selectedHour
                       dateComponents.minute = selectedMinute
                       dateComponents.weekday = day

                       let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                       
                       //Need to set the notification string by appending the day since each notification ID has to be unique or it will overwrite the previous day's Notifcation
                       let notificationIDString : String = standardNotificationIdentiferString+String(day)
                    
                        if storageManager.getNotificationAuthorizationState() != "allowed" {
                            if storageManager.getNotificationAuthorizationState() == "notSet" {
                                alertManager.showSheetAlertWithOneAction(messageText: "Tidi needs permission to send you reminders.", dismissButtonText: "Nope", actionButtonText: "Okay", presentingView: self.view.window!) {
                                            self.notificationManger.promptForPermisson()
                                }
                            } else {
                                alertManager.showSheetAlertWithOnlyDismissButton(messageText: "Tidi needs permission to send you reminders. \n\nPlease try again after granting permission in your System Preferences. \n\n If you deleted Tidi from Notifications, you may need to relaunch Tidi.", buttonText: "Okay", presentingView: self.view.window!)
                                        shouldRecheckForSettingPermission = true
                                }
                            break
                        } else {
                            notificationManger.setReminderNotification(identifier: notificationIDString, notificationTrigger: trigger, presentingView: self.view.window!)
                            if storageManager.setReminderNotificationToUserDefaults(hour : selectedHour!, minute : selectedMinute!, isPM : isPM, daysSetArray : activeDaysArray, isSet : true) == false {
                                alertManager.showSheetAlertWithOnlyDismissButton(messageText: "Looks like something went wrong saving your reminder. \n\nPlease try again", buttonText: "Okay", presentingView: self.view.window!)
                            } else {
                                saveWasSuccessful = true
                            }
                        }
                    
                    }
                        
                   if saveWasSuccessful {
                        if isOnboarding {
                            let mainWindowContainerViewController = self.presentingViewController as! MainWindowContainerViewController
                            mainWindowContainerViewController.completedReminder()
                        } else {
                            viewDidLoad()
                            self.dismiss(sender)
                        }
                       
                   }
               
                   }
                
               }
                
            }
        

    }
    
    
    @objc func removeAllScheduledNotificationsPressed() {
        /// This was split out into to funcs since selectors should not take params
        if self.notificationManger.removeAllScheduledNotifications() == true {
            viewDidLoad()
        }
    }
    
    
    
    
    func setOutletValues() {
        sundayButtonOutlet.tag = 1
        mondayButtonOutlet.tag = 2
        tuesdayButtonOutlet.tag = 3
        wednesdayButtonOutlet.tag = 4
        thursdayButtonOutlet.tag = 5
        fridayButtonOutlet.tag = 6
        saturdayButtonOutlet.tag = 7
        
        dayOfWeekButtonArray = [sundayButtonOutlet, mondayButtonOutlet, tuesdayButtonOutlet, wednesdayButtonOutlet, thursdayButtonOutlet, fridayButtonOutlet, saturdayButtonOutlet]
        
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
        
        amPmDropdown.removeAllItems()
        amPmDropdown.insertItem(withTitle: "AM ", at: 0)
        amPmDropdown.insertItem(withTitle: "AM", at: 1)
        amPmDropdown.insertItem(withTitle: "PM", at: 2)
    }
    
    func getButtonValues() -> [Int] {
        var activeDaysArray : [Int] = []
        
        for day in dayOfWeekButtonArray {
            if day.state == .on {
                activeDaysArray.append(day.tag)
            }
            
        }
        
        return activeDaysArray
    }
    
    
    func getCurrentNotification() {
        var notificationDetails = storageManager.getReminderNotificationFromUserDefaults()
        var minuteString : String = ""
 
        for dayOfWeekButton in dayOfWeekButtonArray {
            dayOfWeekButton.state = .off
        }
        
        isNotificationSet = false
        if notificationDetails != nil {
           if notificationDetails?.isSet == true && notificationDetails != nil {
                isNotificationSet = true
                if notificationDetails!.hour > 12 {
                   notificationDetails!.hour = notificationDetails!.hour - 12
                } else if notificationDetails!.hour == 0 {
                   notificationDetails!.hour = 12
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

                
                if notificationDetails?.daysSetArray != nil || notificationDetails?.daysSetArray.count == 0 {
                    for day in notificationDetails!.daysSetArray {
                        let button = self.view.viewWithTag(day) as? NSButton
                        button!.state = .on
                    }
                }
            }
        }
    }

}
