//
//  SecondPasswordViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/08/07.
//

import UIKit
import LocalAuthentication

class SecondPasswordViewController: UIViewController {
    
    @IBOutlet weak var firstBlank: UIImageView!
    @IBOutlet weak var secondBlank: UIImageView!
    @IBOutlet weak var thirdBlank: UIImageView!
    @IBOutlet weak var forthBlank: UIImageView!
    @IBOutlet weak var backspaceBtn: UIButton!
    @IBOutlet weak var faceIDBtn: UIButton!
    
    private var passwordInput: String = ""
    private let storedPasswordKey = "SecondPassword"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func numberButtonPressed(_ sender: UIButton) {
        guard passwordInput.count < 4, let number = sender.titleLabel?.text else { return }
        passwordInput.append(number)
        updatePasswordDisplay()
        checkPassword()
    }

    @IBAction func backspacePressed(_ sender: UIButton) {
        passwordInput = String(passwordInput.dropLast())
        updatePasswordDisplay()
    }
    
    private func updatePasswordDisplay() {
        let blankImage = UIImage(named: "Ellipse 8") // 비어있는 상태의 이미지
        let filledImage = UIImage(named: "filled") // *로 채워진 상태의 이미지
        
        let imageViews = [firstBlank, secondBlank, thirdBlank, forthBlank]
        
        for (index, imageView) in imageViews.enumerated() {
            if index < passwordInput.count {
                imageView?.image = filledImage
            } else {
                imageView?.image = blankImage
            }
        }
    }
    
    
    private func checkPassword() {
        if passwordInput.count == 4 {
            if passwordInput == UserDefaults.standard.string(forKey: storedPasswordKey) {
                // 비밀번호 일치
                passwordInput = ""
                // 다음 화면으로 이동 또는 원하는 동작 수행
                //메인 화면으로 이동
                self.moveToMainTabBarController()
            } else {
                // 비밀번호 불일치
                passwordInput = ""
                // 사용자에게 비밀번호 불일치 알림
            }
            updatePasswordDisplay()
        }
    }
    
    @IBAction func switchFaceID(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func useFaceID(_ sender: UIButton) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "FaceID를 사용하여 로그인합니다."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // FaceID 인증 성공
                        // 다음 화면으로 이동 또는 원하는 동작 수행
                        //메인 화면으로 이동
                        self.moveToMainTabBarController()
                    } else {
                        // FaceID 인증 실패
                        // 사용자에게 에러 메시지 표시
                    }
                }
            }
        } else {
            // FaceID 사용 불가능
            // 사용자에게 에러 메시지 표시
        }
    }
    //메인 화면으로 이동
    func moveToMainTabBarController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        mainTabBarVC.modalPresentationStyle = .fullScreen
        self.present(mainTabBarVC, animated: false, completion: nil)
    }
}
