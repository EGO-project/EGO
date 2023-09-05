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
    
    
    @IBOutlet weak var EditButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        diaryListView.dataSource = self
        diaryListView.delegate = self
        
        // 추가: allowsSelectionDuringEditing 속성을 true로 설정
        diaryListView.allowsSelectionDuringEditing = false
        diaryListView.allowsMultipleSelectionDuringEditing = true
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.navigationBar.isTranslucent = true
        
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        
        if let leftImage = UIImage(named: "뒤로") {
            let buttonImage = leftImage.withRenderingMode(.alwaysOriginal)
            let leftItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(leftButAction))
            navigationItem.leftBarButtonItem = leftItem
        }
    }
    
    @objc private func leftButAction(){
        
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "monthly") as? mothlyViewController else { return }
        
        if var viewControllers = self.navigationController?.viewControllers {
            viewControllers.removeLast()
            viewControllers.append(nextVC)
            self.navigationController?.setViewControllers(viewControllers, animated: false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
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
            
            calenderRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot, error: String?)  in
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
                // 클릭 날짜부터 글 띄우기
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
        
        cell.accessoryType = diaryListView.indexPathsForSelectedRows?.contains(indexPath) ?? false ? .checkmark : .none
        if tableView.isEditing {
            cell.accessoryType = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
        
        cell.categoryImg.image = UIImage(named: diary.category)
        
        loadImage(diary.photo, forCell: cell)
        cell.photoImg.backgroundColor = UIColor(hexCode: "FFC965")
        
        return cell
    }
    
    func loadImage(_ localIdentifier: String, forCell cell: diaryListTableViewCell) {
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
    
    
    func showDetailViewController(at indexPath: IndexPath) {
        let selectedDiary = diaryList[indexPath.row] // 선택한 셀의 데이터
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewControllerID") as! detailViewController
        detailVC.selectDiary = selectedDiary // 데이터 전달
        self.navigationController?.pushViewController(detailVC, animated: true)
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            showDetailViewController(at: indexPath)
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
