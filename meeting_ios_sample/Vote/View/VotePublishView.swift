//
//  VotePublishView.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/9.
//

import UIKit

class VotePublishView: UIView , UITableViewDelegate , UITableViewDataSource{
    
    var voteTitleLabel : UILabel?
    var voteTagLabel : UILabel!
    var voteTitleHeight : CGFloat = 0;
    var room_id : NSString?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(lineView)
        self.addSubview(tableView)
        self.addSubview(votePublishButton)
        self.addSubview(voteEditButton)
        self.addSubview(voteDelButton)
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
            make.bottom.equalTo(self.snp.bottom).offset(-TabBar_Height - 100)
        }

        votePublishButton.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.leftMargin.equalTo(30)
            make.rightMargin.equalTo(-30)
            make.height.equalTo(40)
        }
        
        voteEditButton.snp.makeConstraints { (make) in
            make.top.equalTo(votePublishButton.snp.bottom).offset(10)
            make.leftMargin.equalTo(30)
            make.rightMargin.equalTo(-30)
            make.height.equalTo(40)
        }
        
        voteDelButton.snp.makeConstraints { (make) in
            make.top.equalTo(voteEditButton.snp.bottom).offset(10)
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

    @objc func startVoteClick() {
        let parameterDic : NSDictionary = ["id":voteModel!.id]
        print("parameterDic = \(parameterDic)")
        MeetingAPIRequest.meetingPollStart(poll_id: Int(voteModel!.id)!) {[weak self] response in
            if response != nil {
                let voteListItemModel:VoteModelListItem = VoteModelListItem.deserialize(from: (response as! [String : Any]))!
                SampleMeetingManager.defaultManager().hostSendCustomControlMessageToRoom(["poll_id" : self!.voteModel!.id as String], subType: "poll_start")
                let voteResultVC : VoteResultController = VoteResultController()
                voteResultVC.voteId = voteListItemModel.id! as NSString
                voteResultVC.is_pulishing = "0"
                voteResultVC.is_mainUser = "1"
                self!.viewForController(view: self!)?.navigationController?.pushViewController(voteResultVC, animated: true)
            }
        }
    }
    
    @objc func editVoteClick() {
        let creatVoteVC = CreatVoteController()
        creatVoteVC.voteModel = self.voteModel
        for voteQuestion : VoteQustionModel in creatVoteVC.voteModel!.questions! as [VoteQustionModel] {
            voteQuestion.itemArray = NSMutableArray.init(array: voteQuestion.options)
        }
        creatVoteVC.voteModel?.creatquestions = NSMutableArray.init(array: creatVoteVC.voteModel!.questions! as [VoteQustionModel])
        creatVoteVC.isUpdate = true
        self.viewForController(view: self)?.navigationController?.pushViewController(creatVoteVC, animated: true)
    }
    
    @objc func delVoteClick() {
        let alertController = UIAlertController(title: "Tip",
                                                message: "delete Poll Confirm", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            let parameterDic : NSDictionary = ["id":self.voteModel?.id ?? ""]
            print("parameterDic = \(parameterDic)")
            MeetingAPIRequest.meetingPollDel(poll_id: Int(self.voteModel!.id) ?? 0) {[weak self] response in
                if response != nil {
                    SampleMeetingManager.defaultManager().hostSendCustomControlMessageToRoom(["poll_id" : self!.voteModel!.id as String], subType: "poll_del")
                    let mineVC = VoteListViewController()
                    var targetVC : UIViewController!
                    for  controller in self!.viewForController(view: self!)!.navigationController!.viewControllers {
                        if controller.isKind(of: mineVC.classForCoder) {
                            targetVC = controller
                        }
                    }
                    if targetVC != nil {
                        NotificationCenter.default.removeObserver(self!)
                        self!.viewForController(view: self!)?.navigationController?.popToViewController(targetVC, animated: true)
                    }
                }
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.viewForController(view: self)?.present(alertController, animated: true, completion: nil)
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

    private lazy var votePublishButton : UIButton = {
        let voteButton = UIButton.init(frame: .zero)
        voteButton.addTarget(self, action: #selector(startVoteClick) , for: .touchUpInside)
        voteButton.backgroundColor = mainColor
        voteButton.setTitle("Publish Poll", for: .normal)
        voteButton.setTitleColor(.white, for: .normal)
        voteButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        voteButton.layer.cornerRadius = 4
        voteButton.layer.masksToBounds = true
        return voteButton
    }()
    
    private lazy var voteEditButton : UIButton = {
        let voteEditButton = UIButton.init(frame: .zero)
        voteEditButton.addTarget(self, action: #selector(editVoteClick) , for: .touchUpInside)
        voteEditButton.backgroundColor = .white
        voteEditButton.setTitle("Edit Poll", for: .normal)
        voteEditButton.setTitleColor(mainColor, for: .normal)
        voteEditButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        voteEditButton.layer.borderWidth = 1
        voteEditButton.layer.borderColor = klineColor.cgColor
        voteEditButton.layer.cornerRadius = 4
        voteEditButton.layer.masksToBounds = true
        return voteEditButton
    }()
    
    private lazy var voteDelButton : UIButton = {
        let voteDelButton = UIButton.init(frame: .zero)
        voteDelButton.addTarget(self, action: #selector(delVoteClick) , for: .touchUpInside)
        voteDelButton.backgroundColor = .white
        voteDelButton.setTitle("Delete Poll", for: .normal)
        voteDelButton.setTitleColor(.red, for: .normal)
        voteDelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        voteDelButton.layer.borderWidth = 1
        voteDelButton.layer.borderColor = klineColor.cgColor
        voteDelButton.layer.cornerRadius = 4
        voteDelButton.layer.masksToBounds = true
        return voteDelButton
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
