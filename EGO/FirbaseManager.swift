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
    
    func checkDuplicateID(id: String, completion: @escaping (Bool) -> Void) {
        let databaseRef = Database.database().reference().child("member").child(id)
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            guard !snapshot.exists() else {
                completion(true)
                return
            }
            completion(false)
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
}
