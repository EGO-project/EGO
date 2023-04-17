//
//  LoginViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/02/20.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import GoogleSignIn
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var btnGoogleLogin: UIButton!
    @IBOutlet weak var btnAppleLogin: UIButton!
    @IBOutlet weak var btnKakaoLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnAutoLogin: UIButton!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var passwd: UITextField!
    
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var bgLoginBox: UIView!
    
    var isAutoLogin : Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnKakaoLogin.setTitle("", for: .normal)
        btnAppleLogin.setTitle("", for: .normal)
        btnGoogleLogin.setTitle("", for: .normal)
        btnRegister.setTitle("회원가입", for: .normal)
        btnLogin.setTitle("로그인", for: .normal)
        
        
        lblLogin.text = "로그인"
        lblLogin.font = UIFont(name: "Noto Sans Regular", size: 20)
        bgLoginBox.layer.cornerRadius = 10
        
        self.view.backgroundColor = UIColor.white
        
        passwd.isSecureTextEntry = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "auto") == true{
            autoLoginCheck(btnAutoLogin)
            autoLogin()
        }
    }
    
    //Auto login
    func autoLogin(){
        if Auth.auth().currentUser != nil {
            print("\(Auth.auth().currentUser) != nil")
            // 사용자가 로그인한 상태
            // 메인 화면으로 이동
            self.moveToMainTabBarController()
        } else {
            // 사용자가 로그인하지 않은 상태
            if UserDefaults.standard.bool(forKey: "auto") {
                // 자동 로그인 활성화
                if let email = UserDefaults.standard.string(forKey: "id"),
                   let password = UserDefaults.standard.string(forKey: "passwd") {
                    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                        guard let self else { return }
                        if let error {
                            print("자동 로그인 실패: \(error.localizedDescription)")
                        } else {
                            print("자동 로그인 성공")
                            self.moveToMainTabBarController()
                        }
                    }
                }
            }
        }
    }
    
    //Auto login check
    @IBAction func autoLoginCheck(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            isAutoLogin = true
            print(true)
        } else {
            print(false)
            isAutoLogin = false
        }
        
        if isAutoLogin! {
            // 자동 로그인 선택 시 로그인 하면서 uid, pwd 저장
            UserDefaults.standard.set(isAutoLogin, forKey: "auto")
            UserDefaults.standard.set(email.text, forKey: "id")
            UserDefaults.standard.set(passwd.text, forKey: "passwd")
        } else {
            UserDefaults.standard.set(false, forKey: "auto")
            UserDefaults.standard.removeObject(forKey: "id")
            UserDefaults.standard.removeObject(forKey: "passwd")
        }
    }
    
    //Google login
    @IBAction func googleSignIn(sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { _, error in
                if let error {
                    print("_________login error_________")
                    print(error)
                    // Start the sign in flow!
                    GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
                        guard error == nil else {
                            return
                        }
                        
                        guard let user = result?.user,
                              let idToken = user.idToken?.tokenString
                        else {
                            return
                        }
                        
                        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                        Auth.auth().signIn(with: credential) { result, error in
                            // At this point, our user is signed in
                        }
                        print("google login")
                        self.moveToMainTabBarController()
                    }
                } else {
                    print("google login")
                    self.moveToMainTabBarController()
                }
            }
        }
    }
    
    //Kakao login
    @IBAction func kakaoLogin(_ sender: UIButton) {
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { _, error in
                if let error {
                    print("_________login error_________")
                    print(error)
                    if UserApi.isKakaoTalkLoginAvailable() {
                        UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                            if let error = error {
                                print(error)
                            } else {
                                print("New Kakao Login")
                                
                                //do something
                                _ = oauthToken
                                
                                // 로그인 성공 시
                                UserApi.shared.me { user, error in
                                    if let error {
                                        print("------KAKAO : user loading failed------")
                                        print(error)
                                    } else {
                                        Auth.auth().createUser(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { fuser, error in
                                            if let error = error {
                                                print("FB : signup failed")
                                                print(error)
                                                Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))", completion: nil)
                                            } else {
                                                print("FB : signup success")
                                            }
                                        }
                                    }
                                }
                                self.moveToMainTabBarController()
                            }
                        }
                    }
                } else {
                    print("kakao login")
                    self.moveToMainTabBarController()
                }
            }
        } else {
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        print(error)
                    } else {
                        print("New Kakao Login")
                        
                        //do something
                        _ = oauthToken
                        
                        // 로그인 성공 시
                        UserApi.shared.me { user, error in
                            if let error = error {
                                print("------KAKAO : user loading failed------")
                                print(error)
                            } else {
                                Auth.auth().createUser(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { fuser, error in
                                    if let error = error {
                                        print("FB : signup failed")
                                        print(error)
                                        Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))", completion: nil)
                                    } else {
                                        print("FB : signup success")
                                    }
                                }
                            }
                        }
                        self.moveToMainTabBarController()
                    }
                }
            }
        }
    }
    
    
    @IBAction func register(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        self.present(registerVC, animated: true, completion: nil)
    }
    
    func moveToMainTabBarController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        mainTabBarVC.modalPresentationStyle = .fullScreen
        self.present(mainTabBarVC, animated: false, completion: nil)
    }
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


