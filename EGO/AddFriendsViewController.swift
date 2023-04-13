//
//  AddFriendsViewController.swift
//  EGO
//
//  Created by 황재하 on 4/13/23.
//

import UIKit

class AddFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var addFriendsTable: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFriendsTable.dataSource = self
        addFriendsTable.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as? AddFriendsTableViewCell else {
            return UITableViewCell()
        }
        cell.addFriendEgg.image = UIImage(named: "egg2.png")
        cell.addFriendName.text = "친구추가요청온 알"
        
        return cell
    }
}
