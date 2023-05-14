//
//  RegisterViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/04/13.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    weak var lblPageName: UILabel!
    
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldNickName: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var fieldPasswordCheck: UITextField!
    
    @IBOutlet weak var lblEmailError: UILabel!
    @IBOutlet weak var lblNickNameError: UILabel!
    @IBOutlet weak var lblPasswordError: UILabel!
    @IBOutlet weak var lblPasswordCheckError: UILabel!


    @IBOutlet weak var btnRegister: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnRegister.setTitle("회원가입", for: .normal)
        btnRegister.setTitleColor(UIColor(hexCode: "959595"), for: .normal)
        btnRegister.tintColor = UIColor(hexCode: "FFF3C7")

        lblEmailError.text = ""
        lblNickNameError.text = ""
        lblPasswordError.text = ""
        lblPasswordCheckError.text = ""

        fieldPassword.isSecureTextEntry = true
        fieldPasswordCheck.isSecureTextEntry = true
        // Do any additional setup after loading the view.
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
        if isPasswordValid(String(password)) == false {
            print(password)
            print(passwordCheck)
            lblPasswordError.text = "비밀번호는 영문 대소문자, 숫자, 특수문자를 포함한 8자 이상이어야 합니다"
            return
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
               
               // 파이어베이스 경로 문제로 인해 . 을 -로 치환
               let safeEmail = email.replacingOccurrences(of: ".", with: "-")
               FirebaseManager.shared.saveUserDataToFirebase(id: safeEmail, email: safeEmail, nickname: nickname, password: password)
           }
       }
    }

    //비밀번호 유효성 검사
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*\\d)(?=.*[@!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
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
