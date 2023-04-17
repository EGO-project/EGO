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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //카카오로그인
        KakaoSDK.initSDK(appKey: "bbfabe81f9909eed954b792cadb0db1d")
        
        //파이어베이스 연결
        FirebaseApp.configure()
        
        
        
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
    }
}

