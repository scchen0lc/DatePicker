//
//  DatePicker.swift
//  
//
//  Created by 陳世爵 on 2021/10/18.
//

import UIKit

fileprivate let today = Date()

public protocol DatePickerDelegate: AnyObject {
    func datePicker(_ datePicker: DatePicker, didSelectDate date: Date?)
}

extension DatePicker {
    
    fileprivate enum Component: Int, CaseIterable {
        case year
        case month
        case day
    }
    
    @objc
    public enum CalendarType: Int {
        case taiwan
        case gregorian
    }
    
    public typealias ToolbarItems = (done: String, cancel: String, clear: String?)
    
    public typealias Components = (year: String, month: String, day: String)
    
}

@IBDesignable
public class DatePicker: UIControl {
    
    private let textField = TextField()
    private let rightImageView = UIImageView()
    private let datePickerView = UIPickerView()
    private var tempDate = today
    
    public var delegate: DatePickerDelegate?
    
    // MARK: - UI Settings
    
    @IBInspectable
    public var font: UIFont? {
        get { textField.font }
        set { textField.font = newValue }
    }
    
    @IBInspectable
    public var rightImage: UIImage? = nil {
        didSet { updateUI() }
    }
    
    @IBInspectable
    public var calendarType: CalendarType = .taiwan {
        didSet { updateUI() }
    }
    
    @IBInspectable
    public var showsWeekday: Bool = true {
        didSet { updateUI() }
    }
    
    // MARK: - Date Settings
    
    public var startDate: Date = today.offset(years: -1)! {
        didSet { updateUI() }
    }
    
    public var endDate: Date = today.offset(years: 1)! {
        didSet { updateUI() }
    }
    
    @objc dynamic
    public var selectedDate: Date? = today {
        didSet {
            if let date = selectedDate {
                tempDate = date
            }
            updateUI()
        }
    }
    
    @IBInspectable
    public var alternativeDateText: String = "請選擇日期..." {
        didSet { updateUI() }
    }
    
    public var toolbarItems: ToolbarItems = ("確認", "取消", "清除") {
        didSet { updateUI() }
    }
    
    public var components: Components = ("年", "月", "日") {
        didSet { updateUI() }
    }
    
    // MARK: - Init
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    private func commonInit() {
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        clipsToBounds = true
        layer.borderWidth = 1
        
        // Right Image View
        rightImageView.tintColor = .darkGray
        rightImageView.contentMode = .scaleAspectFit
        
        // Picker View
        datePickerView.delegate = self
        
        // Text Field
        textField.tintColor = .clear
        textField.font = .monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        textField.rightViewMode = .unlessEditing
        textField.rightView = rightImageView
        textField.inputView = datePickerView
        textField.frame = bounds
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(textField)
        
        // Events
        textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        
        updateUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    // MARK: - Update
    
    private func updateUI() {
        let cornerRadius = bounds.height / 2
        
        layer.cornerRadius = cornerRadius
        
        // Text Field
        textField.contentInset = cornerRadius / 2
        textField.inputAccessoryView = createToolbar()
        
        if let date = selectedDate {
            textField.text = String(format: "%d/%02d/%02d %@",
                                    calendarType == .taiwan ? date.year - 1911 : date.year,
                                    date.month,
                                    date.day,
                                    showsWeekday ? date.weekday : "")
        } else {
            textField.text = alternativeDateText
        }
        
        // Right Image
        rightImageView.frame = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.height)
        rightImageView.image = rightImage
        
        // Picker View
        updatePickerView()
    }
    
    private func updatePickerView() {
        datePickerView.reloadAllComponents()
        
        if let row = availableYears.firstIndex(of: tempDate.year) {
            datePickerView.selectRow(row, inComponent: 0, animated: false)
        }
        
        if let row = availableMonths.firstIndex(of: tempDate.month) {
            datePickerView.selectRow(row, inComponent: 1, animated: false)
        }
        
        if let row = availableDays.firstIndex(of: tempDate.day) {
            datePickerView.selectRow(row, inComponent: 2, animated: false)
        }
    }
    
    // MARK: - Text Field Events
    
    @objc
    private func editingDidBegin() {
        updatePickerView()
    }
    
    @objc
    private func editingDidEnd() {
        
    }
    
    // MARK: UI Actions
    
    @objc
    private func clear(_ sender: Any) {
        selectedDate = nil
        textField.resignFirstResponder()
        sendActions(for: .valueChanged)
        
        delegate?.datePicker(self, didSelectDate: selectedDate)
    }
    
    @objc
    private func cancel(_ sender: Any) {
        if let date = selectedDate {
            tempDate = date
        }
        
        textField.resignFirstResponder()
    }
    
    @objc
    private func done(_ sender: Any) {
        selectedDate = tempDate
        textField.resignFirstResponder()
        sendActions(for: .valueChanged)
        
        delegate?.datePicker(self, didSelectDate: selectedDate)
    }
    
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension DatePicker: UIPickerViewDataSource, UIPickerViewDelegate {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        Component.allCases.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let component = Component(rawValue: component) else {
            fatalError()
        }
        
        switch component {
        case .year:  return availableYears.count
        case .month: return availableMonths.count
        case .day:   return availableDays.count
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let component = Component(rawValue: component) else {
            fatalError()
        }
        
        let title: String
        
        switch component {
        case .year:
            let year = availableYears[row]
            title = (calendarType == .taiwan ? "\(year - 1911)" : "\(year)") + components.year
            
        case .month:
            let month = availableMonths[row]
            title = "\(month)" + components.month
            
        case .day:
            let day = availableDays[row]
            var text = "\(day)" + components.day
            
            if showsWeekday {
                let calendar = Calendar.current
                let components = DateComponents(year: tempDate.year, month: tempDate.month, day: day)
                let date = calendar.date(from: components)!
                text += " " + date.weekday
            }
            
            title = text
        }
        
        let label = UILabel()
        label.text = title
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22)
        
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let component = Component(rawValue: component) else {
            fatalError()
        }
        
        let calendar = Calendar.current
        let year = component == .year ? availableYears[row] : tempDate.year
        let month = component == .month ? availableMonths[row] : tempDate.month
        let day = min(component == .day ? availableDays[row] : tempDate.day,
                      getDays(inYear: year, month: month))
        let components = DateComponents(year: year, month: month, day: day)
        
        tempDate = calendar.date(from: components)!
        
        if tempDate < startDate {
            tempDate = startDate
        } else if tempDate > endDate {
            tempDate = endDate
        }
        
        updatePickerView()
    }
    
}

// MARK: - Utils

extension DatePicker {
    
    private func createToolbar() -> UIToolbar {
        func item(title: String, tintColor: UIColor? = nil, action: Selector) -> UIBarButtonItem {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
            item.tintColor = tintColor
            return item
        }
        
        func flexibleItem() -> UIBarButtonItem {
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }
        
        let toolbar = UIToolbar()
        
        toolbar.barStyle = .default
        toolbar.isTranslucent = false
        toolbar.barTintColor = .white
        toolbar.tintColor = .darkGray
        toolbar.autoresizingMask = [.flexibleHeight]
        toolbar.items = [
            item(title: toolbarItems.cancel, tintColor: .red, action: #selector(cancel(_:))),
            flexibleItem(),
            item(title: toolbarItems.done, action: #selector(done(_:)))
        ]
        
        if let clearTitle = toolbarItems.clear {
            let clear = item(title: clearTitle, action: #selector(clear(_:)))
            toolbar.items?.insert(contentsOf: [clear, flexibleItem()], at: 2)
        }
        
        return toolbar
    }

    private func getDays(inYear year: Int, month: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    private var availableYears: [Int] {
        Array(startDate.year...endDate.year)
    }
    
    private var availableMonths: [Int] {
        var start = 1
        var end = 12
        
        if tempDate.year == availableYears.first {
            start = startDate.month
        }
        
        if tempDate.year == availableYears.last {
            end = endDate.month
        }
        
        return Array(start...end)
    }
    
    private var availableDays: [Int] {
        var start = 1
        var end = getDays(inYear: tempDate.year, month: tempDate.month)
        
        if tempDate.year == availableYears.first && tempDate.month == availableMonths.first {
            start = startDate.day
        }
        
        if tempDate.year == availableYears.last && tempDate.month == availableMonths.last {
            end = endDate.day
        }
        
        return Array(start...end)
    }
    
}
