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
    
    @IBOutlet weak var searchCode: UISearchBar!

    // 카톡 공유 버튼
    let templateId = 93508
    let templateArgs = ["frCode": "123456"]

       
    override func viewDidLoad() {
        super.viewDidLoad()
        newFriendsTable.dataSource = self
        newFriendsTable.delegate = self
        // Do any additional setup after loading the view.
        searchCode.delegate = self
        setSearch()
        
    }
    
    func setSearch() {
        searchCode.placeholder = "EGO 코드로 검색"
        
    }
    
    // 내 친구코드 복사 버튼
    @IBAction func linkBtn(_ sender: Any) {
        UIPasteboard.general.string = "친구코드 : 000000"
        guard let code = UIPasteboard.general.string else {
            return print("값 없음")
        }
        let alert = UIAlertController(title: "친구코드 복사됨", message: "\(code)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            print("수행 할 동작")
          }
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
    
    // 카카오톡 공유버튼
    @IBAction func kakaoBtn(_ sender: Any) {
        if ShareApi.isKakaoTalkSharingAvailable() {
            // 카카오톡으로 카카오톡 공유 가능
            ShareApi.shared.shareCustom(templateId: Int64(templateId), templateArgs: templateArgs) {(sharingResult, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("shareCustom() success.")
                    if let sharingResult = sharingResult {
                        // 카카오톡 오픈
                        UIPasteboard.general.string = "친구코드 : 123456"
                        UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddSocialTableViewCell
        cell.newName.text = "새친구 이름"
        
        
        return cell
    }
}
