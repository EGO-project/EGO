import UIKit
import UserNotifications

class SettingViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // 저장된 사용자 모드 가져오기
            if let savedMode = UserDefaults.standard.object(forKey: "UserMode") as? Int {
                let userInterfaceStyle = UIUserInterfaceStyle(rawValue: savedMode) ?? .unspecified
                overrideUserInterfaceStyle = userInterfaceStyle
            }
        }
    
    override func viewDidLoad() {
           super.viewDidLoad()
           UNUserNotificationCenter.current().delegate = self
           UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
           
           // 이전에 저장한 알람 시간이 있다면 설정된 시간으로 DatePicker를 초기화합니다.
           if let alarmTime = UserDefaults.standard.object(forKey: "alarmTime") as? Date {
               datePicker.date = alarmTime
           }
           // 버튼의 타겟 메서드를 설정합니다.
           lightModeButton.addTarget(self, action: #selector(lightModeButtonPressed(_:)), for: .touchUpInside)
           darkModeButton.addTarget(self, action: #selector(darkModeButtonPressed(_:)), for: .touchUpInside)
           
           // 저장된 인터페이스 스타일을 불러와 적용합니다.
           if let interfaceStyle = loadInterfaceStyle() {
               applyInterfaceStyle(interfaceStyle)
           }
       }
    
    @objc func lightMode(_ sender: UIButton) {
            if #available(iOS 13.0, *) {
                // 현재의 사용자 인터페이스 스타일을 확인하고 라이트 모드로 변경합니다.
                if self.traitCollection.userInterfaceStyle != .light {
                    overrideUserInterfaceStyle = .light
                    UserDefaults.standard.set(UIUserInterfaceStyle.light.rawValue, forKey: "UserMode")
                }
            }
        }
        
        @objc func darkMode(_ sender: UIButton) {
            if #available(iOS 13.0, *) {
                // 현재의 사용자 인터페이스 스타일을 확인하고 다크 모드로 변경합니다.
                if self.traitCollection.userInterfaceStyle != .dark {
                    overrideUserInterfaceStyle = .dark
                    UserDefaults.standard.set(UIUserInterfaceStyle.dark.rawValue, forKey: "UserMode")
                }
            }
        }
    
    @IBOutlet weak var darkModeButton: UIButton!
    @IBOutlet weak var lightModeButton: UIButton!
    
    @objc func lightModeButtonPressed(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            guard let window = UIApplication.shared.keyWindow else {
                return
            }
            recursivelySetInterfaceStyle(.light, for: window)
            
            saveInterfaceStyle(.light) // 라이트 모드 설정 저장
        } else {
            // iOS 12 미만의 경우 라이트 모드로 설정합니다.
            UIApplication.shared.statusBarStyle = .default
            saveInterfaceStyle(.light) // 라이트 모드 설정 저장
        }
    }
    
    @objc func darkModeButtonPressed(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            guard let window = UIApplication.shared.keyWindow else {
                return
            }
            recursivelySetInterfaceStyle(.dark, for: window)
            
            saveInterfaceStyle(.dark) // 다크 모드 설정 저장
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
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["EGOAlarmNotification"])
    }
    
    // 앱이 활성화된 상태에서 알림이 도착했을 때 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    // 인터페이스 스타일 저장 및 불러오기
    
    private func saveInterfaceStyle(_ style: UIUserInterfaceStyle) {
        UserDefaults.standard.setValue(style.rawValue, forKey: "interfaceStyle")
    }
    
    private func loadInterfaceStyle() -> UIUserInterfaceStyle? {
        if let rawValue = UserDefaults.standard.value(forKey: "interfaceStyle") as? Int {
            return UIUserInterfaceStyle(rawValue: rawValue)
        }
        return nil
    }
    
    // 뷰 및 하위 뷰들에게 재귀적으로 인터페이스 스타일 적용
    
    private func recursivelySetInterfaceStyle(_ style: UIUserInterfaceStyle, for view: UIView) {
        if let tableView = view as? UITableView {
            tableView.overrideUserInterfaceStyle = style
        } else {
            view.overrideUserInterfaceStyle = style
        }
        
        for subview in view.subviews {
            recursivelySetInterfaceStyle(style, for: subview)
        }
    }
    
    // 저장된 인터페이스 스타일을 불러와 뷰에 적용
    
    private func applyInterfaceStyle(_ style: UIUserInterfaceStyle) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        recursivelySetInterfaceStyle(style, for: window)
    }
}
