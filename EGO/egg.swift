//
//  egg.swift
//  Pods
//
//  Created by 축신효상 on 2023/04/03.
//

import Foundation

class egg {
    var name : String
    var type : String
    var date : Date
    
    init(name: String, type: String) {
        self.name = name
        self.type = type
        date = Date()
    }
    
    static var eggList = [
        egg(name: "알", type: "다람쥐")
    ]
}
