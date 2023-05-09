//
//  egg.swift
//  Pods
//
//  Created by 축신효상 on 2023/04/03.
//

import Foundation
import Firebase

class egg {
   // var calendarId : String
    var name : String
    var kind : String
    var state : String
    var favoritestate: Bool
    var ref: DatabaseReference?
    
    init(name: String, kind: String, state: String, favoritestate: Bool) {
        //self.calendarId = calendarId
        self.name = name
        self.kind = kind
        self.state = state
        self.favoritestate = favoritestate
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]

        //calendarId = snapshotValue["name"] as! String
        name = snapshotValue["name"] as! String
        kind = snapshotValue["kind"] as! String
        state = snapshotValue["state"] as! String
        favoritestate = snapshotValue["favoritestate"] as! Bool
            
        ref = snapshot.ref
       } // 데이터베이스에서 가져온 데이터를 사용하여 객체를 초기화하는 역할을 수행
    
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
            let databaseRef = Database.database().reference()
            let eggRef = databaseRef.child("egg").childByAutoId()
            eggRef.setValue(toAnyObject())
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
