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
    
    @IBOutlet weak var EditButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
        diaryListView.dataSource = self
        diaryListView.delegate = self
        
        // 추가: allowsSelectionDuringEditing 속성을 true로 설정
        diaryListView.allowsSelectionDuringEditing = false
        diaryListView.allowsMultipleSelectionDuringEditing = true
        
        
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        
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
        cell.accessoryType = diaryListView.indexPathsForSelectedRows?.contains(indexPath) ?? false ? .checkmark : .none
        if tableView.isEditing {
            cell.accessoryType = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
        
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
        cell.selectionStyle = .default
        return cell
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
    
    
    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        // 삭제 가능한 항목이 없으면 편집 모드로 변경하지 않음
        guard !self.diaryList.isEmpty else { return }
        
        // Done 버튼을 내비게이션 바에 추가하고, 테이블 뷰를 편집 모드로 변경
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.diaryListView.setEditing(true, animated: true)
        
        // 선택 항목 삭제 버튼(Trash)을 추가하지 않습니다.
        
    }
    
    // Done 버튼을 눌렀을 때 동작 구현
    @objc func doneButtonTap() {
        if let indexPaths = diaryListView.indexPathsForSelectedRows {
            for indexPath in indexPaths.reversed() {
                let diaryToRemove = diaryList[indexPath.row]
                
                // 선택한 셀의 데이터를 Firebase에서 삭제
                UserApi.shared.me { user, error in
                    guard let id = user?.id else {
                        print("사용자 ID를 가져올 수 없습니다.")
                        return
                    }
                    
                    let databaseRef = Database.database().reference()
                    let calenderRef = databaseRef.child("calender").child(String(id))
                    
                    calenderRef.child(diaryToRemove.id).removeValue { (error, _) in
                        if let error = error {
                            print("Firebase에서 삭제 실패: \(error.localizedDescription)")
                        } else {
                            // 셀 삭제 성공시 데이터 소스에서 먼저 삭제
                            self.diaryList.remove(at: indexPath.row)
                            
                            // 선택한 셀을 삭제합니다. (테이블 뷰에서)
                            self.diaryListView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
            self.diaryListView.reloadData()
        }
        
        // 편집 모드 종료
        self.diaryListView.setEditing(false, animated: true)
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = self.EditButton
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "detail", sender: indexPath)
        } else {
            // 선택된 셀의 체크마크 상태를 업데이트합니다.
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = cell?.accessoryType == .checkmark ? .none : .checkmark
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
