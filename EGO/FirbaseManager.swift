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
    
    
    
    func login(email: String, passwd: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: passwd) { (user, error) in
            if user != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func register(email: String, passwd: String, completion: @escaping (Bool) -> Void) {
        
        
        Auth.auth().createUser(withEmail: email, password: passwd) { (user, error) in
            if user != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func autoLogin(completion: @escaping (Bool) -> Void) {
        if Auth.auth().currentUser != nil {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func getUser(completion: @escaping (User) -> Void) {
        if let user = Auth.auth().currentUser {
            completion(user)
        }
    }
    
    func updateNickName(nickName: String, completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = nickName
            changeRequest.commitChanges { (error) in
                if error != nil {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func updateEmail(email: String, completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            user.updateEmail(to: email) { (error) in
                if error != nil {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func updatePasswd(passwd: String, completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            user.updatePassword(to: passwd) { (error) in
                if error != nil {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
        
    }
    
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
                let friendCode = String(format: "#%05d", ranInt)
                
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
}
