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
    var eggState: Bool
    var eggnote: Int  //해당 알의 글 수
    var ref: DatabaseReference?
    
    init(name: String, kind: String, state: String, favoritestate: Bool, eggState: Bool, eggnote: Int) {
        self.name = name
        self.kind = kind
        self.state = state
        self.favoritestate = favoritestate
        self.eggState = eggState
        self.eggnote = eggnote
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as? [String: AnyObject]
        
        if let snapshotValue = snapshotValue {
            eggState = snapshotValue["eggState"] as? Bool ?? false
            name = snapshotValue["name"] as? String ?? ""
            kind = snapshotValue["kind"] as? String ?? ""
            state = snapshotValue["state"] as? String ?? ""
            favoritestate = snapshotValue["favoritestate"] as? Bool ?? false
            eggnote = snapshotValue["eggnote"] as? Int ?? 0
        } else {
            // 데이터베이스에서 올바른 형식의 데이터를 가져오지 못한 경우에 대한 예외 처리
            // 예를 들어, 데이터베이스 구조가 변경되었을 수 있으므로 유효성 검사를 수행하는 것이 좋습니다.
            name = ""
            kind = ""
            state = ""
            favoritestate = false
            eggState = true
            eggnote = 0
        }
        
        ref = snapshot.ref
    }


    
    func toAnyObject() -> Any {
        
        return [
            // "calendarId": calendarId,
            "name": name,
            "kind": kind,
            "state": state,
            "favoritestate": favoritestate,
            "eggState": eggState,
            "eggnote": eggnote
        ]
    }
    
    func save() {
        
        UserApi.shared.me { user, error in
            guard let id = user?.id
            else{ return }
            
            let databaseRef = Database.database().reference()
            let eggRef = databaseRef.child("egg").child(String(id)).child(self.name)
            let eggList = databaseRef.child("egglist").child(String(id)).child(self.name)
            
            eggRef.setValue(self.toAnyObject())
            eggList.setValue(self.name)
        }
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
