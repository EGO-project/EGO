//
//  EggRoom1ViewController.swift
//  Pods
//
//  Created by bugon cha on 2023/06/03.
//

import UIKit

let imageNames = ["Lug", "장식품", "벽장식", "창문", "벽지", "바닥"]

class EggRoomViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as! EggRoomCollectionViewCell
        let imageName = imageNames[indexPath.item]
        cell.image.image = UIImage(named: imageName)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? EggRoomPDViewController else { return }
        
        if let indexPath = Collection.indexPathsForSelectedItems?.first {
            let selectedItem = imageNames[indexPath.item]
            dest.imageName = selectedItem
        }
    }
    
    
    
   
    @IBOutlet weak var Collection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Collection.delegate = self
        Collection.dataSource = self
        
        
    }
    
}
