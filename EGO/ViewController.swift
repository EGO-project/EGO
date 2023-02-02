//
//  ViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/01/25.
//

import UIKit

var eggs  = [ // 알 이미지]

class ViewController: UIViewController {
    
    // 알 리스트
    @IBOutlet var eggView: UIImageView!
    @IBOutlet var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //페이지 컨트롤의 전체 페이지를 images 배열의 전체 개수 값으로 설정
        pageControl.numberOfPages = eggs.count
        // 페이지 컨트롤의 현재 페이지를 0으로 설정
        pageControl.currentPage = 0
        // 페이지 표시 색상을 밝은 회색 설정
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        // 현재 페이지 표시 색상을 검정색으로 설정
        pageControl.currentPageIndicatorTintColor = UIColor.black
        eggView.image = UIImage(named: eggs[0])
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        // images라는 배열에서 pageControl이 가르키는 현재 페이지에 해당하는 이미지를 imgView에 할당
        eggView.image = UIImage(named: eggs[pageControl.currentPage])
    }
    
    @IBOutlet var eggName: UILabel!
    
    // 달력
    @IBAction func goMothly(_ sender: UIButton) {
        let mothly = self.storyboard?.instantiateViewController(withIdentifier: "mothly")
        self.navigationController?.pushViewController(mothly!, animated: true)
    }
    
    
    
}

