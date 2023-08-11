//
//  AlbumInfo.swift
//  EGO
//
//  Created by 축신효상 on 2023/08/07.
//

import Photos
import UIKit

struct AlbumInfo : Identifiable{
    let id: String?
    let name : String
    let count : Int
    let album : PHFetchResult<PHAsset>
}
