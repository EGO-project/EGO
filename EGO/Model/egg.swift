//
//  egg.swift
//  Pods
//
//  Created by 축신효상 on 2023/04/03.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

class egg {
    
    var name : String
    var kind : String
    var state : String
    var favoritestate: Bool
    var ref: DatabaseReference?
    
    init(name: String, kind: String, state: String, favoritestate: Bool) {
        self.name = name
        self.kind = kind
        self.state = state
        self.favoritestate = favoritestate
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as? [String: AnyObject]
        
        if let snapshotValue = snapshotValue {
            name = snapshotValue["name"] as? String ?? ""
            kind = snapshotValue["kind"] as? String ?? ""
            state = snapshotValue["state"] as? String ?? ""
            favoritestate = snapshotValue["favoritestate"] as? Bool ?? false
        } else {
            // 데이터베이스에서 올바른 형식의 데이터를 가져오지 못한 경우에 대한 예외 처리
            // 예를 들어, 데이터베이스 구조가 변경되었을 수 있으므로 유효성 검사를 수행하는 것이 좋습니다.
            name = ""
            kind = ""
            state = ""
            favoritestate = false
        }
        
        ref = snapshot.ref
    }
    
    
    
    func toAnyObject() -> Any {
        
        return [
            // "calendarId": calendarId,
            "name": name,
            "kind": kind,
            "state": state,
            "favoritestate": favoritestate
        ]
    }
    
    func save() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return print("알 저장 실패")}
        
        let databaseRef = Database.database().reference()
        let eggRef = databaseRef.child("egg").child(uid).child(self.name)
        let eggList = databaseRef.child("egglist").child(uid).child(self.name)
        
        eggRef.setValue(self.toAnyObject())
        eggList.setValue(self.name)
    }
    
    
    func update() {
        guard let ref = ref else { return }
        ref.updateChildValues(toAnyObject() as! [AnyHashable : Any])
    }
    
    func delete() {
        guard let ref = ref else { return }
        ref.removeValue()
    }
}
