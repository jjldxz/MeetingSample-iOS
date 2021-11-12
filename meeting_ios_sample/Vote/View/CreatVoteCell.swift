//
//  CreatVoteCell.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/2.
//

import UIKit
import SnapKit

protocol CellClickProtocol {
    func removeItem(section: Int , indexPath: NSIndexPath)
}

class CreatVoteCell: UITableViewCell,UITextFieldDelegate{
    var delegate : CellClickProtocol?
    var indexPath : NSIndexPath?
    var voteModel:VoteModel?
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = .white
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.text?.isEmpty != nil else {
            return
        }
        if textField.tag == 0 {
            voteModel!.title = (textField.text! as NSString) as String
        }else{
            let voteQestion : VoteQustionModel = voteModel!.creatquestions![indexPath!.section - 2] as! VoteQustionModel
            let voteOption : VoteOptionModel = voteQestion.itemArray?.object(at: indexPath!.row) as! VoteOptionModel
            voteOption.content = textField.text! as NSString
//            (voteModel!.creatquestio ns![indexPath!.section - 2] as! VoteQustionModel).itemArray!.replaceObject(at: indexPath!.row, with: textField.text! as NSString)
        }
    }
    
    @objc func removeItemClick() {
        delegate?.removeItem(section: self.tag , indexPath: indexPath!)
    }
    
    @objc func anonymousClick() {
        voteModel?.isAnonymous = rightSwitch.isOn ? 1 : 0
    }
    
    func setVoteModel(voteModel : VoteModel) {
        self.voteModel = voteModel
        if indexPath!.section > 1 {
            let voteQustionModel : VoteQustionModel = (voteModel.creatquestions![indexPath!.section - 2]) as! VoteQustionModel
            let voteOption : VoteOptionModel = voteQustionModel.itemArray?.object(at: indexPath!.row) as! VoteOptionModel
            rightItemTextField.text = voteOption.content as String?
        }else{
            rightTitleTextField.text = voteModel.title as String?
            rightSwitch.isOn = ((voteModel.isAnonymous) != 0)
        }
    }
    
    lazy var leftLabel : UILabel = {
        let leftLabel = UILabel.init()
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        leftLabel.textColor = mainBlackColor
        leftLabel.text = "Poll Topic"
        return leftLabel
    }()
    
    lazy var rightTitleTextField : UITextField = {
        let rightTitleTextField = UITextField.init()
        rightTitleTextField.tag = 0;
        rightTitleTextField.delegate = self
        rightTitleTextField.font = UIFont.systemFont(ofSize: 14)
        rightTitleTextField.textColor = mainBlackColor
        rightTitleTextField.placeholder?.write("Input Poll Topic")
        return rightTitleTextField
    }()
    
    lazy var rightItemTextField : UITextField = {
        let rightItemTextField = UITextField.init()
        rightItemTextField.tag = 1;
        rightItemTextField.delegate = self
        rightItemTextField.font = UIFont.systemFont(ofSize: 14)
        rightItemTextField.textColor = mainBlackColor
        return rightItemTextField
    }()
    
    lazy var rightSingleButtonItem : UIButton = {
        let rightSingleButtonItem = UIButton.init()
//        rightSingleButtonItem.addTarget(self, action:#selector(singleClick) , for: .touchUpInside)
        rightSingleButtonItem.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightSingleButtonItem.setTitleColor(.black, for: .normal)
        rightSingleButtonItem.setTitle("single choice", for: .normal)
        rightSingleButtonItem.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -15, bottom: 0, right: 0)
        rightSingleButtonItem.setImage(UIImage.init(named: "meeting_unselect_icon"), for: .normal)
        rightSingleButtonItem.setImage(UIImage.init(named: "meeting_select_icon"), for: .selected)
        rightSingleButtonItem.isSelected = true
        return rightSingleButtonItem
    }()
    
    lazy var rightMultiButtonItem : UIButton = {
        let rightMultiButtonItem = UIButton.init()
//        rightMultiButtonItem.addTarget(self, action:#selector(multiClick) , for: .touchUpInside)
        rightMultiButtonItem.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightMultiButtonItem.setTitleColor(.black, for: .normal)
        rightMultiButtonItem.setTitle("multiple choice", for: .normal)
        rightMultiButtonItem.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -15, bottom: 0, right: 0)
        rightMultiButtonItem.setImage(UIImage.init(named: "meeting_unselect_icon"), for: .normal)
        rightMultiButtonItem.setImage(UIImage.init(named: "meeting_select_icon"), for: .selected)
        return rightMultiButtonItem
    }()
    
    lazy var leftButtonItem : UIButton = {
        let leftButtonItem = UIButton.init()
        leftButtonItem.addTarget(self, action: #selector(removeItemClick), for: .touchUpInside)
        leftButtonItem.setImage(UIImage.init(named: "remove"), for: .normal)
        return leftButtonItem
    }()
    
    lazy var rightSwitch : UISwitch = {
        let rightSwitch = UISwitch.init()
        rightSwitch.addTarget(self, action: #selector(anonymousClick), for: .valueChanged)
        rightSwitch.transform = CGAffineTransform.init(scaleX: 41/rightSwitch.bounds.size.width, y: 24/rightSwitch.bounds.size.height);
        rightSwitch.isOn = false
        return rightSwitch
    }()
    
    lazy var noteLabel : UILabel = {
        let noteLabel = UILabel.init()
        noteLabel.font = UIFont.systemFont(ofSize: 12)
        noteLabel.textColor = .black
        return noteLabel
    }()
    
    lazy var lineView : UIView = {
        let lineView = UIView.init()
        lineView.backgroundColor = klineColor
        return lineView
    }()
}

class VoteTitleCell: CreatVoteCell {
    override func setupViews() {
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightTitleTextField)
//        contentView.addSubview(lineView)
        
        leftLabel.text = "Poll Topic"
        rightTitleTextField.attributedPlaceholder = NSAttributedString.init(string:"Input Poll Topic", attributes: [
                                                                        NSAttributedString.Key.foregroundColor:placeHoldColor])
        
        leftLabel.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalTo(contentView).offset(8)
            mask.bottom.equalTo(contentView).offset(-8)
            mask.height.equalTo(30)
            mask.width.lessThanOrEqualTo(100)
        }
        
        rightTitleTextField.snp.makeConstraints { (mask) in
            mask.left.equalTo(leftLabel.snp.right).offset(15)
            mask.rightMargin.equalTo(-15)
            mask.top.equalTo(contentView).offset(8)
            mask.bottom.equalTo(contentView).offset(-8)
            mask.height.equalTo(30)
        }
        
//        lineView.snp.makeConstraints { (mask) in
//            mask.leftMargin.equalTo(0)
//            mask.rightMargin.equalTo(0)
//            mask.bottom.equalTo(contentView).offset(-1)
//            mask.height.equalTo(0.8)
//        }
        
    }
}

class VoteDescriptionCell: CreatVoteCell {
    override func setupViews() {
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightItemTextField)
        contentView.addSubview(lineView)
        
        leftLabel.text = "descriptions"
        rightItemTextField.attributedPlaceholder = NSAttributedString.init(string:"input descriptions（choose）", attributes: [
                                                                        NSAttributedString.Key.foregroundColor:placeHoldColor])
        
        leftLabel.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalTo(contentView).offset(8)
            mask.bottom.equalTo(contentView).offset(-8)
            mask.height.equalTo(30)
            mask.width.lessThanOrEqualTo(100)
        }
        
        rightItemTextField.snp.makeConstraints { (mask) in
            mask.left.equalTo(leftLabel.snp.right).offset(15)
            mask.rightMargin.equalTo(-15)
            mask.top.equalTo(contentView).offset(8)
            mask.bottom.equalTo(contentView).offset(-8)
            mask.height.equalTo(30)
        }
        
        lineView.snp.makeConstraints { (mask) in
            mask.leftMargin.equalTo(0)
            mask.rightMargin.equalTo(0)
            mask.bottom.equalTo(contentView).offset(-1)
            mask.height.equalTo(0.8)
        }
    }
}

class VoteItemTypeCell: CreatVoteCell {
    override func setupViews() {
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightSingleButtonItem)
        contentView.addSubview(rightMultiButtonItem)
        contentView.addSubview(lineView)
        
        leftLabel.text = "Option types"
        
        leftLabel.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalTo(contentView).offset(8)
            mask.bottom.equalTo(contentView).offset(-8)
            mask.height.equalTo(30)
            mask.width.lessThanOrEqualTo(100)
        }
        
        rightSingleButtonItem.snp.makeConstraints { (mask) in
            mask.left.equalTo(leftLabel.snp.right).offset(30)
            mask.centerY.equalTo(leftLabel)
        }
        
        rightMultiButtonItem.snp.makeConstraints { (mask) in
            mask.left.equalTo(rightSingleButtonItem.snp.right).offset(50)
            mask.centerY.equalTo(leftLabel)
            
        }
        
        lineView.snp.makeConstraints { (mask) in
            mask.leftMargin.equalTo(0)
            mask.rightMargin.equalTo(0)
            mask.bottom.equalTo(contentView).offset(-1)
            mask.height.equalTo(0.8)
        }
    }
}

class VoteItemCell: CreatVoteCell {
    override func setupViews() {
        contentView.addSubview(leftButtonItem)
        contentView.addSubview(rightItemTextField)
        contentView.addSubview(lineView)
        
        rightItemTextField.attributedPlaceholder = NSAttributedString.init(string:"option", attributes: [
                                                                            NSAttributedString.Key.foregroundColor:HEXColor(h: 0x999999)])
        leftButtonItem.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalTo(contentView).offset(8)
            mask.bottom.equalTo(contentView).offset(-8)
            mask.size.equalTo(CGSize.init(width: 30, height: 30))
        }
        
        rightItemTextField.snp.makeConstraints { (mask) in
            mask.left.equalTo(leftButtonItem.snp.right).offset(15)
            mask.rightMargin.equalTo(15)
            mask.top.equalTo(contentView).offset(8)
            mask.bottom.equalTo(contentView).offset(-8)
            mask.height.equalTo(30)
        }
        
        lineView.snp.makeConstraints { (mask) in
            mask.leftMargin.equalTo(0)
            mask.rightMargin.equalTo(0)
            mask.bottom.equalTo(contentView).offset(-1)
            mask.height.equalTo(0.8)
        }
    
    }
}

class VoteAnonymousCell: CreatVoteCell {
    override func setupViews() {
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightSwitch)
       
        leftLabel.text = "anonymousVote"
        
        leftLabel.snp.makeConstraints { (mask) in
            mask.left.equalTo(contentView).offset(15)
            mask.top.equalTo(contentView).offset(8)
            mask.bottom.equalTo(contentView).offset(-8)
            mask.height.equalTo(30)
        }
        
        rightSwitch.snp.makeConstraints { (mask) in
            mask.rightMargin.equalTo(-5)
            mask.centerY.equalTo(leftLabel)
        }
        
    }
}
