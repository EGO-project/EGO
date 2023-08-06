//
//  ProfileViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/02/19.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    // 이전 MoreViewController에서 text 값을 받아오기 위한 변수
    @IBOutlet weak var profile: UIImageView!
    var pNameLbl: String?
    var pCodeLbl: String?
    let ref = Database.database().reference()
    let firebaseManager = FirebaseManager.shared
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myNameFB()
        myCodeFB()
        
        // 파이어베이스 데이터 변경 감지
        observeFirebaseChanges()
        
        guard let id = Auth.auth().currentUser?.uid else { return }
        self.firebaseManager.fetchProfileImageFromFirebase(id: id) { image in
            self.profile.image = image
        }
    }
    
    func observeFirebaseChanges() {
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        
        // "member" 경로의 변경 사항을 감시하고 실시간으로 업데이트된 데이터를 받아옴
        self.ref.child("member").child(safeEmail).observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let value = snapshot.value as? [String: Any] {
                // nickname 값이 변경되었을 경우 Label에 업데이트
                if let nickname = value["nickname"] as? String {
                    DispatchQueue.main.async {
                        self.nameLbl.text = nickname
                    }
                }
                
                // friendCode 값이 변경되었을 경우 Label에 업데이트
                if let friendCode = value["friendCode"] as? String {
                    DispatchQueue.main.async {
                        self.codeLbl.text = friendCode
                    }
                }
            }
        }
    }
    
    // 기존 코드와 동일하게 구현
    func myNameFB() {
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        self.ref.child("member").child(safeEmail).child("nickname").observeSingleEvent(of: .value) { [weak self] snapshot  in
            guard let self = self else { return }
            
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.nameLbl.text = value
            }
        }
    }
    
    // 기존 코드와 동일하게 구현
    func myCodeFB() {
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        self.ref.child("member").child(safeEmail).child("friendCode").observeSingleEvent(of: .value) { [weak self] snapshot  in
            guard let self = self else { return }
            
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.codeLbl.text = value
            }
        }
    }
}



