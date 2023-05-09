//
//  CCViewController.swift
//  
//
//  Created by 황재하 on 5/5/23.
//

import UIKit

class CCViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collection: UICollectionView!
    
    let dataArray: Array<UIImage> = [UIImage(named: "공유.png")!, UIImage(named: "인스타.png")!, UIImage(named: "카카오.png")!]
    var nowPage: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCCell", for: indexPath) as! FirstCollectionViewCell
        cell.imgView.image = dataArray[indexPath.row]
        return cell
    }
    // UICollectionViewDelegateFlowLayout 상속
       //컬렉션뷰 사이즈 설정
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: collection.frame.size.width  , height:  collection.frame.height)
       }
       
       //컬렉션뷰 감속 끝났을 때 현재 페이지 체크
       func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
           nowPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
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
