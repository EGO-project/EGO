//
//  ChangePasswordViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/08/12.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChangePasswordViewController: UIViewController {
    let ref = Database.database().reference()
    var passwordValue: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPasswordFB()
    }
    
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    // 비밀번호 변경 버튼이 눌렸을 때 호출되는 액션
    @IBAction func changePasswordButtonTapped(_ sender: UIButton) {
        guard let currentPassword = currentPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            return
        }
        
        // 현재 비밀번호 확인
        if currentPassword == passwordValue {
            // 새 비밀번호와 새 비밀번호 확인 일치 여부 확인
            if newPassword == confirmPassword {
                // 비밀번호 변경 로직 처리
                updatePasswordInDatabase(newPassword)
            } else {
                print("새 비밀번호와 새 비밀번호 확인이 일치하지 않습니다.")
            }
        } else {
            print("현재 비밀번호가 일치하지 않습니다.")
        }
    }
    
    func updatePasswordInDatabase(_ newPassword: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            // User is not logged in
            print("User is not logged in.")
            return
        }
        
        // 데이터베이스 업데이트
        self.ref.child("member").child(userId).child("password").setValue(newPassword) { (error, databaseRef) in
            if let error = error {
                print("Error updating password: \(error)")
            } else {
                print("비밀번호가 업데이트되었습니다.")
                // 업데이트가 성공한 경우, 이전 페이지로 돌아가기
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func myPasswordFB() {
        guard let userId = Auth.auth().currentUser?.uid else {
            // User is not logged in
            print("User is not logged in.")
            return
        }
        self.ref.child("member").child(userId).child("password").observeSingleEvent(of: .value) { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            if let value = snapshot.value as? String {
                DispatchQueue.main.async {
                    // Update UI using the fetched value
                    self.passwordValue = value
                }
            } else {
                print("Value is not a string or is nil")
            }
        }
    }
}
