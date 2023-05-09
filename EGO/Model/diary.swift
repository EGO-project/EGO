//
//  diary.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/28.
//

import Foundation
import Firebase

class diary {
    var description : String
    var date : Date
    var ref: DatabaseReference?
    //Firebase Realtime Database에서 데이터의 참조를 나타내는 DatabaseReference 객체를 가져온다는 의미, 데이터베이스 내 특정 위치를 가리키는 포인터 역할
    
    init(description: String) {
        self.description = description
        date = Date()
    }
    
    init(snapshot: DataSnapshot) {
           let snapshotValue = snapshot.value as! [String: AnyObject]
           description = snapshotValue["description"] as! String
           date = snapshotValue["date"] as! Date
           ref = snapshot.ref
       } // 데이터베이스에서 가져온 데이터를 사용하여 객체를 초기화하는 역할을 수행
    
    func toAnyObject() -> Any {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date) // Date를 String으로 변환
        
            return [
                "description": description,
                "date": dateString
            ]
        }
    
    func save() {
            let databaseRef = Database.database().reference()
            let calenderRef = databaseRef.child("calender").childByAutoId()
            calenderRef.setValue(toAnyObject())
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
