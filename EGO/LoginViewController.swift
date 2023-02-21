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

class LoginViewController: UIViewController {

    @IBOutlet weak var NickNameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    
    @IBOutlet weak var lblSocialLogin: UILabel!
    
    @IBOutlet weak var btnGoogleLogin: UIButton!
    @IBOutlet weak var btnAppleLogin: UIButton!
    @IBOutlet weak var btnKakaoLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnKakaoLogin.setTitle("", for: .normal)
        btnAppleLogin.setTitle("", for: .normal)
        btnGoogleLogin.setTitle("", for: .normal)
        
        lblSocialLogin.text = "소셜로그인"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func googleSignIn(sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
        guard error == nil else { return }
        
            self.setUserInfoGoogle()
        // If sign in succeeded, display the app's main content View.
      }
    }
    
    @IBAction func kakaoLogin(_ sender: UIButton) {
        // 카카오톡 실행 가능 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoAccount() {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    //do something
                    _ = oauthToken
                    self.setUserInfoKakao()
                }
            }
        }
    }
    @IBAction func kakaoLogout(_ sender: UIButton) {
        UserApi.shared.logout{(error) in
                if let error = error {
                    print(error)
                } else {
                    print("kakao logout success")
                    self.NickNameLabel.text = "Nickname :"
                    self.EmailLabel.text = "Email :"
                }
            }
    }
    
    func setUserInfoKakao() {
        UserApi.shared.me {(user, error) in
            if let error = error {
                print(error)
            } else {
                print("nickname: \(user?.kakaoAccount?.profile?.nickname ?? "no nickname")")
                print("email: \(user?.kakaoAccount?.email ?? "no email")")
                
                guard let userId = user?.id else {return}
                
                print("닉네임 : \(user?.kakaoAccount?.profile?.nickname ?? "no nickname").....이메일 : \(user?.kakaoAccount?.email ?? "no nickname"). . . . .유저 ID : \(userId)")
                self.NickNameLabel.text = "Nickname : \(user?.kakaoAccount?.profile?.nickname ?? "no nickname")"
                self.EmailLabel.text = "Email : \(user?.kakaoAccount?.email ?? "no nickname")"
            }
        }
    }
    
    func setUserInfoGoogle(){
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }

            let user = signInResult.user

            let emailAddress = user.profile?.email

            let fullName = user.profile?.name
            let givenName = user.profile?.givenName
            let familyName = user.profile?.familyName

            let profilePicUrl = user.profile?.imageURL(withDimension: 320)
            
            self.NickNameLabel.text = fullName
            self.EmailLabel.text = emailAddress
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

}
