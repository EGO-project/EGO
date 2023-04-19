//
//  diary.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/28.
//

import Foundation
import Firebase


class diary {
    var content : String
    var date : Date
    
    init(content: String) {
        self.content = content
        date = Date()
    }
    
    static var diaryList = [
        diary(content: "오늘의 일과")
    ]
    
}
