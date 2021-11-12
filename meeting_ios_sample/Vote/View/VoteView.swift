//
//  VoteView.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/3.
//

import UIKit
import YYKit

class VoteView: UIView , UITableViewDelegate , UITableViewDataSource{
    var voteTitleLabel : UILabel?
    var voteTagLabel : UILabel!
    var voteTitleHeight : CGFloat = 0;
    var room_id : NSString?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(lineView)
        self.addSubview(tableView)
        self.addSubview(voteCommitButton)
        self.setUpView()
    }
    
    func setUpView() {
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaInsets.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(0)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(-TabBar_Height)
        }

        voteCommitButton.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.leftMargin.equalTo(30)
            make.rightMargin.equalTo(-30)
            make.height.equalTo(40)
        }
        
        voteTitleLabel?.frame = CGRect.init(x: 15, y: 10, width: screenWidth - 100, height:voteTitleHeight)
        voteTagLabel?.frame = CGRect.init(x: screenWidth - 60, y: 10, width: 50, height:20)
    }
    
    var voteModel : VoteModel?{
        didSet{
            guard voteModel != nil else { return }
            voteTitleHeight = heightForView(text: voteModel!.title as String, font: UIFont.boldSystemFont(ofSize: 15), width: screenWidth - 100)
            
            if self.voteTitleHeight < 25 {
                self.voteTitleHeight = 25
            }
            
            voteHeaderView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: voteTitleHeight + 20)
            self.voteTitleLabel?.text = voteModel?.title
            self.voteTagLabel?.text = voteModel!.isAnonymous > 0 ? "anonymous" : "unanonymous"
            self.tableView.tableHeaderView = voteHeaderView
            self.tableView.reloadData()
            
        }
    }
    
    @objc func commitVoteClick() {
        let parameterDic : NSMutableDictionary = NSMutableDictionary.init(dictionary: ["poll_id":voteModel?.id ?? ""])
        
        let qestionArray : NSMutableArray = NSMutableArray.init()
       
        for voteqestion : VoteQustionModel in voteModel!.questions! as [VoteQustionModel]{
            let qestionDic : NSMutableDictionary = NSMutableDictionary.init()
            qestionDic .setValue(voteqestion.id!, forKey: "id")
            let optionArray : NSMutableArray = NSMutableArray.init()
            if voteqestion.optionArray?.count == 0 {
                debugPrint("There are still unanswered poll")
                return
            }
            for voteOptionId : NSString in voteqestion.optionArray as! [NSString] {
                optionArray .add(["id":voteOptionId])
            }
            qestionDic .setObject(optionArray, forKey:"options" as NSCopying)
            qestionArray .add(qestionDic)
        }
        parameterDic .setObject(qestionArray, forKey: "questions" as NSCopying)
        print("parameterDic = \(parameterDic)")
        MeetingAPIRequest.meetingPollCommit(poll_id: parameterDic["id"] as! Int, questions: parameterDic["questions"] as! Array<Int>) {[weak self] response in
            if response != nil {
                let userResultVC = UserResultController()
                userResultVC.voteId = self!.voteModel!.id as NSString
                SampleMeetingManager.defaultManager().hostSendCustomControlMessageToRoom(parameterDic as! Dictionary<AnyHashable, Any>, subType: "poll_commit")
                self!.viewForController(view: self!)?.navigationController!.pushViewController(userResultVC, animated: true)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if voteModel == nil {
            return 0
        }else{
            return (voteModel?.questions?.count)! as Int
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let votequstionModel : VoteQustionModel = (voteModel?.questions![section])!
        return votequstionModel.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let voteqestion : VoteQustionModel = voteModel!.questions![indexPath.section]
        let voteoption : VoteOptionModel = voteqestion.options[indexPath.row]
        voteoption.is_single = voteqestion.isSingle
        voteoption.is_select = false
        for optionId : NSString in voteqestion.optionArray! as! [NSString] {
            if optionId.intValue == voteoption.id!.intValue{
                voteoption.is_select = true
                break
            }
        }
        let voteCell = tableView.dequeueReusableCell(withIdentifier: "voteCell") as! VoteCell
        voteCell.indexPath = indexPath as NSIndexPath
        voteCell.voteOption = voteoption
        return voteCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //获取label高度
        let voteqestion : VoteQustionModel = voteModel!.questions![section]
        let contentHeight = heightForView(text: "Question" + String(section + 1) + ":" + (voteqestion.content! as String), font: UIFont.systemFont(ofSize: 14), width: screenWidth - 30.0)
        let qustionView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Int(screenWidth), height: Int(contentHeight) + 20))
        qustionView.backgroundColor = .white
        let qustionLabel : UILabel = UILabel.init(frame: CGRect.init(x: 15, y: 10, width:screenWidth - 30, height: contentHeight))
        qustionLabel.font = UIFont.systemFont(ofSize: 14)
        qustionLabel.textColor = mainBlackColor
        qustionLabel.numberOfLines = 0
        qustionView .addSubview(qustionLabel)
        qustionLabel.text = "Question" + String(section + 1) + ":" + (voteqestion.content! as String)
        return qustionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //获取label高度
        let voteqestion : VoteQustionModel = voteModel!.questions![section]
        let contentHeight = heightForView(text: "Question" + String(section + 1) + ":" + (voteqestion.content! as String), font: UIFont.systemFont(ofSize: 14), width: screenWidth - 30.0)
        return contentHeight + 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Int(screenWidth), height: 1))
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //判断多选和单选
        //多选是有正选和反选  修改model 刷新view
        //单选没有反选 修改model 刷新view
        let voteqestion : VoteQustionModel = voteModel!.questions![indexPath.section]
        let voteoption : VoteOptionModel = voteqestion.options[indexPath.row]
        if voteqestion.isSingle == 1 { //单选
            voteqestion.optionArray?.removeAllObjects()
            voteqestion.optionArray?.add(voteoption.id! as String)
        }else{ //多选
            if ((voteqestion.optionArray?.contains(voteoption.id! as String)) == true) {
                voteqestion.optionArray?.remove(voteoption.id! as String)
            }else{
                voteqestion.optionArray?.add(voteoption.id! as String)
            }
        }
        self.tableView .reloadSections(NSIndexSet.init(index: indexPath.section) as IndexSet, with: .fade)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.font = font
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }

    private lazy var voteHeaderView : UIView = {
        let voteHeaderView : UIView = UIView.init(frame: CGRect.zero)
        voteHeaderView.backgroundColor = .white
        voteTitleLabel = UILabel.init(frame: CGRect.init(x: 15, y: 10, width: screenWidth - 100, height:voteTitleHeight))
        voteTitleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        voteTitleLabel!.numberOfLines = 0
        voteTitleLabel?.textColor = mainBlackColor
        
        voteTagLabel = UILabel.init(frame: CGRect.init(x: screenWidth - 60, y: 10, width: 50, height:20))
        voteTagLabel.textColor = mainBlackColor
        voteTagLabel.font = UIFont.systemFont(ofSize: 12)
        voteTagLabel.textAlignment = .center
        voteTagLabel.layer.borderWidth = 1
        voteTagLabel.layer.borderColor = mainColor.cgColor
        voteTagLabel.layer.cornerRadius = 2
        voteTagLabel.layer.masksToBounds = true
        
        voteHeaderView.addSubview(voteTitleLabel!)
        voteHeaderView.addSubview(voteTagLabel)
        return voteHeaderView
    }()

    private lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: .zero,style: .grouped)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.register(VoteCell.classForCoder(), forCellReuseIdentifier: "voteCell")
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    private lazy var voteCommitButton : UIButton = {
        let voteCommitButton = UIButton.init(frame: .zero)
        voteCommitButton.addTarget(self, action: #selector(commitVoteClick) , for: .touchUpInside)
        voteCommitButton.backgroundColor = mainColor
        voteCommitButton.setTitle("Submit Poll", for: .normal)
        voteCommitButton.setTitleColor(.white, for: .normal)
        voteCommitButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        voteCommitButton.layer.cornerRadius = 4
        voteCommitButton.layer.masksToBounds = true
        return voteCommitButton
    }()

    lazy var lineView : UIView = {
        let lineView = UIView.init()
        lineView.backgroundColor = klineColor
        return lineView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func viewForController(view:UIView)->UIViewController?{
        var next:UIView? = view
        repeat{
            if let nextResponder = next?.next, nextResponder is UIViewController {
                return (nextResponder as! UIViewController)
            }
            next = next?.superview
        }while next != nil
        return nil
    }
}

