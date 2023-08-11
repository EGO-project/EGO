//
//  detailViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/28.
//

import UIKit
import Photos

class detailViewController: UIViewController {
    
    @IBOutlet weak var detailDate: UILabel!
    @IBOutlet weak var detailText: UILabel!
    @IBOutlet weak var detailCategory: UIImageView!
    @IBOutlet weak var detailImg: UIImageView!
    
    var selectDiary : diary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectDiary {
            
            detailText.text = selectDiary.description
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: selectDiary.date)
            detailDate.text = dateString
            
            detailCategory.image = UIImage(named: selectDiary.category)
            
            loadPhtoWithLocalIdentifier(selectDiary.photo)
            
        }
        else {print("nil")}
            }
    
    func loadPhtoWithLocalIdentifier(_ localIdentifier: String) {
        // localIdentifier를 사용하여 이미지의 PHAsset을 가져옵니다.
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        
        // 가져온 PHAsset 객체에서 이미지를 로드합니다.
        if let asset = fetchResult.firstObject {
            let options = PHImageRequestOptions()
            options.isSynchronous = true // 동기적으로 이미지 로드
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options) { (image, info) in
                if let image = image {
                    // 이미지가 성공적으로 로드된 경우, image를 사용합니다.
                    DispatchQueue.main.async {
                        // UI 업데이트는 메인 스레드에서 수행되어야 합니다.
                        self.detailImg.image = image
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "change" { // segue 식별자에 따라 분기 처리
                if let changeVC = segue.destination as? changeDiaryViewController {
                    changeVC.changeDiary = selectDiary // 데이터 전달
                } else {
                    print("데이터 전달 실패")
                }
            }
        }
    }
