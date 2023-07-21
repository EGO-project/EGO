//
//  mothlyViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit
import FSCalendar

class mothlyViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    
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
        
        self.currentPage = self.today
        setCalendarUI()
        calendar.delegate = self

        // Do any additional setup after loading the view.
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

}
