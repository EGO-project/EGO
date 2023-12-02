//
//  RegisterViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/04/13.
//

import UIKit
import Firebase
import FirebaseAuth

import GoogleSignIn

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

import AuthenticationServices
import CryptoKit

class RegisterViewController: UIViewController, ASAuthorizationControllerDelegate {
    
    let LoginManager = FirebaseManager.shared
    
    let imageView: UIImageView = UIImageView()
    
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldNickName: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var fieldPasswordCheck: UITextField!
    
    @IBOutlet weak var lblPageName: UILabel!
    @IBOutlet weak var lblEmailError: UILabel!
    @IBOutlet weak var lblNickNameError: UILabel!
    @IBOutlet weak var lblPasswordError: UILabel!
    @IBOutlet weak var lblPasswordCheckError: UILabel!
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnIdCheck: UIButton!
    @IBOutlet weak var btnAppleLogin: ASAuthorizationAppleIDButton!
    
    private var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        btnRegister.setTitle("회원가입", for: .normal)
        btnRegister.setTitleColor(UIColor(hexCode: "959595"), for: .normal)
        btnRegister.tintColor = UIColor(hexCode: "FFF3C7")
        
        btnIdCheck.tintColor = UIColor(hexCode: "FFC965")
        btnIdCheck.setTitle("중복확인", for: .normal)
        
        lblEmailError.text = ""
        lblEmailError.font = UIFont(name: "Noto Sans Regular", size: 10)
        lblEmailError.textColor = UIColor(hexCode: "6A6A6A")
        
        lblNickNameError.text = ""
        lblPasswordError.text = ""
        lblPasswordCheckError.text = ""
        
        fieldPassword.isSecureTextEntry = true
        fieldPasswordCheck.isSecureTextEntry = true
        
        btnAppleLogin.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
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
    
    @IBAction func IDDuplicateCheck(_ sender: Any) {
        guard let email = fieldEmail.text else{
            lblEmailError.text = "*이메일을 입력해주세요"
            lblEmailError.textColor = UIColor.red
            return
        }
        guard email.contains("@") else {
            lblEmailError.text = "*이메일 형식이 올바르지 않습니다"
            lblEmailError.textColor = UIColor.red
            return
        }

        FirebaseManager.shared.checkDuplicateID(email: email) { (isDuplicate) in
            if isDuplicate {
                self.lblEmailError.text = "*이미 존재하는 아이디입니다"
                self.lblEmailError.textColor = UIColor.red
                return
            }
            else {
                self.lblEmailError.text = "*사용 가능한 아이디입니다"
                self.lblEmailError.textColor = UIColor.green
                return
            }
        }
    }
    
    @IBAction func register(_ sender: Any) {
        
        guard let email = fieldEmail.text else{
            lblEmailError.text = "이메일을 입력해주세요"
            lblEmailError.textColor = UIColor.red
            return
        }
        
        guard let nickname = fieldNickName.text else{
            lblNickNameError.text = "닉네임을 입력해주세요"
            lblNickNameError.textColor = UIColor.red
            return
        }
        
        guard let password = fieldPassword.text else{
            lblPasswordError.text = "비밀번호를 입력해주세요"
            
            return
        }
        guard let passwordCheck = fieldPasswordCheck.text else{
            lblPasswordCheckError.text = "비밀번호를 입력해주세요"
            return
        }
        if password != passwordCheck {
            lblPasswordCheckError.text = "비밀번호가 일치하지 않습니다"
            return
        }
        
        switch String(password){
            case " ": lblPasswordError.text = "공백은 사용할 수 없습니다"
                return
            case ".": lblPasswordError.text = ".은 사용할 수 없습니다"
                return
            case "$": lblPasswordError.text = "$는 사용할 수 없습니다"
                return
            case "[": lblPasswordError.text = "[는 사용할 수 없습니다"
                return
            case "]": lblPasswordError.text = "]는 사용할 수 없습니다"
                return
            case "#": lblPasswordError.text = "#은 사용할 수 없습니다"
                return
            case "/": lblPasswordError.text = "/은 사용할 수 없습니다"
                return
            default:
                if !isPasswordValid(String(password)) {
                    lblPasswordError.text = "영문, 숫자, 특수문자를 포함한 8자 이상입니다."
                    return
                } else{
                    print("비밀번호 유효성 검사 통과")
                }
        }

        
        
        Auth.auth().createUser(withEmail: email, password: password){
            authResult, error in

            guard let user = authResult?.user, error == nil else {
                print("회원가입 실패: \(error!.localizedDescription)")
                return
            }
            
            
            // 인증 토큰 생성
            user.getIDTokenForcingRefresh(true) { token, error in
                guard error == nil else {
                    print("토큰 생성 실패: \(error!.localizedDescription)")
                    return
                }
                
                // 이메일 주소 확인
                user.sendEmailVerification { (error) in
                    if let error = error {
                        print("이메일 인증 전송 실패: \(error.localizedDescription)")
                        return
                    }
                    print("이메일 인증 전송 성공")
                }
                
                // 생성된 토큰 사용
                let tokenString = token!
                print("토큰: \(tokenString)")
                
                FirebaseManager.shared.saveUserDataToFirebase(id: Auth.auth().currentUser!.uid, email: email, nickname: nickname, password: password)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "Login") 
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: false, completion: nil)
            }
        }
    }
    
    //비밀번호 유효성 검사
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*\\d)(?=.*[@!%*?&])[A-Za-z\\d@$!%*?&]{8,}$" // 영문, 숫자, 특수문자 포함 8자리 이상
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    func moveToMainTabBarController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        mainTabBarVC.modalPresentationStyle = .fullScreen
        self.present(mainTabBarVC, animated: false, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK - UIColor Extension
extension UIColor {
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}

extension RegisterViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
