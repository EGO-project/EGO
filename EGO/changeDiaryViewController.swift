//
//  changeDiaryViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/05/26.
//

import UIKit
import Photos
import PhotosUI

class changeDiaryViewController: UIViewController {
    
    @IBOutlet weak var changeText: UITextView!
    @IBOutlet weak var cDate: UILabel!
    @IBOutlet weak var changeImg: UIImageView!
    @IBOutlet weak var changeCategory: UIImageView!
    @IBOutlet weak var photoBut: UIButton!
    
    var changeDiary : diary!
    var changePhoto : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoBut.tintColor = UIColor.clear
        barStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeText.text = changeDiary.description
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: changeDiary.date)
        cDate.text = dateString
        
        changeCategory.image = UIImage(named: changeDiary.category)
        
        photo(changeDiary.photoURL)
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

    
    func photo(_ localIdentifier: String) {
        // localIdentifier를 사용하여 이미지의 PHAsset
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        
        // 가져온 PHAsset 객체에서 이미지를 로드
        if let asset = fetchResult.firstObject {
            let options = PHImageRequestOptions()
            options.isSynchronous = true // 동기적으로 이미지 로드
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options) { (image, info) in
                if let image = image {
                    // 이미지가 성공적으로 로드된 경우, image를 사용
                    DispatchQueue.main.async {
                        self.changeImg.image = image
                    }
                }
            }
        }
    }
    
    @available(iOS 14.0, *)
    @IBAction func imagePicker(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // 이미지를 가져올 소스 선택 (갤러리 또는 카메라)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "카메라", style: .default, handler: { action in
            authDeviceCamera(self) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let galleryAction = UIAlertAction(title: "갤러리", style: .default) { [weak self] action in
            authPhotoLibrary(self!) {
                var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                configuration.filter = .images // 이미지만 선택 가능하도록 설정
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                
                self?.present(picker, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cancelAction)
        
        // 갤러리 또는 카메라 선택 액션시트 표시
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func changeOk(_ sender: Any) {
        
        guard let detail = self.storyboard?.instantiateViewController(identifier: "detail") as? detailViewController else { return }
        
        let changeDiary = diary(eggId: changeDiary.eggId, description: changeText.text ?? "", category: changeDiary.category, photoURL: changeDiary.photoURL)
        
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
                if self.changePhoto != ""{
                    self.changeDiary.photoURL = self.changePhoto
                }
                self.changeDiary.update() // 내용 저장
                self.navigationController?.popViewController(animated: true) // 이전 화면으로 돌아가기
            })
            
            alert.addAction(ok)
            alert.addAction(cancle)
            //확인 버튼 경고창에 추가하기
            present(alert,animated: true,completion: nil)
        }
    }
}

// 사진 불러오기
extension changeDiaryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // 이미지 선택 또는 촬영이 완료되면 호출되는 메서드
        
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            changeImg.image = img // 선택한 이미지를 뷰에 표시
        }
        
        // 이미지 선택 또는 촬영 후 갤러리 또는 카메라 화면 닫기
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 이미지 선택 또는 촬영 취소 시 호출되는 메서드
        
        // 이미지 선택 또는 촬영을 취소하면 갤러리 또는 카메라 화면 닫기
        picker.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 14.0, *)
    // 사진 선택이 끝났을때 들어오는 함수
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        
        // asset - 메타데이터 들어있음
        fetchResult.enumerateObjects { asset, index, pointer in
            print(asset)
            self.changePhoto = asset.localIdentifier
            print(self.changePhoto)
        }
        
        let itemProvider = results.first?.itemProvider
        
        // UIImage로 추출
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                DispatchQueue.main.async { // Ensure UI updates are done on the main thread
                    guard let image = image as? UIImage else { return }
                    self?.changeImg.image = image // Update the selectImage with the extracted UIImage
                }
            }
            
        }
        
        // 갤러리뷰 닫기
        picker.dismiss(animated: true, completion: nil)
        photoBut.tintColor = UIColor.clear
        
    }
}
