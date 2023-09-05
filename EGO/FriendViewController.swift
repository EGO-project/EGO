//
//  FriendViewController.swift
//  EGO
//
//  Created by 김민석 on 5/5/23.
//

import UIKit

class FriendViewController: UIViewController {

    // Outlets
    @IBOutlet weak var eggName: UILabel!
    @IBOutlet weak var eggImage: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var diaryImage: UIImageView!
    
    var selectedEgg: egg?
    var allEggs: [egg]? // This should be set from the previous view

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEggData()
        setupPageControl()
        
//        print(selectedEgg)
//        print(allEggs)
    }
    
    func setupEggData() {
        guard let selectedEgg = selectedEgg else { return }
        eggName.text = selectedEgg.name
        eggName.sizeToFit()
        
        eggImage.image = UIImage(named: selectedEgg.kind + "_" + selectedEgg.state)
        
    }
    
    func setupPageControl() {
        guard let allEggs = allEggs else { return }
        pageControl.numberOfPages = allEggs.count
        
        if let selectedIndex = allEggs.firstIndex(where: { $0.name == selectedEgg?.name }) {
            pageControl.currentPage = selectedIndex
        }
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        updateEgg(for: sender.currentPage)
    }

    func updateEgg(for pageIndex: Int) {
        guard let allEggs = allEggs, allEggs.indices.contains(pageIndex) else { return }

        let selectedEgg = allEggs[pageIndex]
        
        UIView.transition(with: eggImage, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.eggImage.image = UIImage(named: selectedEgg.kind + "_" + selectedEgg.state)
        }, completion: nil)
        
        // 이름 변경을 위한 간단한 fade 애니메이션
        UIView.transition(with: eggName, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.eggName.text = selectedEgg.name
        }, completion: nil)
        
        eggName.sizeToFit()
    }

}


