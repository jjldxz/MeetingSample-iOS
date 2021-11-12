//
//  VoteListCell.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/2.
//

import UIKit

class VoteListCell: UITableViewCell {
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        contentView.backgroundColor = .white
        self.selectionStyle = .none
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(rightLabel)
        contentView.addSubview(rightPublishLabel)
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightArrowImageView)
        contentView.addSubview(lineView)
        
        rightLabel.snp.makeConstraints { (mask) in
            mask.right.equalTo(contentView).offset(-30)
            mask.top.equalTo(contentView).offset(8)
            mask.height.equalTo(30)
            mask.width.equalTo(55)
        }
        
        rightPublishLabel.snp.makeConstraints { (mask) in
            mask.right.equalTo(rightLabel.snp.left).offset(-10)
            mask.top.equalTo(contentView).offset(8)
            mask.height.equalTo(30)
        }
        
        leftLabel.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.right.equalTo(rightPublishLabel.snp.left).offset(-15)
            mask.top.equalTo(contentView).offset(8)
            mask.height.equalTo(30)
        }
        
        rightArrowImageView.snp.makeConstraints { (mask) in
            mask.right.equalTo(contentView).offset(-15)
            mask.size.equalTo(CGSize.init(width: 6, height: 10))
            mask.centerY.equalTo(rightLabel)
        }
        
        lineView.snp.makeConstraints { (mask) in
            mask.leftMargin.equalTo(0)
            mask.rightMargin.equalTo(0)
            mask.bottom.equalTo(contentView).offset(-1)
            mask.height.equalTo(0.8)
        }
    }
    
    var model: VoteModelListItem?{
        didSet{
          guard let model = model else { return }
            leftLabel.text = model.title as String?
            rightLabel.text = model.status == 0 ? "To Start" : model.status == 1 ? "Voting" : "Ended"
            rightPublishLabel.text = model.share == true ? "Publishing" : ""
            
            rightPublishLabel.snp.remakeConstraints{ (mask) in
                mask.right.equalTo(rightLabel.snp.left).offset(0)
                mask.top.equalTo(contentView).offset(13)
                mask.height.equalTo(20)
                mask.width.equalTo(model.share == true ? 80 : 0)
               
            }
            
            leftLabel.snp.makeConstraints { (mask) in
                mask.left.equalTo(contentView).offset(15)
                mask.right.equalTo(rightPublishLabel.snp.left).offset(model.share == true ? 10 : 0)
                mask.top.equalTo(contentView).offset(8)
                mask.height.equalTo(30)
            }
        }
    }

    
    private lazy var leftLabel : UILabel = {
        let leftLabel = UILabel.init()
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        leftLabel.textColor = mainBlackColor
        leftLabel.text = "poll"
        return leftLabel
    }()
    
    private lazy var rightLabel : UILabel = {
        let rightLabel = UILabel.init()
        rightLabel.font = UIFont.systemFont(ofSize: 14)
        rightLabel.textColor = grayBlackTextColor
        rightLabel.textAlignment = .right
        rightLabel.text = "voting"
        return rightLabel
    }()
    
    private lazy var rightPublishLabel : UILabel = {
        let rightPublishLabel = UILabel.init()
        rightPublishLabel.font = UIFont.systemFont(ofSize: 12)
        rightPublishLabel.textColor = mainColor
        rightPublishLabel.textAlignment = .center
        rightPublishLabel.text = "publishing"
        rightPublishLabel.layer.cornerRadius = 4
        rightPublishLabel.layer.masksToBounds = true
        rightPublishLabel.layer.borderWidth = 1
        rightPublishLabel.layer.borderColor = mainColor.cgColor
        return rightPublishLabel
    }()
    
    private lazy var rightArrowImageView : UIImageView = {
        let rightArrowImageView = UIImageView.init()
        rightArrowImageView.image = UIImage.init(named: "meeting_right_icon")
        return rightArrowImageView
    }()
    
    lazy var lineView : UIView = {
        let lineView = UIView.init()
        lineView.backgroundColor = klineColor
        return lineView
    }()
    
    
}
