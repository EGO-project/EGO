//
//  MainViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/03/16.
//

//import UIKit
//import Firebase
//import KakaoSDKUser

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
    
    
    //    @IBOutlet weak var eggName: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var eggnames : [String] = []
    var images : [UIImage] = []
    
    var eggList : [egg] = []
    var diaryList: [diary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        print("\(diaryList.count)")
    }
    
    
    // 파이어베이스에 저장된 egg정보 가져오기
    func fetchData() {
        UserApi.shared.me { user, error in
            guard let id = user?.id else {
                print("사용자 ID를 가져올 수 없습니다.")
                return
            }
            
            let databaseRef = Database.database().reference()
            let calenderRef = databaseRef.child("calender").child(String(id))
            let eggRef = databaseRef.child("egg").child(String(id))
            
            eggRef.observeSingleEvent(of: .value) { snapshot  in
                self.eggnames.removeAll()
                self.images.removeAll() // 이미지 배열 초기화
                self.diaryList.removeAll() // 배열 초기화
                
                if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for childSnapshot in dataSnapshot {
                        let egg = egg(snapshot: childSnapshot)
                        let diary = diary(snapshot: childSnapshot)
                        self.diaryList.append(diary)
                        
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
                    print("다이어리 리스트 : \(self.diaryList.count)")
                }else {
                    print("데이터(egg) 스냅샷을 가져올 수 없습니다.")
                }
            }
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
    }
    
    //pageControl의 페이지 수를 이미지 배열의 크기로 설정
    func setPageControl() {
        pageControl.numberOfPages = images.count
        
    }
    
    //현재 페이지를 pageControl의 currentPage 속성에 설정
    func setPageControlSelectedPage(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
    
    //현재 페이지를 업데이트
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x / scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
    
    
}


