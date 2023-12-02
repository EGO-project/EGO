//
//  FirbaseManager.swift
//  EGO
//
//  Created by 김민석 on 2023/05/14.
//

import Foundation
import Firebase
import FirebaseAuth

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
    func saveUserDataToFirebase(id: String, email: String, nickname: String, password: String? = nil) {
        let databaseRef = Database.database().reference().child("member").child(id)
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            guard !snapshot.exists() else {
                print("이미 존재하는 아이디입니다.")
                return
            }
            
            let password = password ?? String(id)
            
            func generateUniqueFriendCode() {
                let ranInt = Int.random(in: 00000...99999)
                let friendCode = String(format: "@%05d", ranInt)
                
                let query = Database.database().reference().child("member").queryOrdered(byChild: "nickname").queryEqual(toValue: nickname)
                query.observeSingleEvent(of: .value) { snapshot in
                    var isFriendCodeUnique = true
                    
                    for childSnapshot in snapshot.children {
                        if let child = childSnapshot as? DataSnapshot,
                           let childValue = child.value as? [String: Any],
                           let childFriendCode = childValue["friendCode"] as? String {
                            if childFriendCode == friendCode {
                                isFriendCodeUnique = false
                                break
                            }
                        }
                    }
                    
                    if isFriendCodeUnique {
                        let values = ["email": email, "nickname": nickname, "friendCode": friendCode, "password": password]
                        databaseRef.updateChildValues(values) { error, _ in
                            guard error == nil else { return }
                            print("DB : signup success")
                        }
                    } else {
                        generateUniqueFriendCode()
                    }
                }
            }
            
            generateUniqueFriendCode()
        }
    }
    
    func checkDuplicateID(email: String, completion: @escaping (Bool) -> Void) {
        let databaseRef = Database.database().reference().child("member")
        
        // 이메일을 쿼리하기 위한 참조 설정
        let query = databaseRef.queryOrdered(byChild: "email").queryEqual(toValue: email)
        
        query.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // 스냅샷이 존재하면, 이메일이 데이터베이스에 있음
                completion(true)
            } else {
                // 스냅샷이 존재하지 않으면, 이메일이 데이터베이스에 없음
                completion(false)
            }
        }
    }

    
    //회원탈퇴
    func withdrawl(id: String, completion: @escaping (Error?) -> Void) {
        let databaseRef = Database.database().reference().child("member").child(id)
        
        databaseRef.removeValue { (error, _) in //실시간 데이터베이스에서 삭제
            if let error = error {
                completion(error)
            } else {
                Auth.auth().currentUser?.delete { error in //인증에서 삭제
                    completion(error)
                }
            }
        }
    }
    
    func saveProfileImageToFirebase(id: String, image: UIImage, completion: @escaping (Error?) -> Void) {
        let databaseRef = Database.database().reference().child("member").child(id).child("profileImage")
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image conversion to Data failed."]))
            return
        }
        
        let base64String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        databaseRef.setValue(base64String) { error, _ in
            completion(error)
        }
    }
    
    func fetchProfileImageFromFirebase(id: String, completion: @escaping (UIImage?) -> Void) {
        let databaseRef = Database.database().reference().child("member").child(id).child("profileImage")
        
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            if let base64String = snapshot.value as? String {
                if let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
                    let retrievedImage = UIImage(data: imageData)
                    completion(retrievedImage)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }


}
