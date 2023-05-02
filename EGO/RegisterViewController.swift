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
    
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldNickName: UITextField!
    @IBOutlet weak var fieldPasswd: UITextField!
    @IBOutlet weak var fieldPasswdCheck: UITextField!
    
    @IBOutlet weak var lblEmailError: UILabel!
    @IBOutlet weak var lblNickNameError: UILabel!
    @IBOutlet weak var lblPasswdError: UILabel!
    @IBOutlet weak var lblPasswdCheckError: UILabel!


    @IBOutlet weak var btnRegister: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnRegister.setTitle("회원가입", for: .normal)
        btnRegister.setTitleColor(UIColor(hexCode: "959595"), for: .normal)
        btnRegister.tintColor = UIColor(hexCode: "FFF3C7")

        lblEmailError.text = ""
        lblNickNameError.text = ""
        lblPasswdError.text = ""
        lblPasswdCheckError.text = ""

        fieldPasswd.isSecureTextEntry = true
        fieldPasswdCheck.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func register(_ sender: Any) {
        
        guard let email = fieldEmail.text else{
            lblEmailError.text = "이메일을 입력해주세요"
            lblEmailError.textColor = UIColor.red
            return
        }
        guard let passwd = fieldPasswd.text else{
            lblPasswdError.text = "비밀번호를 입력해주세요"

            return
        }
        guard let passwdCheck = fieldPasswdCheck.text else{
            lblPasswdCheckError.text = "비밀번호를 입력해주세요"
            return
        }
        if passwd != passwdCheck {
            lblPasswdCheckError.text = "비밀번호가 일치하지 않습니다"
            return
        }
        if isPasswordValid(String(passwd)) == false {
            lblPasswdError.text = "비밀번호는 영문 대소문자, 숫자, 특수문자를 포함한 8자 이상이어야 합니다"
            return
        }
        Auth.auth().createUser(withEmail: email, password: passwd){
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
           }
       }
    }

    //비밀번호 유효성 검사
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
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
