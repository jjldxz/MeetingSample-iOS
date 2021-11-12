//
//  MeetingListCell.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/1.
//

import UIKit

class MeetingListCell: UITableViewCell {

    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var owner_label: UILabel!
    @IBOutlet weak var meeting_status_label: UILabel!

    var data:meetingInfoStruct?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func handleDatasWith(model: meetingInfoStruct) {
        self.data = model
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormate.timeZone = TimeZone(abbreviation: "UTC")
        let startAt:Date = dateFormate.date(from: model.beginAt!)!
        let endAt:Date = dateFormate.date(from: model.endAt!)!
        
        let calendar:Calendar = Calendar.current
        let meeting_day:Int = calendar.component(.day, from: startAt)
        let meeting_month:Int = calendar.component(.month, from: startAt)
        let meeting_start_h:Int = calendar.component(.hour, from: startAt)
        let meeting_start_m:Int = calendar.component(.minute, from: startAt)
        let meeting_end_h:Int = calendar.component(.hour, from: endAt)
        let meeting_end_m:Int = calendar.component(.minute, from: endAt)
        
        let dateTime:String = String(meeting_day) + "d " + String(meeting_month) + "th"
        let attrbute_date_text = NSMutableAttributedString.init(string: dateTime)
        attrbute_date_text.addAttribute(.font, value: UIFont.systemFont(ofSize: 20), range: NSRange.init(location: 0, length: String(meeting_day).count))
        attrbute_date_text.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: NSRange.init(location: String(meeting_day).count, length: 2))
        attrbute_date_text.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: NSRange.init(location: String(meeting_day).count + 2, length: String(meeting_month).count))
        attrbute_date_text.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: NSRange.init(location: dateTime.count - 2, length:2))
        self.date_label.attributedText = (attrbute_date_text.copy() as! NSAttributedString)
        
        let time_string:String = String(format: "%.2d", meeting_start_h) + ":" + String(format: "%.2d", meeting_start_m) + " - " + String(format: "%.2d", meeting_end_h) + ":" + String(format: "%.2d", meeting_end_m) + " " + String(model.number!)
        self.time_label.text = time_string
        
        self.owner_label.text = model.ownerName! + "'s meeting: " + model.name!
        switch model.status {
        case 0:
            self.meeting_status_label.text = "New"
            self.meeting_status_label.textColor = .orange
            break
        case 1:
            self.meeting_status_label.text = "Ongoing"
            self.meeting_status_label.textColor = .green
            break
        case 2:
            self.meeting_status_label.text = "Done"
            self.meeting_status_label.textColor = .lightGray
            break
        default:
            break
        }
    }
    
}
