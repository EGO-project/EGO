//
//  CustomWeekdayView.swift
//  EGO
//
//  Created by bugon cha on 2023/08/13.
//

import UIKit
import FSCalendar

class CustomWeekdayView: FSCalendarWeekdayView {
    private var topLineView: UIView?
    private var bottomLineView: UIView?

    override init(frame: CGRect) {
        super.init(frame:frame)
        setupLines()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLines()
    }

    private func setupLines() {
        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 1))
        topLine.backgroundColor = .gray
        topLineView = topLine
        self.addSubview(topLine)

        let bottomLine = UIView(frame: CGRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1))
        bottomLine.backgroundColor = .gray
        bottomLineView = bottomLine
        self.addSubview(bottomLine)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topLineView?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 1)
        bottomLineView?.frame = CGRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
    }
}
