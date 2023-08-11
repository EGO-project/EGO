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

class mothlyViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    var idName : String = ""
    var diaryList: [diary] = []
    var currentPage: Date?
    var today: Date = {
        return Date()
    }()
    
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 M월"
        return df
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setCalendarUI()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEggIdNotification(_:)),
            name: NSNotification.Name("EggIdNotification"),
            object: nil
        )
        print(idName)
    }
    
    @objc public func handleEggIdNotification(_ notification: Notification) {
        print("시작")
        if let receivedId = notification.userInfo?["id"] as? String {
            print("전달 받은 데이터 : \(receivedId)")
            self.idName = receivedId
            // 원하는 로직 수행
        } else {
            print("전달 받은 데이터가 유효하지 않습니다.")
        }
        print("test")
        print("test2")
    }
    
    func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendar.setCurrentPage(self.currentPage!, animated: true)
    }
    // 달력 넘기는 버튼
    
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
        setCalendarUI()
        calendar.delegate = self
        calendar.dataSource = self
        // Do any additional setup after loading the view.
        
        print("mothl7yl : \(idName)")
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
        calendar.appearance.titleWeekendColor = .systemYellow
        
        // Header dateFormat, 년도, 월 폰트(사이즈)와 색, 가운데 정렬, 헤더 높이
        calendar.appearance.headerDateFormat = "MM. dd"
        //self.calendar.appearance.headerTitleFont = UIFont.SpoqaHanSans(type: .Bold, size: 20)
        calendar.appearance.headerTitleColor = UIColor(named: "FFFFFF")?.withAlphaComponent(0.9)
        calendar.appearance.headerTitleAlignment = .center
        calendar.headerHeight = 0
        calendar.scope = .month
        headerLabel.text = self.dateFormatter.string(from: calendar.currentPage)
        
        
        // 상단 요일을 한글로 변경
        calendar.calendarWeekdayView.weekdayLabels[0].text = "S"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "M"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "T"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "W"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "T"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "F"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "S"
        
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = .systemYellow
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = .systemYellow
        
        
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
            
            calenderRef.observeSingleEvent(of: .value) { snapshot  in
                self.diaryList.removeAll() // 배열 초기화
                
                if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for childSnapshot in dataSnapshot {
                        let diary = diary(snapshot: childSnapshot)
                        self.diaryList.append(diary)
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
        
        if let diary = matchingDiary {
            return UIImage(named: "\(diary.category).png")
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            guard let diaryList = self.storyboard?.instantiateViewController(identifier: "diaryList") as? mothlyListViewController else { return }
            
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
        
        diaryList.selectedDate = dateFormatter.date(from: dateString) ?? Date()
        diaryList.selectedEggId = idName
            
            self.present(diaryList, animated: true, completion: nil)
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
