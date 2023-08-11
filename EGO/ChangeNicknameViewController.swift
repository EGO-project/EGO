//
//  ChangeNicknameViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/05/16.
//

import UIKit
import Firebase
import FirebaseDatabase
import Kingfisher

class ChangeNicknameViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var nickNameCh: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    var databaseRef: DatabaseReference!
    let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // clear 버튼 모드를 "편집 중에만"으로 설정합니다.
        nickNameCh.clearButtonMode = .whileEditing
        
        // Firebase Realtime Database의 루트 참조
        databaseRef = Database.database().reference()
        
        // Firebase에서 데이터 가져와 TextField에 설정
        fetchFirebaseData()
        
        // 프로필 이미지 설정
        guard let id = Auth.auth().currentUser?.uid else { return }
        self.firebaseManager.fetchProfileImageFromFirebase(id: id) { image in
            self.profileImage.image = image
        }
    
    }
    
    // Firebase에서 데이터 가져와 TextField에 설정
    func fetchFirebaseData() {
        // 데이터베이스의 "nickNameRef" 경로에서 데이터 가져오기
        guard let email = Auth.auth().currentUser?.email else { return }
        self.databaseRef.child("member").child(email).child("nickname").observeSingleEvent(of: .value) { snapshot  in
            if let value = snapshot.value as? String {
                // 가져온 값이 있을 경우 TextField에 설정
                self.nickNameCh.text = value
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let text = nickNameCh.text else { return }
        
        // Firebase Realtime Database의 "nickname" 경로에 값 업데이트
        guard let userId = Auth.auth().currentUser?.uid else {
            // User is not logged in
            print("User is not logged in.")
            return
        }
        let nicknameRef = databaseRef.child("member").child(userId).child("nickname")
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
    
    @IBAction func changeProfileImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false){
            let alert = UIAlertController(title: "", message: "이미지 선택이 취소되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: false)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 이미지 피커 컨트롤러 창 닫기
        picker.dismiss(animated: false) { () in
            // 이미지를 이미지 뷰에 표시
            guard let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
            guard let id = Auth.auth().currentUser?.uid else { return }
            self.profileImage.image = img
            self.firebaseManager.saveProfileImageToFirebase(id: id, image: img){ error in
                if error != nil {
                    print("프로필 이미지 저장 실패")
                } else {
                    print("프로필 이미지 저장 성공")
                }
            }
        }
    }
}
