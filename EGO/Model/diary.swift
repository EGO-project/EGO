//
//  diary.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/28.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

class diary {
    var description : String
    var date : Date
    var category : String
    
    var ref: DatabaseReference?
    //Firebase Realtime Database에서 데이터의 참조를 나타내는 DatabaseReference 객체를 가져온다는 의미, 데이터베이스 내 특정 위치를 가리키는 포인터 역할
    
    init(description: String, category:String) {
        self.description = description
        date = Date()
        self.category = category
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as? [String: AnyObject]
        
        if let category = snapshotValue?["categoty"] as? String {
            self.category = category
        } else {
            self.category = ""
            print("category 값이 없거나 타입이 맞지 않습니다.")
        }

        if let description = snapshotValue?["description"] as? String {
            self.description = description
        } else {
            self.description = ""
            print("description 값이 없거나 타입이 맞지 않습니다.")
        }

        if let dateString = snapshotValue?["date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                self.date = date
            } else {
                // 날짜 변환 실패
                self.date = Date()
            }
        } else {
            // "date" 키가 존재하지 않음
            self.date = Date()
            print("date 값이 없거나 타입이 맞지 않습니다.")
        }
//        category = snapshotValue["category"] as! String
//        description = snapshotValue["description"] as! String
//        date = snapshotValue["date"] as! Date
        
        ref = snapshot.ref
    }

    
    func toAnyObject() -> Any {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date) // Date를 String으로 변환
        
            return [
                "description": description,
                "date": dateString,
                "categoty": category
            ]
        }
    
    func save() {
        
        UserApi.shared.me { user, error in
            guard let id = user?.id
            else{ return }
            
            let databaseRef = Database.database().reference()
            let calenderRef = databaseRef.child("calender").child(String(id)).childByAutoId()
            calenderRef.setValue(self.toAnyObject())
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
