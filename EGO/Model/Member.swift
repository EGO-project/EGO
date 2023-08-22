//
//  Member.swift
//  EGO
//
//  Created by 김민석 on 2023/08/17.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct Member {
    var id: String?
    var email: String?
    var password: String?
    var friendCode: String?
    var nickname: String?
    var friend: [Friend?]
    var egg: [egg?]
    
    init(id: String? = nil, email: String? = nil, passwd: String? = nil, friendCode: String? = nil, nickname: String? = nil, friend: [Friend?], egg: [egg?]) {
        self.id = id
        self.email = email
        self.password = passwd
        self.friendCode = friendCode
        self.nickname = nickname
        self.friend = friend
        self.egg = egg
    }
    
    init(snapshot: DataSnapshot){
        let snapshotValue = snapshot.value as? [String: AnyObject]
        
        if let snapshotValue = snapshotValue {
            id = snapshotValue["id"] as? String ?? ""
            email = snapshotValue["email"] as? String ?? ""
            password = snapshotValue["password"] as? String ?? ""
            friendCode = snapshotValue["friendCode"] as? String ?? ""
            nickname = snapshotValue["nickname"] as? String ?? ""
            friend = snapshotValue["friend"] as? [Friend?] ?? []
            egg = snapshotValue["egg"] as? [egg?] ?? []
        } else {
            id = ""
            email = ""
            password = ""
            friendCode = ""
            nickname = ""
            friend = []
            egg = []
        }
    }
    
}
