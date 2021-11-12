//
//  CreatVoteHeaderView.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/5.
//

import UIKit

protocol HeaderClickProtocol {
    func removeQustion(section: Int)
//    func voteTypeSelect(section: Int,selectType:Int)
}

class CreatVoteHeaderView: UIView , UITextFieldDelegate{
    
    var delegate : HeaderClickProtocol?
    var rightSingleButtonItem : UIButton!
    var rightMultiButtonItem : UIButton!
    var qustionTextField : UITextField!
    var voteModel:VoteModel?
    init(frame: CGRect , voteModel:VoteModel ,section:Int) {
        self.voteModel = voteModel
        super.init(frame: frame)
        self.backgroundColor = .white
        //1.问题:请输入问题
        
        let toplineView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 10))
        toplineView.backgroundColor = klineColor
        
        let centerlineView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 61, width: screenWidth, height: 1))
        centerlineView.backgroundColor = klineColor
        
        let bottomlineView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 111, width: screenWidth, height: 1))
        bottomlineView.backgroundColor = klineColor
 
        let qustionLabel : UILabel = UILabel.init(frame: CGRect.init(x: 15, y: 20, width: 80, height: 30))
        qustionLabel.font = UIFont.systemFont(ofSize: 14)
        qustionLabel.text = "Question" + String(section - 1)
        qustionLabel.textColor = mainBlackColor
        
        qustionTextField = UITextField.init(frame: CGRect.init(x: 90, y: 20, width: screenWidth - 180, height: 30))
        qustionTextField.delegate = self
        qustionTextField.attributedPlaceholder = NSAttributedString.init(string:"Input Questions", attributes: [
                                                                        NSAttributedString.Key.foregroundColor:placeHoldColor])
        qustionTextField.font = UIFont.systemFont(ofSize: 14)
        qustionTextField.textColor = mainBlackColor
        
        let deleteQustionButton : UIButton = UIButton.init(frame: CGRect.init(x: screenWidth - 40, y: 20, width: 30, height: 30))
        deleteQustionButton.addTarget(self, action: #selector(removeQustionClick), for: .touchUpInside)
        deleteQustionButton .setImage(UIImage.init(named: "remove"), for: .normal)
        
        let leftLabel = UILabel.init(frame: CGRect.init(x: 15, y: 71, width: 100, height: 30))
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        leftLabel.textColor = mainBlackColor
        leftLabel.text = "Option types"
        
        rightSingleButtonItem = UIButton.init(frame: CGRect.init(x: 120, y: 71, width: 80, height: 30))
        rightSingleButtonItem.addTarget(self, action:#selector(singleClick) , for: .touchUpInside)
        rightSingleButtonItem.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightSingleButtonItem.setTitleColor(.black, for: .normal)
        rightSingleButtonItem.setTitle("single choice", for: .normal)
        rightSingleButtonItem.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -15, bottom: 0, right: 0)
        rightSingleButtonItem.setImage(UIImage.init(named: "meeting_unselect_icon"), for: .normal)
        rightSingleButtonItem.setImage(UIImage.init(named: "meeting_select_icon"), for: .selected)
        rightSingleButtonItem.isSelected = true
        
        rightMultiButtonItem = UIButton.init(frame: CGRect.init(x: 220, y: 71, width: 80, height: 30))
        rightMultiButtonItem.addTarget(self, action:#selector(multiClick) , for: .touchUpInside)
        rightMultiButtonItem.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightMultiButtonItem.setTitleColor(.black, for: .normal)
        rightMultiButtonItem.setTitle("multiple choice", for: .normal)
        rightMultiButtonItem.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -15, bottom: 0, right: 0)
        rightMultiButtonItem.setImage(UIImage.init(named: "meeting_unselect_icon"), for: .normal)
        rightMultiButtonItem.setImage(UIImage.init(named: "meeting_select_icon"), for: .selected)
        
        
        self.addSubview(toplineView)
        self.addSubview(qustionLabel)
        self.addSubview(qustionTextField)
        if voteModel.creatquestions!.count  > 1 {
            self.addSubview(deleteQustionButton)
        }
        self.addSubview(leftLabel)
        self.addSubview(rightSingleButtonItem)
        self.addSubview(rightMultiButtonItem)
        self.addSubview(centerlineView)
        self.addSubview(bottomlineView)
    }
   
    
    
    @objc func removeQustionClick() {
        delegate?.removeQustion(section: self.tag)
    }
    
    @objc func singleClick() {
//        delegate?.voteTypeSelect(section: self.tag, selectType: 0)
        rightSingleButtonItem.isSelected = true
        rightMultiButtonItem.isSelected = false
        let voteQustionModel : VoteQustionModel = (voteModel?.creatquestions![self.tag - 10002]) as! VoteQustionModel
        voteQustionModel.isSingle = 1
    }
    
    @objc func multiClick() {
//        delegate?.voteTypeSelect(section: self.tag, selectType: 0)
        rightSingleButtonItem.isSelected = false
        rightMultiButtonItem.isSelected = true
        let voteQustionModel : VoteQustionModel = (voteModel?.creatquestions![self.tag - 10002]) as! VoteQustionModel
        voteQustionModel.isSingle = 0
    }
    
    func setVoteModel(voteModel : VoteModel) {
        self.voteModel = voteModel
        let voteQustionModel : VoteQustionModel = (voteModel.creatquestions![self.tag - 10002]) as! VoteQustionModel
        rightSingleButtonItem.isSelected = voteQustionModel.isSingle == 1
        rightMultiButtonItem.isSelected = voteQustionModel.isSingle == 0
        qustionTextField.text = voteQustionModel.content as String?
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.text?.isEmpty != nil else {
            return
        }
        let voteQustionModel : VoteQustionModel = (voteModel!.creatquestions![self.tag - 10002]) as! VoteQustionModel
        voteQustionModel.content = textField.text as NSString?
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
