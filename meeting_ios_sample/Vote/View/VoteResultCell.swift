//
//  VoteResultCell.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/3.
//

import UIKit
import RxSwift

class VoteResultCell: UITableViewCell {
    var indexPath : NSIndexPath?
//    let itemLabel : UILabel
//    let selectButtonItem : UIButton
//    let itemCountLabel : UILabel
//
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        itemLabel = UILabel()
//        selectButtonItem = UIButton()
//        itemCountLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectClick() {
        //按钮点击
    }
    
    var model: VoteModel?{
        didSet{
          guard let model = model else { return }
            itemLabel.numberOfLines = 0
            let qustionModel : VoteQustionModel = (model.questions![indexPath!.section]) as VoteQustionModel
            let opeionModel : VoteOptionModel = (qustionModel.options[indexPath!.row]) as VoteOptionModel
            itemLabel.text = opeionModel.content as String?
            //hashid关联用户名称
            //处理显示数据
            if (opeionModel.voters!.count > 0)  {
                itemNameLabel.text = opeionModel.voters?.compactMap{(temp) -> String? in
                    return (temp["username"]! as! String)
                }.joined(separator:"、")
            }

            var voteCount = 0
            for opeionModel : VoteOptionModel in qustionModel.options {
                voteCount += opeionModel.count!
            }
            if voteCount == 0 {
                itemCountLabel.text = "0" + " Tickets " + "0" + "%"
                progressView.setProgress(0,animated:false)
            }else{
                let floatcountAll : Float = Float(voteCount)
                let floatcount : Float = Float(opeionModel.count!)
                let flotev = Float(floatcount / floatcountAll)
                let sizeInKBStr = NSString(format: "%.2f", flotev)
                itemCountLabel.text = String(opeionModel.count!) + (opeionModel.count! == 1 ? "Ticket " : "Tickets ") + String(sizeInKBStr.intValue * 100) + "%"
                progressView.setProgress(flotev,animated:false)
            }
        }
    }
    
    func setupViews() {
        contentView.addSubview(itemLabel)
        if SampleMeetingManager.defaultManager().user_info?.role == "attendee" {
            contentView.addSubview(selectButtonItem)
        }
        contentView.addSubview(itemCountLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(itemNameLabel)
        
        itemLabel.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalToSuperview().offset(10)
            mask.right.lessThanOrEqualTo(contentView).offset(-130)
        }
        
        itemCountLabel.snp.makeConstraints { (mask) in
            mask.right.equalTo(contentView).offset(-15)
            mask.top.equalTo(contentView).offset(8)
            mask.width.equalTo(120)
            mask.height.equalTo(20)
        }
        
        progressView.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalTo(itemLabel.snp.bottom).offset(10)
            mask.height.equalTo(3)
            mask.right.equalTo(contentView).offset(-15)
        }
        
        itemNameLabel.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalTo(progressView.snp.bottom).offset(10)
            mask.right.equalTo(contentView).offset(-15)
            mask.bottom.equalToSuperview().offset(-10.0)
        }
    }
    
    
    private lazy var itemContentView : UIView = {
        let itemContentView = UIView.init()
        itemContentView.backgroundColor = .white
        return itemContentView
    }()

    private lazy var itemLabel : UILabel = {
        let itemLabel = UILabel.init()
        itemLabel.font = UIFont.boldSystemFont(ofSize: 14)
        itemLabel.textColor = mainBlackColor
        itemLabel.numberOfLines = 0
        return itemLabel
    }()


    lazy var selectButtonItem : UIButton = {
        let selectButtonItem = UIButton.init()
        selectButtonItem.addTarget(self, action: #selector(selectClick), for: .touchUpInside)
        selectButtonItem.setImage(UIImage.init(named: "nn"), for: .normal)
        return selectButtonItem
    }()

    private lazy var itemCountLabel : UILabel = {
        let itemCountLabel = UILabel.init()
        itemCountLabel.font = UIFont.systemFont(ofSize: 14)
        itemCountLabel.textColor = mainBlackColor
        itemCountLabel.textAlignment = .right
        itemCountLabel.text = "0" + "Tickets " + "0" + "%"
        return itemCountLabel
    }()
    
    private lazy var progressView : UIProgressView = {
        let progressView = UIProgressView(progressViewStyle:UIProgressView.Style.default)
        progressView.progress = 0
        progressView.progressTintColor = mainColor  //已有进度颜色
        progressView.trackTintColor = klineColor
        return progressView
    }()
    
    

    private lazy var itemNameLabel : UILabel = {
        let itemNameLabel = UILabel.init()
        itemNameLabel.font = UIFont.systemFont(ofSize: 12)
        itemNameLabel.textColor = grayBlackTextColor
        itemNameLabel.numberOfLines = 0
        return itemNameLabel
    }()

}
