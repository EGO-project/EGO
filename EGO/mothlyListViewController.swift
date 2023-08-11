//
//  mothlyListViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit
import Firebase
import KakaoSDKUser
import Photos

class mothlyListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var diaryListView: UITableView!
    
    var diaryList: [diary] = []
    var selectedDate : Date = Date()
    var selectedEggId : String = ""
      
      override func viewDidLoad() {
          super.viewDidLoad()
          
          diaryListView.dataSource = self
          diaryListView.delegate = self
          
      }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        print(selectedEggId)
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
                        if diary.eggId == self.selectedEggId {
                            self.diaryList.append(diary)
                        }
                    }
                } else {
                    print("데이터(diary) 스냅샷을 가져올 수 없습니다.")
                }
              
                self.diaryListView.reloadData()
                
                if let index = self.diaryList.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: self.selectedDate) }) {
                           let indexPath = IndexPath(row: index, section: 0)
                           self.diaryListView.scrollToRow(at: indexPath, at: .top, animated: false)
                       }
                
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
          
          cell.categoryImg.image = UIImage(named: diary.category)

          loadImageWithLocalIdentifier(diary.photo, forCell: cell)
          cell.photoImg.backgroundColor = UIColor(hexCode: "FFC965")
          
          return cell
      }
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          performSegue(withIdentifier: "detail", sender: nil)
          
      }
    
    func loadImageWithLocalIdentifier(_ localIdentifier: String, forCell cell: diaryListTableViewCell) {
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
                        cell.photoImg.image = image
                    }
                }
            }
        }
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
