//
//  AddSocialViewController.swift
//  EGO
//
//  Created by 황재하 on 5/4/23.
//

import UIKit

class AddSocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var newFriendsTable: UITableView!
    
    @IBOutlet weak var searchCode: UISearchBar!

       
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddSocialTableViewCell
        cell.newName.text = "새친구 이름"
        
        
        return cell
    }
}
