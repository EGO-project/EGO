//
//  SettingViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/04/02.
//

import UIKit
import UserNotifications // 알람 객체를 사용하기  프레임워크 임포트

class SettingViewController: UIViewController {
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var setAlarmSwitch: UISwitch!
    @IBOutlet weak var lavel: UILabel!
    
    @IBAction func switchChange(_ sender: Any) {
        if alarmSwitch.isOn {
        } else {
        }
    }
    
    @IBAction func reservePushClick(_ sender: UIButton) {
         
                sendNotification(duration: 6) //6초 후 push 실행
        }
         @IBAction func removePushClick(_ sender: UIButton) {
         
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer notification"])
        }
        
        
        func sendNotification(duration: Int) {
            let content = UNMutableNotificationContent()
            content.title = "title"
            content.subtitle = "subtitle"
            content.body = "body"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(duration), repeats: false)
            let request = UNNotificationRequest(identifier: "timer notification", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    extension SettingViewController: UNUserNotificationCenterDelegate {
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.alert, .sound])
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
                UNUserNotificationCenter.current().requestAuthorization(options:  [.alert, .sound], completionHandler: {
                    didAllow, Error in})
        // Do any additional setup after loading the view.
    }
    
}
