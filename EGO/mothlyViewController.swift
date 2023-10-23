//
//  mothlyViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit
import FSCalendar
import KakaoSDKUser
import Firebase

class mothlyViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var yearLbl: UILabel!
    
    var idName : String = ""
    var diaryList: [diary] = []
    var currentPage: Date?
    var selectedEggId : String = ""
    var today: Date = {
        return Date()
    }()
    
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "MM.dd"
        return df
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear2  \(idName)")
        
    }
    
    func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendar.setCurrentPage(self.currentPage!, animated: true)
    } // 달력 넘기는 버튼
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func prev(_ sender: UIButton) {
        scrollCurrentPage(isPrev: true)
        print(dateFormatter)
    }
    
    @IBAction func next(_ sender: UIButton) {
        scrollCurrentPage(isPrev: false)
    }
    
    var selectedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        self.currentPage = self.today
        calendar.delegate = self
        calendar.dataSource = self
        // Do any additional setup after loading the view.
        
        print("mothl7yl : \(idName)")
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let mainTabBarController = self.tabBarController as? MainTabBarViewController {
            idName = mainTabBarController.idData
            print("Received idData monthly: \(idName)")
            
            // 데이터를 받은 후에 화면을 갱신하거나 필요한 로직
            fetchData()
            setCalendarUI()
        }
    }
    
    // 캘린더 디자인
    func setCalendarUI() {
        // delegate, dataSource
        self.calendar.delegate = self
        self.calendar.dataSource = self
        
        // calendar locale > 한국으로 설정
        calendar.locale = Locale(identifier: "ko_KR")
        
        
        // 양옆 년도, 월 지우기
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        
        // 요일 글자 색
        calendar.appearance.weekdayTextColor = UIColor(named: "000000")?.withAlphaComponent(0.2)
        calendar.appearance.titleWeekendColor = UIColor(hexCode: "FEC965")
        
        
        // Header dateFormat, 년도, 월 폰트(사이즈)와 색, 가운데 정렬, 헤더 높이
        calendar.appearance.headerDateFormat = "MM. dd"
        //self.calendar.appearance.headerTitleFont = UIFont.SpoqaHanSans(type: .Bold, size: 20)
        calendar.appearance.headerTitleColor = UIColor(named: "FFFFFF")?.withAlphaComponent(0.9)
        calendar.appearance.headerTitleAlignment = .center
        calendar.headerHeight = 0
        calendar.scope = .month
        headerLabel.text = self.dateFormatter.string(from: calendar.currentPage)
        yearLbl.text = String(Calendar.current.component(.year, from: today))
        
        calendar.appearance.titleFont = UIFont(name: "NotoSans", size: 25)
        
        
        // 상단 요일을 한글로 변경
        calendar.calendarWeekdayView.weekdayLabels[0].text = "S"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "M"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "T"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "W"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "T"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "F"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "S"
        
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor(hexCode: "FEC965")
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = UIColor(hexCode: "FEC965")
        
        // 요일 타이틀 아래쪽에 구분선 추가
        let bottomSeparatorView = UIView()
        bottomSeparatorView.backgroundColor = UIColor.lightGray
        calendar.addSubview(bottomSeparatorView)
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomSeparatorView.leadingAnchor.constraint(equalTo: calendar.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: calendar.trailingAnchor),
            bottomSeparatorView.bottomAnchor.constraint(equalTo: calendar.daysContainer.topAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // 달에 유효하지않은 날짜 지우기
        calendar.placeholderType = .none
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.headerLabel.text = self.dateFormatter.string(from: calendar.currentPage)
    }
    
    
    // 당일 날짜 이후 선택 불가
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func fetchData() {
        UserApi.shared.me { user, error in
            guard let id = user?.id else {
                print("사용자 ID를 가져올 수 없습니다.")
                return
            }
            
            let databaseRef = Database.database().reference()
            let calenderRef = databaseRef.child("calender").child(String(id))
            
            calenderRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot, error: String?)  in
                self.diaryList.removeAll() // 배열 초기화
                
                if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for childSnapshot in dataSnapshot {
                        let diary = diary(snapshot: childSnapshot)
                        if diary.eggId == self.idName {
                            self.diaryList.append(diary)
                        }
                    }
                } else {
                    print("데이터(diary) 스냅샷을 가져올 수 없습니다.")
                }
                
                self.calendar.reloadData()
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let matchingDiary = diaryList.first { dateFormatter.string(from: $0.date) == dateString }
        
        // 알 이름 조건 추가
        if let diary = matchingDiary, diary.eggId == idName {
            var image = UIImage(named: "\(diary.category).png")
            
            // 이미지 크기 조절 (예: 가로 30포인트, 세로 30포인트)
            let imageSize = CGSize(width: 75, height: 75) // 원하는 크기로 설정
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            image?.draw(in: CGRect(origin: .zero, size: imageSize))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let diaryList = storyboard.instantiateViewController(withIdentifier: "diaryList") as? mothlyListViewController {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            
            diaryList.selectedDate = dateFormatter.date(from: dateString) ?? Date()
            diaryList.selectedEggId = idName
            
            
            var viewControllers = self.navigationController?.viewControllers
            viewControllers?.removeLast()
            viewControllers?.append(diaryList)
            self.navigationController?.setViewControllers(viewControllers ?? [], animated: false)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add1" {
            if let destinationVC = segue.destination as? mothlyAdd_1ViewController {
                destinationVC.idName = idName
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}
