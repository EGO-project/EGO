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
    
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var bgLoginBox: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnKakaoLogin.setTitle("", for: .normal)
        btnAppleLogin.setTitle("", for: .normal)
        btnGoogleLogin.setTitle("", for: .normal)
        
        lblLogin.text = "로그인"
        lblLogin.font = UIFont(name: "Noto Sans Regular", size: 20)
        bgLoginBox.layer.cornerRadius = 10
        
        self.view.backgroundColor = UIColor.white
        
        // Do any additional setup after loading the view.
    }
    
    //auto login
//    override func viewDidAppear(_ animated: Bool) {
//        if Auth.auth().currentUser?.uid != nil {
//            print("auto login success")
//            let VC = self.storyboard?.instantiateViewController(identifier: "MainVC") as! MainViewController
//            VC.modalPresentationStyle = .fullScreen
//            self.present(VC, animated: true,completion: nil)
//        } else {
//            print("auto login failed")
//        }
//    }
    
    //Google login
    @IBAction func googleSignIn(sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { _, error in
                if let error = error {
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
                        let VC = self.storyboard?.instantiateViewController(identifier: "MainTabBar")
                        VC?.modalPresentationStyle = .fullScreen
                        self.present(VC!, animated: true, completion: nil)
                    }
                } else {
                    print("google login")
                    let VC = self.storyboard?.instantiateViewController(identifier: "MainTabBar")
                    VC?.modalPresentationStyle = .fullScreen
                    self.present(VC!, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Kakao login
    @IBAction func kakaoLogin(_ sender: UIButton) {
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { _, error in
                if let error = error {
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
                                let VC = self.storyboard?.instantiateViewController(identifier: "MainVC") as! MainViewController
                                VC.modalPresentationStyle = .fullScreen
                                self.present(VC, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    print("kakao login")
                    let VC = self.storyboard?.instantiateViewController(identifier: "MainTabBar")
                    VC?.modalPresentationStyle = .fullScreen
                    self.present(VC!, animated: true, completion: nil)
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
                        
                        let VC = self.storyboard?.instantiateViewController(identifier: "MainTabBar")
                        VC?.modalPresentationStyle = .fullScreen
                        self.present(VC!, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func moveToMainTabBarController(){

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        mainTabBarVC.modalPresentationStyle = .fullScreen
        self.present(mainTabBarVC, animated: false, completion: nil)
//        self.performSegue(withIdentifier: "MainTabBar", sender: self)
        
        
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


