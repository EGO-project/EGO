//
//  mothlyListViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit
import Firebase
import KakaoSDKUser

class mothlyListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var diaryListView: UITableView!
    
    var diaryList: [diary] = []
      
      override func viewDidLoad() {
          super.viewDidLoad()
          fetchData()
          
          diaryListView.dataSource = self
          diaryListView.delegate = self

      }
    // 파이어베이스에 저장된 diary정보 가져오기
    func fetchData() {
        UserApi.shared.me { user, error in
            guard let id = user?.id else {
                print("사용자 ID를 가져올 수 없습니다.")
                return
            }
            
            let databaseRef = Database.database().reference()
            let calenderRef = databaseRef.child("calender").child(String(id))
          
            calenderRef.observeSingleEvent(of: .value) { snapshot  in
                self.diaryList.removeAll() // 배열 초기화
              
                if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for childSnapshot in dataSnapshot {
                        let diary = diary(snapshot: childSnapshot)
                        self.diaryList.append(diary)
                    }
                } else {
                    print("데이터(diary) 스냅샷을 가져올 수 없습니다.")
                }
              
                self.diaryListView.reloadData()
            }
        }
    }
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return diaryList.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "diaryCell", for: indexPath) as! diaryListTableViewCell
          
          let diary = diaryList[indexPath.row]
          
          cell.contentLabel?.text = diary.description
          
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy.MM.dd"
          let dateString = dateFormatter.string(from: diary.date)
          cell.dateLabel?.text = dateString
          
          if let imgUrl = URL(string: diary.photoURL) {
              // 이미지 URL을 이용하여 이미지 데이터를 불러옴
              if let imageData = try? Data(contentsOf: imgUrl) {
                  // 이미지 데이터를 UIImage로 변환
                  if let image = UIImage(data: imageData) {
                      // 이미지를 cell의 photoImg에 할당
                      cell.photoImg.image = image
                  } else {
                      // UIImage로 변환할 수 없는 경우, 혹은 이미지가 nil인 경우
                      print("Failed to convert data to UIImage")
                  }
              } else {
                  // 이미지 데이터를 불러오지 못한 경우
                  print("Failed to load image data from URL")
              }
          } else {
              // 유효하지 않은 이미지 URL인 경우
              print("Invalid URL: \(diary.photoURL)")
          }
          
          return cell
      }
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          performSegue(withIdentifier: "detail", sender: nil)
          
      }
      
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "detail" { // segue 식별자에 따라 분기 처리
              if let indexPath = diaryListView.indexPathForSelectedRow {
                  let selectedDiary = diaryList[indexPath.row] // 선택한 셀의 데이터
                  if let detailVC = segue.destination as? detailViewController {
                      detailVC.selectDiary = selectedDiary // 데이터 전달
                  } else {
                      print("데이터 전달 실패")
                  }
              }
          }
      }
  }
