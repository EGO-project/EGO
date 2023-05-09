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

class AddSocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var newFriendsTable: UITableView!
       
    override func viewDidLoad() {
        super.viewDidLoad()
        newFriendsTable.dataSource = self
        newFriendsTable.delegate = self
        searchCode()
    }
    
    // 검색창
    func searchCode() {
        var bounds = UIScreen.main.bounds
        var width = bounds.size.width //화면 너비
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: width - 28, height: 0))
        searchBar.placeholder = "EGO 코드로 검색"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)
    }
    
    // 친구코드 공유버튼
    @IBAction func linkBtn(_ sender: Any) {
        copyMSG()
    }
    
    // 카카오톡 공유버튼
    @IBAction func kakaoBtn(_ sender: Any) {
        
        let templateId = 93508
        let templateArgs = ["frCode": "000000"]
        
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
    
    // 새로운친구 추천 테이블뷰
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddSocialTableViewCell
        cell.newName.text = "새친구 이름"
        
        return cell
    }
    
    // 친구코드 복사 성공메세지
    func copyMSG() {
        UIPasteboard.general.string = "친구코드 : 000000"
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
}
