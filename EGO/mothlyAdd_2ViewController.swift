//
//  mothlyAdd_2ViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI

class mothlyAdd_2ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var selectImage: UIImageView!
    
    @IBOutlet weak var photoBut: UIButton!
    
    var selectCategory : String = ""
    var saveId: String = ""
    var selectPhoto :  String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barStyle()
        
        // 현재 날짜 가져오기
        let currentDate = Date()
        // 날짜를 원하는 형식으로 포맷
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = dateFormatter.string(from: currentDate)
        // todayLabel에 날짜 표시
        todayLabel.text = formattedDate
        
        categoryImg.image = UIImage(named: "\(selectCategory).png")
        print(selectCategory)
        print(type(of: selectCategory))
        
        self.selectImage.backgroundColor = UIColor(hexCode: "FFC965")
        
        print("viewdidload - \(saveId)")
        print("method called on thread: \(Thread.current)")
    }
    
    func barStyle(){
        if let leftImage = UIImage(named: "뒤로") {
            let buttonImage = leftImage.withRenderingMode(.alwaysOriginal)
            let leftItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(backAction))
            navigationItem.leftBarButtonItem = leftItem
        }
        
        if let rightImage = UIImage(named: "확인") {
            let buttonImage = rightImage.withRenderingMode(.alwaysOriginal)
            let rightItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(saveAction))
            navigationItem.rightBarButtonItem = rightItem
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
    
    
    @objc func backAction(_ sender: Any) {
        let backAlert = UIAlertController(title:"알림",message: "이전으로 돌아가면 지금까지 작성한 글이 모두 사라져요 !",preferredStyle: UIAlertController.Style.alert)
        let bCancle = UIAlertAction(title: "계속 작성", style: .default, handler: nil)
        
        let bOk = UIAlertAction(title: "뒤로가기", style: .default, handler: {
            action in
            self.navigationController?.popViewController(animated: true)
        })
        
        backAlert.addAction(bOk)
        backAlert.addAction(bCancle)
        present(backAlert,animated: true,completion: nil)
    }
    
    @objc func saveAction(_ sender: Any) {
        
        guard let diaryList = self.storyboard?.instantiateViewController(identifier: "diaryList") as? mothlyListViewController else { return }
        
        let newDiary = diary(eggId : saveId, description: textView.text, category: selectCategory, photo: selectPhoto)
        
        if textView.text.count == 0 {
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
            let ok = UIAlertAction(title: "확인", style: .default, handler: { action in
                newDiary.save() // 내용 저장
                
                if var viewControllers = self.navigationController?.viewControllers {
                    viewControllers.removeLast()
                    viewControllers.append(diaryList)
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
                
            })
            
            alert.addAction(ok)
            alert.addAction(cancle)
            //확인 버튼 경고창에 추가하기
            present(alert,animated: true,completion: nil)
        }
    }
}

// 사진 불러오기
extension mothlyAdd_2ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // 이미지 선택 또는 촬영이 완료되면 호출되는 메서드
        
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectImage.image = img // 선택한 이미지를 뷰에 표시
        }
        
        // 이미지 선택 또는 촬영 후 갤러리 또는 카메라 화면 닫기
        picker.dismiss(animated: true, completion: nil)
        photoBut.tintColor = UIColor.clear
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
            self.selectPhoto = asset.localIdentifier
            print(self.selectPhoto)
        }
        
        let itemProvider = results.first?.itemProvider
        
        // UIImage로 추출
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                DispatchQueue.main.async { // Ensure UI updates are done on the main thread
                    guard let image = image as? UIImage else { return }
                    self?.selectImage.image = image // Update the selectImage with the extracted UIImage
                }
            }
            
        }
        
        // 갤러리뷰 닫기
        picker.dismiss(animated: true, completion: nil)
        photoBut.tintColor = UIColor.clear
        
    }
}
