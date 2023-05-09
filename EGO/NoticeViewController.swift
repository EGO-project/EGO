import UIKit
import Firebase
import FirebaseDatabase

class NoticeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var anTable: UITableView!
    var dataArray: [String] = []
    var keyArray: [String] = []
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
                    self.keyArray.insert(child.key, at: 0)
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
        // 1. 선택된 셀의 인덱스 경로를 얻는다.
        let selectedIndexPath = indexPath
        
        // 2. 인덱스 경로를 사용하여 dataArray에서 선택된 항목의 값을 가져온다.
        let announcementKey = keyArray[selectedIndexPath.row]
        
        // 3. NoticeLblViewController 인스턴스를 만들고, 이전 뷰 컨트롤러에서 선택된 값을 설정한다.
        guard let noticeLblViewController = storyboard?.instantiateViewController(withIdentifier: "NoticeLblViewController") as? NoticeLblViewController else { return }
        noticeLblViewController.announcementKey = announcementKey
        
        navigationController?.pushViewController(noticeLblViewController, animated: true)
    }
}
