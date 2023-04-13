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
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //카카오로그인
        KakaoSDK.initSDK(appKey: "bbfabe81f9909eed954b792cadb0db1d")
        
        //파이어베이스 연결
        FirebaseApp.configure()
        
        // Override point for customization after application launch.
        if #available(iOS 11.0, *) {
            // 경고창 배지 사운드를 사용하는 알림 환경 정보를 생성하고, 사용자 동의여부 창을 실행
            let notiCenter =  UNUserNotificationCenter.current()
            notiCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (didAllow, e) in }
            notiCenter.delegate = self // 이 코드는 사용자가 알림을 클릭하여 들어온 이벤트를 전달받기 위한 델리게이트 패턴구조
            // 즉, 알림 센터와 관련하여 뭔가 사건이 발생하면 나(앱 델리게이트) 한테 알려줘 이런 의미임
            /* 클로저 매개변수 설명
             사용자가 메시지 창의 알림 동의 여부를 true / false
             오류 발생시 사용하는 오류 발생 타입의 매개변수 e
             */
        } else {
            // 경고창, 배지, 사운드를 사용하는 알림 환경 정보를 생성하고, 이를 애플리케이션에 저장.
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(setting) // 생성된 정보 애플리케이션에 등록
        }
        return true
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

