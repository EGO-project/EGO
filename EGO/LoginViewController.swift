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
import FirebaseDatabase



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
        // Do any additional setup after loading the view.
        
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
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "auto") == true{
//            autoLoginCheck(btnAutoLogin)
//            autoLogin()
        }
    }
    
    //Auto login
    func autoLogin(){
        if Auth.auth().currentUser != nil {
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
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard error == nil, let user = result?.user, let idToken = user.idToken?.tokenString, let email = user.profile?.email, let nickname = user.profile?.name else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                guard let uid = result?.user.uid else { return }
                
                self?.saveUserDataToFirebase(id: uid, email: email, nickname: nickname)
                self?.moveToMainTabBarController()
            }
        }
    }
    
    //Kakao login
    @IBAction func kakaoLogin(_ sender: UIButton) {
        func handleKakaoLogin(_ oauthToken: OAuthToken?, error: Error?) {
            guard error == nil else {
                print(error!)
                return
            }
            
            UserApi.shared.me { user, error in
                guard error == nil else {
                    print("------KAKAO : user loading failed------")
                    print(error!)
                    return
                }
                
                guard let email = user?.kakaoAccount?.email,
                      let id = user?.id,
                      let nickname = user?.kakaoAccount?.profile?.nickname else {
                    print("------KAKAO : user email or id not found------")
                    return
                }
                
                let password = "\(id)"
                self.authenticateFirebase(withEmail: email, password: password)
                self.saveUserDataToFirebase(id: "\(id)", email: email, nickname: nickname)
                self.moveToMainTabBarController()
            }
        }
        
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { _, error in
                guard error == nil else {
                    print("_________login error_________")
                    print(error!)
                    return
                }
                
                if UserApi.isKakaoTalkLoginAvailable() {
                    UserApi.shared.loginWithKakaoTalk(completion: handleKakaoLogin)
                } else {
                    UserApi.shared.loginWithKakaoAccount(completion: handleKakaoLogin)
                }
            }
        } else {
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: handleKakaoLogin)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: handleKakaoLogin)
            }
        }
    }

    func authenticateFirebase(withEmail email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                print("FB : signup failed")
                print(error)
                Auth.auth().signIn(withEmail: email, password: password, completion: nil)
            } else {
                print("FB : signup success")
            }
        }
    }

    func saveUserDataToFirebase(id: String, email: String, nickname: String) {
        let databaseRef = Database.database().reference().child("member").child(id)
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            guard !snapshot.exists() else {
                print("이미 존재하는 아이디입니다.")
                return
            }
            
            let values = ["email": email, "nickname": nickname]
            databaseRef.updateChildValues(values) { error, _ in
                guard error == nil else { return }
                print("DB : signup success")
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


