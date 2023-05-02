import UIKit
import Firebase
import FirebaseCore

class NoticeLblViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    @IBOutlet weak var notceLbl: UILabel!
    
    let ref = Database.database().reference()
    var announcementKey: String?
    
//    override func viewWillAppear(_ animated: Bool) {
            //super.viewWillAppear(animated)
    func fetchData() {
            if let key = announcementKey {
                print("23")
                ref.child("announcement/\(key)").observeSingleEvent(of: .value, with: { snapshot in
                    if let title = snapshot.childSnapshot(forPath: "description").value as? String {
                        print(title)
                        self.notceLbl.text = title
                    }
                }) { error in
                    print(error.localizedDescription)
                }
            }
        }

    }
