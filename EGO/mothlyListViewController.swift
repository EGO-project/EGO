//
//  mothlyListViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit

class mothlyListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var diaryListView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        diaryListView.dataSource = self
        diaryListView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return diary.diaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let diarycell = tableView.dequeueReusableCell(withIdentifier: "diaryCell", for: indexPath) as! diaryListTableViewCell
        
        let target = diary.diaryList[indexPath.row]
        
        diarycell.contentLabel?.text = target.content
        diarycell.dateLabel?.text = "\(target.date)"

        return diarycell
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
