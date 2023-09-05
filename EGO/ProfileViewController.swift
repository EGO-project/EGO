//
//  ProfileViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/02/19.
//

import UIKit
import Firebase
import KakaoSDKUser

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // 이전 MoreViewController에서 text 값을 받아오기 위한 변수
    @IBOutlet weak var profile: UIImageView!
    var pNameLbl: String?
    var pCodeLbl: String?
    let ref = Database.database().reference()
    let firebaseManager = FirebaseManager.shared
    
    var eggnames : [String] = []
    var eggstates : [Bool] = []
    
    @IBOutlet weak var CategoryOption: UITableView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
        myNameFB()
        myCodeFB()
        
        CategoryOption.delegate = self
        CategoryOption.dataSource = self
        // 파이어베이스 데이터 변경 감지
        observeFirebaseChanges()
        
        guard let id = Auth.auth().currentUser?.uid else { return }
        self.firebaseManager.fetchProfileImageFromFirebase(id: id) { image in
            self.profile.image = image
        }
    }
    
    func observeFirebaseChanges() {
        guard let userId = Auth.auth().currentUser?.uid else {
            // User is not logged in
            print("User is not logged in.")
            return
        }
        
        // "member" 경로의 변경 사항을 감시하고 실시간으로 업데이트된 데이터를 받아옴
        self.ref.child("member").child(userId).observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let value = snapshot.value as? [String: Any] {
                // nickname 값이 변경되었을 경우 Label에 업데이트
                if let nickname = value["nickname"] as? String {
                    DispatchQueue.main.async {
                        self.nameLbl.text = nickname
                    }
                }
                
                // friendCode 값이 변경되었을 경우 Label에 업데이트
                if let friendCode = value["friendCode"] as? String {
                    DispatchQueue.main.async {
                        self.codeLbl.text = friendCode
                    }
                }
            }
        }
    }
    
    // 기존 코드와 동일하게 구현
    func myNameFB() {
        guard let userId = Auth.auth().currentUser?.uid else {
            // User is not logged in
            print("User is not logged in.")
            return
        }
        self.ref.child("member").child(userId).child("nickname").observeSingleEvent(of: .value) { [weak self] snapshot  in
            guard let self = self else { return }
            
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.nameLbl.text = value
            }
        }
    }
    
    // 기존 코드와 동일하게 구현
    func myCodeFB() {
        guard let userId = Auth.auth().currentUser?.uid else {
            // User is not logged in
            print("User is not logged in.")
            return
        }
        self.ref.child("member").child(userId).child("friendCode").observeSingleEvent(of: .value) { [weak self] snapshot  in
            guard let self = self else { return }
            
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.codeLbl.text = value
            }
        }
    }
    
    // 파이어베이스에 저장된 egg정보 가져오기
    func fetchData() {
        UserApi.shared.me { user, error in
            guard let id = user?.id else {
                print("사용자 ID를 가져올 수 없습니다.")
                return
            }
            
            let databaseRef = Database.database().reference()
            let eggRef = databaseRef.child("egg").child(String(id))
            
            eggRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot, error: String?)  in
                self.eggnames.removeAll()
                self.eggstates.removeAll()
                
                if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for childSnapshot in dataSnapshot {
                        let egg = egg(snapshot: childSnapshot)
                        
                        if let name : String? = egg.name{
                            self.eggnames.append(name!)
                        } else {
                            print("알 이름을 찾을 수 없습니다.")
                        }
                        
                        if let eggState : Bool? = egg.eggState{
                            self.eggstates.append(eggState!)
                        } else {
                            print("알 공개 여부를 알 수 없습니다.")
                        }
                    }
                }else {
                    print("데이터(egg) 스냅샷을 가져올 수 없습니다.")
                }
                self.CategoryOption.reloadData()
                print(self.eggstates)
            }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eggnames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! CategoryOptionCell
        
        cell.categoryTitle.text = eggnames[indexPath.row]
        cell.categoryOption.isOn = eggstates[indexPath.row]
        return cell
    }
    
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        // 스위치가 있는 셀의 indexPath를 가져옵니다.
        guard let cell = sender.superview?.superview as? CategoryOptionCell,
              let indexPath = CategoryOption.indexPath(for: cell) else {
            print("셀의 indexPath를 가져올 수 없습니다.")
            return
        }
        
        // 선택한 행에 해당하는 eggState 값을 업데이트하고 Firebase에 저장합니다.
        let selectedEggState = sender.isOn
        eggstates[indexPath.row] = selectedEggState
        saveEggStateAtIndexPath(indexPath)
    }

    func saveEggStateAtIndexPath(_ indexPath: IndexPath) {
        UserApi.shared.me { [self] user, error in
            guard let id = user?.id else {
                print("사용자 ID를 가져올 수 없습니다.")
                return
            }

            let eggName = self.eggnames[indexPath.row]
            let eggState = eggstates[indexPath.row]
            
            let databaseRef = Database.database().reference()
            let eggRef = databaseRef.child("egg").child(String(id)).child(eggName)
            
            // Firebase에 eggState 값을 업데이트합니다.
            eggRef.updateChildValues(["eggState": eggState])
        }
    }

}
