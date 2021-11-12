//
//  VoteUserResultCell.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/9.
//

import UIKit

class VoteUserResultCell: UITableViewCell {
    var indexPath : NSIndexPath?

    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model: VoteModel?{
        didSet{
          guard let model = model else { return }
            itemLabel.numberOfLines = 0
            let qustionModel : VoteQustionModel = (model.questions![indexPath!.section]) as VoteQustionModel
            let opeionModel : VoteOptionModel = (qustionModel.options[indexPath!.row]) as VoteOptionModel
            itemLabel.text = opeionModel.content as String?
            selectButtonItem.isHidden = opeionModel.is_select == false
        }
    }
    
    func setupViews() {
        contentView.addSubview(itemLabel)
        contentView.addSubview(selectButtonItem)
        
        itemLabel.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalToSuperview().offset(10)
            mask.right.lessThanOrEqualTo(contentView).offset(-60)
            mask.bottom.equalToSuperview().offset(-10.0)
        }
   
        selectButtonItem.snp.makeConstraints { (mask) in
            mask.left.equalTo(itemLabel.snp.right).offset(8)
            mask.top.equalTo(contentView).offset(8)
            mask.height.width.equalTo(20)
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
        selectButtonItem.setImage(UIImage.init(named: "nn"), for: .normal)
        return selectButtonItem
    }()

}
