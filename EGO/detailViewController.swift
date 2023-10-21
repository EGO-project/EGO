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
        barStyle()
        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .left // 수평 정렬
//        paragraphStyle.lineBreakMode = .byTruncatingTail // 줄바꿈 모드 설정
//
//        let attributedText = NSAttributedString(string: selectDiary.description, attributes: [
//            .paragraphStyle: paragraphStyle,
//            .baselineOffset: NSNumber(value: 0) // 기본 값은 0 (기준선)
//        ])
//
//        detailText.attributedText = attributedText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectDiary {
            
//            detailText.text = selectDiary.description
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left // 수평 정렬
            paragraphStyle.lineBreakMode = .byTruncatingTail // 줄바꿈 모드 설정

            // 수정된 부분: baselineOffset을 음수 값으로 설정하여 텍스트를 위로 올립니다.
            let baselineOffset: CGFloat = -detailText.font.ascender // 기본 값은 0 (기준선)
            let attributedText = NSAttributedString(string: selectDiary.description, attributes: [
                .paragraphStyle: paragraphStyle,
                .baselineOffset: NSNumber(value: Float(baselineOffset))
            ])

            detailText.attributedText = attributedText
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            let dateString = dateFormatter.string(from: selectDiary.date)
            detailDate.text = dateString
            
            detailCategory.image = UIImage(named: selectDiary.category)
            
            loadPhtoWithLocalIdentifier(selectDiary.photoURL)
            
        }
        else {print("nil")}
    }
    
    func barStyle(){
            if let leftImage = UIImage(named: "뒤로") {
                let buttonImage = leftImage.withRenderingMode(.alwaysOriginal)
                let leftItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(leftButAction))
                navigationItem.leftBarButtonItem = leftItem
            }
        }
        
        @objc private func leftButAction(){
            self.navigationController?.popViewController(animated: true)
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
