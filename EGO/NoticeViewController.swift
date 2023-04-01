//
//  NoticeViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/02/19.
//

import UIKit
import Firebase
import FirebaseDatabase

class NoticeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    // Firebase Realtime Database 참조 가져오기
    let ref = Database.database().reference()
    
    var dataArray = [Any]()
    
    func fetchData() {
        ref.child("announcement").observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [Any] {
                // 키 밑의 값을 가져와 배열에 추가
                for data in value {
                    if let data = data as? String {
                        self.dataArray.append(data)
                    }
                }
                
                // 가져온 값 출력
//                print(dataArray)
                
                // 테이블 뷰 업데이트
                DispatchQueue.main.async {
                    self.anTable.reloadData()
                }
            }
        }) { error in
            print(error.localizedDescription)
        }
    }

    // 테이블 뷰 업데이트
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "\(dataArray[indexPath.row])"
        
        // 셀 선택시 색변경 없앰
        cell.selectionStyle = .none
        
        return cell
    }

    
    
    // 테이블 뷰에 대한 아울렛 변수 anTable 선언
    @IBOutlet weak var anTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fetchData() 함수 호출
        fetchData()
        anTable.dataSource = self
        anTable.delegate = self
    }
    
}

// 관리 앱에서 작성한 공지를 데이터 베이스에서 받아오기
