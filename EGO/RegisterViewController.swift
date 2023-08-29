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
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var fieldPasswordCheck: UITextField!
    
    @IBOutlet weak var lblPageName: UILabel!
    @IBOutlet weak var lblEmailError: UILabel!
    @IBOutlet weak var lblNickNameError: UILabel!
    @IBOutlet weak var lblPasswordError: UILabel!
    @IBOutlet weak var lblPasswordCheckError: UILabel!
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnIdCheck: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // Do any additional setup after loading the view.
    }
    
    @IBAction func IDDuplicateCheck(_ sender: Any) {
        guard let email = fieldEmail.text else{
            lblEmailError.text = "*이메일을 입력해주세요"
            lblEmailError.textColor = UIColor.red
            return
        }
        // 파이어베이스 경로 문제로 인해 . 을 -로 치환
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        FirebaseManager.shared.checkDuplicateID(id: safeEmail) { (isDuplicate) in
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
