//
//  WithdrawlViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/06/05.
//

import UIKit
import FirebaseAuth

class WithdrawlViewController: UIViewController {
    
    private var isWithdrawalEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func withdrawlButton(_ sender: Any) {
        guard let id = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard isWithdrawalEnabled else {
           // If not enabled, present an alert to inform the user.
           let alert = UIAlertController(title: "Error", message: "회원탈퇴를 하시려면 동의합니다를 체크해주세요.", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           self.present(alert, animated: true, completion: nil)
           return
       }

        FirebaseManager.shared.withdrawl(id: id) { error in
            if error == nil {
                // UIAlertController 객체 생성
                let alert = UIAlertController(title: "Success", message: "회원탈퇴 성공", preferredStyle: .alert)
                // 'OK' 액션 추가
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    // 모든 뷰 컨트롤러 해제
                    self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
                    // 로그인 화면 표시
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "Login") as? UIViewController {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                })
                // 알림창 표시
                self.present(alert, animated: true, completion: nil)
            } else {
                // UIAlertController 객체 생성
                let alert = UIAlertController(title: "Error", message: "회원탈퇴 실패", preferredStyle: .alert)
                // 'OK' 액션 추가
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                // 알림창 표시
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func btnClick(_ sender: UIButton) {
        sender.isSelected.toggle()
        isWithdrawalEnabled = sender.isSelected
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
