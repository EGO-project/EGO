//
//  Friend.swift
//  EGO
//
//  Created by 김민석 on 2023/08/17.
//

import Foundation

struct Friend {
    var id: String?
    var code: String?
    var favoriteState: String?
    var publicState: String?
    var state: String?
    
    init(id: String? = nil, code: String? = nil, favoriteState: String? = nil, publicState: String? = nil, state: String? = nil) {
        self.id = id
        self.code = code
        self.favoriteState = favoriteState
        self.publicState = publicState
        self.state = state
    }
}
