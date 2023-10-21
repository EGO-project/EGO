//
//  MainViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/03/16.
//

import UIKit
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKCommon
import SafariServices

import KakaoSDKAuth
import KakaoSDKUser
import Firebase
import FirebaseDatabase

class MainViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var addBut: UIButton!
    var eggnames : [String] = []
    var images : [UIImage] = []
    var idData : String = ""
    var eggStatus: String = ""
    
    var eggList : [egg] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        self.barStyle()
        
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        
        print("view did load : \(idData)")
        
    }
    
    func barStyle(){
        
        let image = UIImage(named: "타이틀")
        navigationItem.titleView = UIImageView(image: image)
        
        if let leftImage = UIImage(named: "후라이샵") {
            let buttonImage = leftImage.withRenderingMode(.alwaysOriginal)
            let leftItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(leftButAction))
            navigationItem.leftBarButtonItem = leftItem
        }
        
        if let rightImage = UIImage(named: "알림") {
            let buttonImage = rightImage.withRenderingMode(.alwaysOriginal)
            let rightItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(rightButAction))
            navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    @objc private func leftButAction(){
        performSegue(withIdentifier: "shop", sender: nil)
    }
    
    @objc private func rightButAction(){
        performSegue(withIdentifier: "alarm", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(idData)
        print("Main viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.updateCurrentImageId()
        print(idData)
        
        print(eggnames)
        print(idData)
        print(type(of: idData))
        
        NotificationCenter.default.post(
            name: NSNotification.Name("EggIdNotification"),
            object: nil,
            userInfo: ["id" : idData]
        )
    }
    
    // 파이어베이스에 저장된 egg정보 가져오기
    func fetchData() {
        guard let uid = Auth.auth().currentUser?.uid else { return print("알 저장 실패")}
        
        let databaseRef = Database.database().reference()
        let eggRef = databaseRef.child("egg").child(uid)
        
        eggRef.observeSingleEvent(of: .value) { snapshot  in
            self.eggnames.removeAll()
            self.images.removeAll() // 이미지 배열 초기화
            
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for childSnapshot in dataSnapshot {
                    let egg = egg(snapshot: childSnapshot)
                    
                    if let image = UIImage(named: "\(egg.kind)_\(egg.state)") {
                        self.images.append(image)
                    } else {
                        print("이미지를 찾을 수 없습니다.")
                    }
                    
                    if let name : String? = egg.name{
                        self.eggnames.append(name!)
                    } else {
                        print("알 이름을 찾을 수 없습니다.")
                    }
                }
                
                self.addContentScrollView()
                self.setPageControl()
            }else {
                print("데이터(egg) 스냅샷을 가져올 수 없습니다.")
            }
        }
    }
    
    // 현재 화면에 보이는 이미지의 ID 값을 업데이트하는 메서드
    func updateCurrentImageId() {
        let visibleIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        if visibleIndex < eggnames.count {
            idData = eggnames[visibleIndex]
        }
    }
    
    //이미지를 담은 배열을 순회하며 이미지뷰를 생성. 이미지뷰의 위치와 크기를 설정, 할당. scrollView의 contentSize를 설정
    func addContentScrollView() {
        for i in 0..<images.count {
            
            let imageView = UIImageView()
            let eggNameLabel = UILabel()
            let xPos = scrollView.frame.width * CGFloat(i)
            // 알 이름
            eggNameLabel.frame = CGRect(x: xPos, y: 0, width: scrollView.bounds.width, height: 60)
            eggNameLabel.text = eggnames[i]
            eggNameLabel.font = UIFont.systemFont(ofSize: 20)
            eggNameLabel.textAlignment = .center
            scrollView.addSubview(eggNameLabel)
            
            // 알 이미지
            imageView.frame = CGRect(x: xPos, y: 80, width: scrollView.bounds.width, height: 250)
            imageView.image = images[i]
            scrollView.addSubview(imageView)
            
            scrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
        
        if images.isEmpty {
            let imageView = UIImageView()
            let xPos: CGFloat = 0
            
            // 알 이미지
            imageView.frame = CGRect(x: xPos, y: 80, width: scrollView.bounds.width, height: 250)
            imageView.image = UIImage(named: "egg_신규")
            scrollView.addSubview(imageView)
            
            addBut.center.x = view.center.x
            
            scrollView.contentSize.width = scrollView.bounds.width
            
            
        }
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let xOffset = scrollView.frame.size.width * CGFloat(sender.currentPage)
        scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
    }
    
    
    func setPageControl(){
        pageControl.numberOfPages = images.count
        pageControl.pageIndicatorTintColor = UIColor(hexCode: "FDF2C5") // 모든
        pageControl.currentPageIndicatorTintColor = UIColor(hexCode: "FFC965") // 해당
        pageControl.currentPage = 0
    }
    
    //현재 페이지를 pageControl의 currentPage 속성에 설정
    func selectedPage(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
    
    //현재 페이지를 업데이트
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x / scrollView.frame.size.width
        selectedPage(currentPage: Int(round(value)))
    }
    
}

