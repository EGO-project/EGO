//
//  EggRoomViewController.swift
//  EGO
//
//  Created by bugon cha on 2023/05/27.
//

import UIKit
import FirebaseStorage

// Firebase Storage 참조 생성
let storage = Storage.storage()



class EggRoomPDViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

     var dataSource: [UIImage] = []
    
    var imageName = ""
     @IBOutlet weak var Collection: UICollectionView!

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return dataSource.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EggRoomPDCell", for: indexPath) as! EggRoomPDCollectionViewCell
         let image = dataSource[indexPath.item]
         cell.image.image = image
        // cell.name.text = image.title
         return cell

     }

    
    func downloadImages() {
       
            let storage = Storage.storage()
            let storageRef = storage.reference()
        let imagesRef = storageRef.child("\(self.imageName)") // 이미지 파일이 저장된 경로
            
            imagesRef.listAll { (result, error) in
                if let error = error {
                    print("파일 목록 가져오기 에러: \(error.localizedDescription)")
                } else {
                    let group = DispatchGroup()
                    
                    for item in result!.items {
                        group.enter()
                        
                        let imageRef = item
                        
                        imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                            if let error = error {
                                print("이미지 다운로드 에러: \(error.localizedDescription)")
                            } else if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.dataSource.append(image) // 이미지를 dataSource에 추가
                                    self.Collection.reloadData() // 컬렉션 뷰 다시 로드
                                }
                            }
                            
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        print("이미지 다운로드 완료")
                        print(self.imageName)
                    }
                }
            }
    }





     override func viewDidLoad() {
         super.viewDidLoad()
         Collection.dataSource = self
         Collection.delegate = self

         
         // 이미지 다운로드 함수 호출
         downloadImages()
         // Do any additional setup after loading the view.
     }




 }

    

   
