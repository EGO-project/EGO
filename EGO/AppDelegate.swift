//
//  AppDelegate.swift
//  EGO
//
//  Created by 김민석 on 2023/01/25.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import GoogleSignIn
import FirebaseCore
import Firebase
import FirebaseAuth
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var interfaceStyle: UIUserInterfaceStyle = .unspecified
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 앱 시작 시 커스터마이징을 위한 오버라이드 포인트
        
        // 카카오 로그인
        KakaoSDK.initSDK(appKey: "bbfabe81f9909eed954b792cadb0db1d")
        
        // 파이어베이스 설정
        FirebaseApp.configure()
        
        // 이전에 저장된 인터페이스 스타일 값을 가져와서 설정
        if let storedStyle = UserDefaults.standard.string(forKey: "interfaceStyle") {
            setInterfaceStyle(storedStyle)
        }
        
        // 알림 설정
        if #available(iOS 11.0, *) {
            // 경고, 배지, 사운드를 사용하는 알림 환경 정보 생성 및 사용자 동의 여부 확인
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (didAllow, error) in }
            notificationCenter.delegate = self // 알림 이벤트를 수신하기 위한 델리게이트 설정
        } else {
            // 경고, 배지, 사운드를 사용하는 알림 환경 정보 생성 및 애플리케이션에 등록
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        return true
    }
    
    internal func setInterfaceStyle(_ style: String) {
        if #available(iOS 13.0, *) {
            switch style {
            case "light":
                interfaceStyle = .light
            case "dark":
                interfaceStyle = .dark
            default:
                interfaceStyle = .unspecified
            }
            
            if let window = window {
                window.overrideUserInterfaceStyle = interfaceStyle
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //구글로그인
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    //        let handled = Auth.auth().canHandle(url)
    //        if handled {
    //            // URL이 Firebase Authentication으로 전달됩니다.
    //            return true
    //        }
    //        // URL이 Firebase Authentication으로 전달되지 않으면 다른 앱에서 열린 것입니다.
    //        return false
    //    }
    //
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    //        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
    //            if let verificationID = dynamicLink.url?.valueOf("verificationID") {
    //                let credential = EmailAuthProvider.credential(withVerificationID: verificationID, verificationCode: "")
    //                // Firebase 인증 작업 계속 수행
    //                // ...
    //                return true
    //            }
    //        }
    //        return false
    //    }
    
    
    
}



extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        return Dictionary(uniqueKeysWithValues: queryItems.map {
            ($0.name, $0.value ?? "")
        })
        func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            var handled: Bool
            
            handled = GIDSignIn.sharedInstance.handle(url)
            if handled {
                return true
            }
            
            // Handle other custom URL types.
            
            // If not handled by this app, return false.
            return false
        }
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            print(token)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("User did not authorize notifications")
                }
            }
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            // 앱이 foreground 상태일 때 알림이 오면 실행되는 함수
            completionHandler([.alert, .sound, .badge])
        }
    }
}

