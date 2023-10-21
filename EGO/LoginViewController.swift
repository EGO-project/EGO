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

import AuthenticationServices
import CryptoKit

import Kingfisher

class LoginViewController: UIViewController, ASAuthorizationControllerDelegate {
    
    let LoginManager = FirebaseManager.shared
    
    @IBOutlet weak var btnGoogleLogin: UIButton!
    @IBOutlet weak var btnAppleLogin: ASAuthorizationAppleIDButton!
    @IBOutlet weak var btnKakaoLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnAutoLogin: UIButton!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var lblRegister: UIButton!
    @IBOutlet weak var bgLoginBox: UIView!
    
    private var currentNonce: String?
    
    var isAutoLogin : Bool? = false
    
    let imageView: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        btnKakaoLogin.setTitle("", for: .normal)
        btnGoogleLogin.setTitle("", for: .normal)
        
        
        lblLogin.text = "로그인"
        lblLogin.font = UIFont(name: "Noto Sans Regular", size: 20)
        bgLoginBox.layer.cornerRadius = 10
        
        
        self.view.backgroundColor = UIColor.white
        
        password.isSecureTextEntry = true
        
        btnAppleLogin.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "auto") == true{
            autoLoginCheck(btnAutoLogin)
            autoLogin()
        }
    }
    
    //Auto login
    func autoLogin() {
        if Auth.auth().currentUser != nil {
            // 사용자가 로그인한 상태
            // 2차 비밀번호 확인
            checkForSecondPasswordAndNavigate()
        } else {
            // 사용자가 로그인하지 않은 상태
            if UserDefaults.standard.bool(forKey: "auto") {
                // 자동 로그인 활성화
                if let email = UserDefaults.standard.string(forKey: "id"),
                   let password = UserDefaults.standard.string(forKey: "password") {
                    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                        guard let self = self else { return }
                        if let error {
                            print("자동 로그인 실패: \(error.localizedDescription)")
                        } else {
                            print("자동 로그인 성공")
                            // 2차 비밀번호 확인
                            self.checkForSecondPasswordAndNavigate()
                        }
                    }
                }
            }
        }
    }
    
    func checkForSecondPasswordAndNavigate() {
        if UserDefaults.standard.bool(forKey: "secondPasswordEnabled") {
            // 2차 비밀번호 입력창으로 이동
            // 여기에서는 예시로 함수만 호출하였습니다. 실제로는 2차 비밀번호 입력 화면으로 이동하는 코드를 작성해야 합니다.
            navigateToSecondPasswordInput()
        } else {
            // 메인 화면으로 이동
            moveToMainTabBarController()
        }
    }
    
    func navigateToSecondPasswordInput() {
        let secondPasswordVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondPasswordViewController")
        self.present(secondPasswordVC, animated: true, completion: nil)
        
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
            UserDefaults.standard.set(password.text, forKey: "password")
        } else {
            UserDefaults.standard.set(isAutoLogin, forKey: "auto")
            UserDefaults.standard.removeObject(forKey: "id")
            UserDefaults.standard.removeObject(forKey: "password")
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
            Auth.auth().signIn(with: credential) { [self] result, error in
                guard let uid = result?.user.uid else { return }
                
                self?.LoginManager.saveUserDataToFirebase(id: uid, email: email, nickname: nickname)
                
                self?.imageView.kf.setImage(with: user.profile?.imageURL(withDimension: 100))
                
                if let image = self?.imageView.image {
                    self?.LoginManager.saveProfileImageToFirebase(id: uid, image: image){ error in
                        if let error {
                            print("Error saving profile image: \(error.localizedDescription)")
                        }
                    }
                }
                
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
                self.authenticateFirebase(withEmail: email, password: password, nickname: nickname)
                
                
                
                if let profileImageUrl = user?.kakaoAccount?.profile?.thumbnailImageUrl {
                    self.imageView.kf.setImage(with: profileImageUrl)
                    if let image = self.imageView.image {
                        guard let id = Auth.auth().currentUser?.uid else {return}
                        self.LoginManager.saveProfileImageToFirebase(id: id, image: image){ error in
                            if let error {
                                print("Error saving profile image: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                
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
    
    @IBAction func emailLogin(_ sender: UIButton) {
        guard let email = email.text, let password = password.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error {
                print("FB : login failed")
                print(error.localizedDescription)
                return
            }
            
            print("FB : login success")
            self.moveToMainTabBarController()
        }
        
    }
    
    func authenticateFirebase(withEmail email: String, password: String, nickname: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // 로그인에 실패한 경우
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        if let errorCode: Int? = (error as NSError).code, errorCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                            print("FB: signup failed - Email already in use")
                        } else {
                            print("FB: signup failed")
                            print(error)
                        }
                    } else {
                        print("FB: signup success")
                        if let user = authResult?.user {
                            FirebaseManager.shared.saveUserDataToFirebase(id: user.uid, email: email, nickname: nickname ?? "")
                            self.moveToMainTabBarController()
                        }
                    }
                }
            } else {
                print("FB: login success")
                self.moveToMainTabBarController()
            }
        }
    }
    
    
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // Generate nonce for validation after sign in
        currentNonce = randomNonceString()
        request.nonce = sha256(currentNonce!)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("잘못된 상태: 로그인 콜백이 수신되었지만 로그인 요청이 전송되지 않았습니다.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("identity 토큰을 가져올 수 없음")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("데이터에서 토큰 문자열을 직렬화할 수 없음: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (authResult?.user) != nil {
                    // 로그인이 성공했으므로 다음 화면으로 이동.
                    self.moveToMainTabBarController()
                }
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("애플 로그인에 에러 발생: \(error)")
    }
    
    //회원가입 화면으로 이동
    @IBAction func register(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "Register")
        self.present(registerVC, animated: true, completion: nil)
    }
    
    //메인 화면으로 이동
    func moveToMainTabBarController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        mainTabBarVC.modalPresentationStyle = .fullScreen
        self.present(mainTabBarVC, animated: false, completion: nil)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
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


