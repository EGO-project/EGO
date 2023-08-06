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
        
//        // 이전에 저장한 인터페이스 스타일 값이 있다면 설정된 스타일로 인터페이스를 업데이트합니다.
//        if let storedStyle = UserDefaults.standard.string(forKey: "interfaceStyle") {
//            updateInterfaceStyle(storedStyle)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let secondPasswordEnabled = UserDefaults.standard.value(forKey: "secondPasswordEnabled") as? Bool {
            setAlarmSwitch.isOn = secondPasswordEnabled
        }
    }

    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // 뷰가 나타날 때마다 인터페이스 스타일을 업데이트합니다.
//        if let storedStyle = UserDefaults.standard.string(forKey: "interfaceStyle") {
//            updateInterfaceStyle(storedStyle)
//        }
//    }
    
    @IBOutlet weak var setAlarmSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func switchChange(_ sender: Any) {
        if setAlarmSwitch.isOn {
            scheduleNotification()
        } else {
            cancelNotification()
        }
    }
    
//    @IBAction func lightModeButtonTapped(_ sender: UIButton) {
//        updateInterfaceStyle("light")
//        UserDefaults.standard.set("light", forKey: "interfaceStyle")
//    }
//    
//    @IBAction func darkModeButtonTapped(_ sender: UIButton) {
//        updateInterfaceStyle("dark")
//        UserDefaults.standard.set("dark", forKey: "interfaceStyle")
//    }
//    
//    public func updateInterfaceStyle(_ style: String) {
//        if #available(iOS 13.0, *) {
//            switch style {
//            case "light":
//                updateInterfaceStyle(.light)
//            case "dark":
//                updateInterfaceStyle(.dark)
//            default:
//                break
//            }
//        }
//    }
//    
//    private func updateInterfaceStyle(_ style: UIUserInterfaceStyle) {
//        if #available(iOS 13.0, *) {
//            UIApplication.shared.windows.forEach { window in
//                window.overrideUserInterfaceStyle = style
//            }
//        }
//    }
    
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
    @IBAction func didChangeSecondPasswordSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "secondPasswordEnabled")
        if sender.isOn {
            let setSecondPasswordVC = SetSecondPasswordViewController()
            setSecondPasswordVC.modalPresentationStyle = .fullScreen
            present(setSecondPasswordVC, animated: true, completion: nil)
        }
    
    }
}

extension SettingViewController: UNUserNotificationCenterDelegate {
    // 알림이 foreground에서 동작할 때 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
