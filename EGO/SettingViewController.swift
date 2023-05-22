import UIKit
import UserNotifications

class SettingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        
        // 이전에 저장한 알람 시간이 있다면 설정된 시간으로 DatePicker를 초기화합니다.
        if let alarmTime = UserDefaults.standard.object(forKey: "alarmTime") as? Date {
            datePicker.date = alarmTime
        }
    }
    
    @IBOutlet weak var setAlarmSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func switchChange(_ sender: Any) {
        if setAlarmSwitch.isOn {
            scheduleNotification()
        } else {
            cancelNotification()
        }
    }
    
    @IBAction func alarmTime(_ sender: Any) {
        let selectedDate = (sender as! UIDatePicker).date
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "a HH:mm"
        
        let formattedDate = formatter.string(from: selectedDate)
        print("formattedDate --> \(formattedDate)")
        
        // 알람 시간 설정
        UserDefaults.standard.set(selectedDate, forKey: "alarmTime")
        
        // 알림 등록
        scheduleNotification()
    }
    
    func scheduleNotification() {
        // 이전 알람 취소
        cancelNotification()
        
        // 알람 시간 가져오기
        guard let alarmTime = UserDefaults.standard.object(forKey: "alarmTime") as? Date else { return }
        
        // 알림 내용 설정
        let content = UNMutableNotificationContent()
        content.title = "EGO"
        content.subtitle = "알림"
        content.body = "글을 작성할 시간이 되었습니다."
        
        // 알림 트리거 설정
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: alarmTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // 알림 등록
        let request = UNNotificationRequest(identifier: "EGOAlarmNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["EGOAlarmNotification"])
    }
    // 알림 설정 클릭시 설정 권한 페이지로 이동
    @IBAction func alarmSettings(_ sender: UIButton) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // 권한을 얻은 경우 또는 이미 권한이 있는 경우 알림 설정 페이지로 이동
            if granted || error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

extension SettingViewController: UNUserNotificationCenterDelegate {
    // 알림이 foreground에서 동작할 때 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
