//
//  mothlyAdd_2ViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit

class mothlyAdd_2ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var selectImage: UIImageView!
    
    var selectCategory : String = ""
//    var eggId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    }
    
    @IBAction func imagePicker(_ sender: Any) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            // 이미지를 가져올 소스 선택 (갤러리 또는 카메라)
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "카메라", style: .default) { _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            let galleryAction = UIAlertAction(title: "갤러리", style: .default) { _ in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(galleryAction)
            actionSheet.addAction(cancelAction)
            
            // 갤러리 또는 카메라 선택 액션시트 표시
            present(actionSheet, animated: true, completion: nil)
        }
        
        
        @IBAction func backBut(_ sender: Any) {
            let backAlert = UIAlertController(title:"알림",message: "이전으로 돌아가면 지금까지 작성한 글이 모두 사라져요 !",preferredStyle: UIAlertController.Style.alert)
            let bCancle = UIAlertAction(title: "계속 작성", style: .default, handler: nil)
            
            let bOk = UIAlertAction(title: "뒤로가기", style: .default, handler: {
                action in self.dismiss(animated: true); })
            
            backAlert.addAction(bOk)
            backAlert.addAction(bCancle)
            present(backAlert,animated: true,completion: nil)
        }
        
        @IBAction func saveBut(_ sender: Any) {
            
            let mothlyList = self.storyboard?.instantiateViewController(withIdentifier: "diaryList")
            mothlyList?.modalPresentationStyle = .fullScreen

            let newDiary = diary(description: textView.text, category: selectCategory, photoURL: "")
            
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
                    
                    if let selectImage = self.selectImage.image,
                       let imagePath = self.saveImageToDocumentsDirectory(selectImage) {
                        // FileManager를 사용하여 이미지 저장 후, 이미지의 경로를 얻음
                        newDiary.photoURL = imagePath.absoluteString // 이미지 경로를 diary의 photoURL에 할당
                    }
                    newDiary.save() // 내용 저장
                    self.present(mothlyList!, animated: true, completion: nil)
                })
                
                alert.addAction(ok)
                alert.addAction(cancle)
                //확인 버튼 경고창에 추가하기
                present(alert,animated: true,completion: nil)
            }
        }
        
        //이미지를 FileManager를 사용하여 저장하는 함수
        func saveImageToDocumentsDirectory(_ image: UIImage) -> URL? {
            // 파일 시스템에서 Documents 디렉토리 경로 가져오기
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Documents 디렉토리를 찾을 수 없습니다.")
                return nil
            }
            
            // 파일명 생성 (랜덤 UUID를 사용하거나, 다른 방식으로 파일명을 지정할 수 있습니다)
            let imageName = "\(UUID().uuidString).jpg"
            
            // 이미지를 저장할 파일 경로 생성
            let imagePath = documentsDirectory.appendingPathComponent(imageName)
            
            // 이미지 데이터를 파일로 저장
            do {
                if let imageData = image.jpegData(compressionQuality: 1) {
                    try imageData.write(to: imagePath)
                    print("이미지 저장 성공: \(imagePath)")
                    return imagePath
                } else {
                    print("이미지 데이터를 얻을 수 없습니다.")
                    return nil
                }
            } catch {
                print("이미지 저장 실패: \(error)")
                return nil
            }
        }
    }


    // 사진 불러오기
    extension mothlyAdd_2ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // 이미지 선택 또는 촬영이 완료되면 호출되는 메서드
            
            if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                selectImage.image = img // 선택한 이미지를 뷰에 표시
                
                // 이미지 선택 또는 촬영 후 갤러리 또는 카메라 화면 닫기
                picker.dismiss(animated: true, completion: nil)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // 이미지 선택 또는 촬영 취소 시 호출되는 메서드
            
            // 이미지 선택 또는 촬영을 취소하면 갤러리 또는 카메라 화면 닫기
            picker.dismiss(animated: true, completion: nil)
        }
    }
