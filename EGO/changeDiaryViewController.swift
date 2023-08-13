//
//  changeDiaryViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/05/26.
//

import UIKit
import Photos

class changeDiaryViewController: UIViewController {
    
    @IBOutlet weak var changeText: UITextView!
    @IBOutlet weak var cDate: UILabel!
    @IBOutlet weak var changeImg: UIImageView!
    @IBOutlet weak var changeCategory: UIImageView!
    
    var changeDiary : diary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeText.text = changeDiary.description
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: changeDiary.date)
        cDate.text = dateString
        
        changeCategory.image = UIImage(named: changeDiary.category)
        
        loadPhtoWithLocalIdentifier(changeDiary.photo)
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
                        self.changeImg.image = image
                    }
                }
            }
        }
    }
    
    @IBAction func changeOk(_ sender: Any) {
        
        guard let detail = self.storyboard?.instantiateViewController(identifier: "detail") as? detailViewController else { return }
        
        let changeDiary = diary(description: changeText.text ?? "", category: changeDiary.category, photoURL: changeDiary.photo)
        
        if changeText.text.count == 0 {
            let alert = UIAlertController(title:"경고",message: "내용을 입력하세요.",preferredStyle: UIAlertController.Style.alert)
            //확인 버튼 만들기
            let ok = UIAlertAction(title: "확인", style: .destructive, handler: nil)
            //확인 버튼 경고창에 추가하기
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        } else {
            let alert = UIAlertController(title:"알림",message: "내용을 저장하시겠습니까?",preferredStyle: UIAlertController.Style.alert)
            let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
            //확인 버튼 만들기
            let ok = UIAlertAction(title: "확인", style: .default, handler: {
                action in
                self.changeDiary.description = self.changeText.text // 내용 수정
                self.changeDiary.update() // 내용 저장
                detail.selectDiary = changeDiary // 데이터 전달
                self.navigationController?.popViewController(animated: true) // 이전 화면으로 돌아가기
            })
            
            alert.addAction(ok)
            alert.addAction(cancle)
            //확인 버튼 경고창에 추가하기
            present(alert,animated: true,completion: nil)
        }
    }
}
