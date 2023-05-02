import UIKit
import Firebase
import FirebaseDatabase

class NoticeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var dataArray: [String] = []
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        anTable.dataSource = self
        anTable.delegate = self
        fetchData()
    }
    
    func fetchData() {
        ref.child("announcement").observeSingleEvent(of: .value, with: { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Error: Could not cast snapshot to children array.")
                return
            }
            for child in children {
                if let value = child.childSnapshot(forPath: "title").value as? String {
                    self.dataArray.insert(value, at: 0) // 내림차순
                }
            }
            self.anTable.reloadData()
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]
        
        // 셀 선택시 색변경 없앰
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let announcementKey = dataArray[indexPath.row]
            performSegue(withIdentifier: "showNoticeLbl", sender: announcementKey)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showNoticeLbl" {
                if let noticeLblViewController = segue.destination as? NoticeLblViewController {
                    noticeLblViewController.announcementKey = sender as? String
                }
            }
        }
    
    @IBOutlet weak var anTable: UITableView!
    
}
