//
//  VoteCell.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/3.
//

import UIKit

class VoteCell: UITableViewCell {
    var indexPath : NSIndexPath?
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        self.selectionStyle = .none
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectClick() {
        //按钮点击
    }
    
    var voteOption : VoteOptionModel?{
        didSet{
            guard voteOption != nil else { return }
            itemLabel.text = voteOption!.content as String?
            if voteOption!.is_single == 1 {
                if voteOption!.is_select! {
                    selectButtonItem.setImage(UIImage.init(named: "meeting_select_icon"), for: .normal)
                }else{
                    selectButtonItem.setImage(UIImage.init(named: "meeting_unselect_icon"), for: .normal)
                }
                
                
            }else{
                if voteOption!.is_select! {
                    selectButtonItem.setImage(UIImage.init(named: "mutSelect"), for: .normal)
                }else{
                    selectButtonItem.setImage(UIImage.init(named: "mutUnSelect"), for: .normal)
                }
                
                
            }
        }
    }
    
    func setupViews() {
        contentView.addSubview(itemLabel)
        contentView.addSubview(selectButtonItem)
        
        selectButtonItem.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalTo(contentView).offset(8)
            mask.height.width.equalTo(30)
        }
        
        itemLabel.snp.makeConstraints { (mask) in
            mask.left.equalTo(selectButtonItem.snp.right).offset(10)
            mask.top.equalToSuperview().offset(8)
            mask.right.equalTo(contentView).offset(-15)
            mask.height.greaterThanOrEqualTo(30)
            mask.bottom.equalToSuperview().offset(-8.0)
        }
    }
    
    private lazy var itemLabel : UILabel = {
        let itemLabel = UILabel.init()
        itemLabel.font = UIFont.systemFont(ofSize: 14)
        itemLabel.textColor = mainBlackColor
        itemLabel.numberOfLines = 0
        itemLabel.isUserInteractionEnabled = false
        return itemLabel
    }()
    
    lazy var selectButtonItem : UIButton = {
        let selectButtonItem = UIButton.init()
        selectButtonItem.isUserInteractionEnabled = false
        selectButtonItem.addTarget(self, action: #selector(selectClick), for: .touchUpInside)
     
        return selectButtonItem
    }()
}
