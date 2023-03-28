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
    
    // 상수 ref에 파이어베이스 주소를 넣음
    // reference는 데이터베이스의 특정 위치를 나타내고 읽고 쓰게끔 해준다
    let ref = Database.database().reference()
    
    var labelValue: [String] = []
    
    lazy var notice = [labelValue]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = notice[indexPath.row].joined(separator: ",")
        
        // 셀 선택시 색변경 없앰
        cell.selectionStyle = .none
        
        return cell
    }
    
    func updateLabel() {
        ref.child("announcement").observe(.value, with: { snapshot  in
            if let labelValue = snapshot.value as? [String: Any] {
                //self.data = labelValue
                let key1Value = labelValue["1"] as? String
                let key2Value = labelValue["2"] as? String
                
            }
        }) { error in
            print(error.localizedDescription)
        }
    }
                                                     

    
    
    // 테이블 뷰에 대한 아울렛 변수 anTable 선언
    @IBOutlet weak var anTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabel()
        anTable.dataSource = self
        anTable.delegate = self
    }
    
}

// 관리 앱에서 작성한 공지를 데이터 베이스에서 받아오기
