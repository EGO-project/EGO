//
//  ChangeNicknameViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/05/16.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChangeNicknameViewController: UIViewController {
    
    @IBOutlet weak var nickNameCh: UITextField!
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // clear 버튼 모드를 "편집 중에만"으로 설정합니다.
        nickNameCh.clearButtonMode = .whileEditing
        
        // Firebase Realtime Database의 루트 참조
        databaseRef = Database.database().reference()
        
        // Firebase에서 데이터 가져와 TextField에 설정
        fetchFirebaseData()
    }
    
    // Firebase에서 데이터 가져와 TextField에 설정
    func fetchFirebaseData() {
        // 데이터베이스의 "nickNameRef" 경로에서 데이터 가져오기
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        self.databaseRef.child("member").child(safeEmail).child("nickname").observeSingleEvent(of: .value) { snapshot  in
            if let value = snapshot.value as? String {
                // 가져온 값이 있을 경우 TextField에 설정
                self.nickNameCh.text = value
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let text = nickNameCh.text else { return }
        
        // Firebase Realtime Database의 "nickname" 경로에 값 업데이트
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        let nicknameRef = databaseRef.child("member").child(safeEmail).child("nickname")
        nicknameRef.setValue(text) { error, _ in
            if let error = error {
                print("Failed to update nickname:", error.localizedDescription)
            } else {
                print("Nickname updated successfully")
                // 데이터 전송 후 이전 페이지로 돌아가기
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
            // clear 버튼이 탭되었을 때 추가 작업을 수행합니다.
            // true를 반환하여 기본 clear 동작도 수행하도록 합니다.
            return true
        }
}
