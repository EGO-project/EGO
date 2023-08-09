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

class diary: Equatable{
    //    var eggId : String
    var id: String // 추가
    var description : String
    var date : Date
    var category : String
    var photoURL : String
    var ref: DatabaseReference?
    //Firebase Realtime Database에서 데이터의 참조를 나타내는 DatabaseReference 객체를 가져온다는 의미, 데이터베이스 내 특정 위치를 가리키는 포인터 역할
    
    init(description: String, category: String, photoURL:String) {
        //        self.eggId = eggId
        self.description = description
        date = Date()
        self.category = category
        self.photoURL = photoURL
        
        self.id = UUID().uuidString // id 초기화
        self.ref = nil // ref 초기화
    }
    
    // Equatable 프로토콜을 준수하기 위한 == 연산자 함수 구현
    static func ==(lhs: diary, rhs: diary) -> Bool {
       return lhs.description == rhs.description &&
              lhs.date == rhs.date &&
              lhs.category == rhs.category &&
              lhs.photoURL == rhs.photoURL
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as? [String: AnyObject]
        id = snapshot.key
        ////        eggId = snapshotValue["eggId"] as! String
        //        category = snapshotValue["category"] as! String
        //        description = snapshotValue["description"] as! String
        //        date = snapshotValue["date"] as! Date
        
        if let category = snapshotValue?["category"] as? String {
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
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
        
        if let photoURL = snapshotValue?["photoURL"] as? String {
            self.photoURL = photoURL
        } else {
            self.photoURL = ""
            print("description 값이 없거나 타입이 맞지 않습니다.")
        }
        
        ref = snapshot.ref
        
    }
    
    
    func toAnyObject() -> Any {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date) // Date를 String으로 변환
        
        return [
            //                "eggId": eggId,
            "id": id, // 추가된 부분
            "description": description,
            "date": dateString,
            "category": category,
            "photoURL": photoURL
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
           guard let ref = ref else {
               print("Firebase 디렉터리 참조를 찾을 수 없습니다. 삭제할 수 없음.")
               return
           }
           ref.removeValue { error, _ in
               if let error = error {
                   print("Firebase에서 diary 삭제 실패: \(error.localizedDescription)")
               } else {
                   print("Firebase에서 diary 삭제 성공")
               }
           }
       }
}

