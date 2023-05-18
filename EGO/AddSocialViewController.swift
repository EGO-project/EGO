//
//  AddSocialViewController.swift
//  EGO
//
//  Created by 황재하 on 5/4/23.
//

import UIKit
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKCommon
import SafariServices

import KakaoSDKAuth
import KakaoSDKUser
import Firebase
import FirebaseDatabase

class AddSocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    let ref = Database.database().reference()

    @IBOutlet weak var newFriendsTable: UITableView!
    
    var dataSource: [String] = ["iOS", "iOS 앱", "iOS 앱 개발", "iOS 앱 개발 알아가기", "iOS 앱 개발 알아가기 jake"]
    var filteredDataSource: [String] = []
    
    // 파베친구코드 저장
    var myCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newFriendsTable.dataSource = self
        newFriendsTable.delegate = self
        nowUser()
    }
    
    // 친구추가버튼
    @IBAction func addFriendBtn(_ sender: Any) {
        
    }
    
    // 파이어 베이스에서 친구코드 추출
    func nowUser() {
        UserApi.shared.me { user, error in
            guard error == nil else {
                print("카카오톡 정보 가져오지 못함")
                print(error!)
                return
            }
            
            guard let id = user?.id else {
                return
            }

            // 현재 사용자 친구코드
            self.ref.child("member").child("\(id)").child("friendCode").observeSingleEvent(of: .value) { snapshot  in
                print("\(snapshot)")
                let value = snapshot.value as? String ?? ""
                DispatchQueue.main.async {
                    self.myCode = value
                }
            }
        }
    }
    
    // 친구코드 공유버튼
    @IBAction func linkBtn(_ sender: Any) {
        copyMSG()
    }
    
    // 카카오톡 공유버튼
    @IBAction func kakaoBtn(_ sender: Any) {
        let templateId = 93508
        let templateArgs = ["frCode": "\(String(describing: myCode))"]
        
        if ShareApi.isKakaoTalkSharingAvailable() {
            // 카카오톡으로 카카오톡 공유 가능
            ShareApi.shared.shareCustom(templateId: Int64(templateId), templateArgs: templateArgs) {(sharingResult, error) in
                if error != nil {
                    // 카카오톡이 설치되어 있지 않은 경우, 사용자에게 알림을 표시합니다.
                    self.errorMSG(appName: "카카오톡")
                }
                else {
                    print("shareCustom() success.")
                    if let sharingResult = sharingResult {
                        // 카카오톡 오픈
                        self.copyMSG()
                        UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    // 인스타그램 공유버튼
    @IBAction func instaBtn(_ sender: Any) {
        let instagramURL = URL(string: "instagram://direct_message")!
        
        if UIApplication.shared.canOpenURL(instagramURL) {
            // 인스타그램이 설치되어 있는 경우, DM으로 이동
            copyMSG()
            UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
        } else {
            // 인스타그램이 설치되어 있지 않은 경우, 사용자에게 알림을 표시합니다.
            errorMSG(appName: "인스타그램")
        }
    }
    
    // 친구코드 복사 성공메세지
    func copyMSG() {
        UIPasteboard.general.string = "\(String(describing: myCode))"
        guard let mycode = UIPasteboard.general.string else {
            return print("값 없음")
        }
        let alert = UIAlertController(title: "친구코드 복사됨", message: "\(mycode)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            print("수행 할 동작")
        }
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
    
    // 친구코드 복사 오류메세지
    func errorMSG(appName: String) {
        let alert = UIAlertController(title: "\(appName)이 설치되어 있지 않습니다.", message: "\(appName)을 설치하고 다시 시도해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // 새로운친구 추천 테이블뷰
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddSocialTableViewCell
        cell.newName.text = "새친구 이름"
        
        return cell
    }
    
}
