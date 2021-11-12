//
//  VoteResultView.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/3.
//

import UIKit

protocol reloadViewProtocol {
    func reloadView()
}

class VoteResultView: UIView , UITableViewDelegate,UITableViewDataSource{
    var delegate : reloadViewProtocol?
    var voteTitleLabel : UILabel?
    var voteTagLabel : UILabel?
    var voteTitleHeight : CGFloat = 0;
    var is_mainUser : Bool = true
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(lineView)
        self.addSubview(tableView)
    }

    
    @objc func stopVoteClick(){//终止投票
        let alertController = UIAlertController(title: "Terminate Title",
                                                message: "terminated text", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            //终止投票成功后将按钮变成公布投票
            let parameterDic : NSDictionary = ["id":self.voteModel!.id]
            print("parameterDic = \(parameterDic)")
            MeetingAPIRequest.meetingPollStop(poll_id: Int(self.voteModel!.id)!) {[weak self] response in
                if response != nil {
                    let voteModel = self!.voteModel
                    voteModel?.status = 2
                    voteModel?.is_publishing = 0
                    self!.voteModel = voteModel
                    SampleMeetingManager.defaultManager().hostSendCustomControlMessageToRoom(["poll_id": voteModel!.id], subType: "poll_stop")
                }
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.viewForController(view: self)?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func publishVoteClick(){//公布结果
        //终止投票成功后将按钮变成公布投票
        let parameterDic : NSDictionary = ["id":voteModel!.id,"share":true]
        print("parameterDic = \(parameterDic)")
        MeetingAPIRequest.meetingPollShare(poll_id: Int(voteModel!.id)!, share: true) { [weak self] response in
            if response != nil {
                self!.voteStopButton.setTitle("stop publishing", for: .normal)
                self!.voteModel!.is_publishing = 1
                self!.voteStopButton.removeTarget(self!, action: #selector(self!.publishVoteClick), for: .touchUpInside)
                self!.voteStopButton.addTarget(self!, action: #selector(self!.stopPublishVoteClick), for: .touchUpInside)
                SampleMeetingManager.defaultManager().hostSendCustomControlMessageToRoom(["poll_id": (self?.voteModel!.id)! as String], subType: "poll_publishResult")
            }
        }
    }
    
    @objc func stopPublishVoteClick(){//停止公布结果
        //终止投票成功后将按钮变成公布投票
        let parameterDic : NSDictionary = ["id":voteModel!.id,"share":false]
        print("parameterDic = \(parameterDic)")
        MeetingAPIRequest.meetingPollShare(poll_id: Int(voteModel!.id)!, share: false) {[weak self] response in
            if response != nil {
                self!.voteStopButton.setTitle("publish", for: .normal)
                self!.voteModel!.is_publishing = 0
                self!.voteStopButton.removeTarget(self!, action: #selector(self!.stopVoteClick), for: .touchUpInside)
                self!.voteStopButton.removeTarget(self!, action: #selector(self!.stopPublishVoteClick), for: .touchUpInside)
                self!.voteStopButton.addTarget(self!, action: #selector(self!.publishVoteClick), for: .touchUpInside)
                //发送停止公布结果消息
                SampleMeetingManager.defaultManager().hostSendCustomControlMessageToRoom(["poll_id": (self?.voteModel!.id)! as String], subType: "poll_stopPublishResult")
            }
        }
    }
    
    @objc func editVoteClick(){//重新编辑投票
        let creatVoteVC = CreatVoteController()
        creatVoteVC.voteModel = self.voteModel
        for voteQuestion : VoteQustionModel in creatVoteVC.voteModel!.questions! as [VoteQustionModel] {
            voteQuestion.itemArray = NSMutableArray.init(array: voteQuestion.options)
        }
        creatVoteVC.voteModel?.creatquestions = NSMutableArray.init(array: creatVoteVC.voteModel!.questions! as [VoteQustionModel])
        creatVoteVC.isUpdate = true
        NotificationCenter.default.removeObserver(self.viewForController(view: self)!)
        self.viewForController(view: self)?.navigationController?.pushViewController(creatVoteVC, animated: true)
    }
    
    @objc func reVoteClick(){//重新投票
        let alertController = UIAlertController(title: "Tip",
                                                message: "relaunch Text", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            let parameterDic : NSDictionary = ["id":self.voteModel!.id ,"room_id":self.voteModel!.room_id ?? "","title":self.voteModel!.title ,"round":"0","status":"0","is_anonymous":self.voteModel!.isAnonymous]
            print("parameterDic = \(parameterDic)")
            MeetingAPIRequest.meetingPollStart(poll_id: Int(self.voteModel!.id)!) {[weak self] response in
                if response != nil {
                    self!.tableView.snp.remakeConstraints { (make) in
                        make.bottom.equalTo(self!.snp.bottom).offset(-SafeArea_BottomHeight - 10)
                    }
                    self!.voteStopButton.setTitle("terminate voting", for: .normal)
                    self!.voteModel!.is_publishing = 0
                    self!.voteStopButton.removeTarget(self, action: #selector(self!.publishVoteClick), for: .touchUpInside)
                    self!.voteStopButton.removeTarget(self, action: #selector(self!.stopPublishVoteClick), for: .touchUpInside)
                    self!.voteStopButton.removeTarget(self, action: #selector(self!.stopVoteClick), for: .touchUpInside)
                    self!.voteStopButton.addTarget(self, action: #selector(self!.stopVoteClick), for: .touchUpInside)
                    self!.reEditButton.removeFromSuperview()
                    self!.relaunchButton.removeFromSuperview()
                    self!.delegate?.reloadView()
                    SampleMeetingManager.defaultManager().hostSendCustomControlMessageToRoom(["poll_id": self!.voteModel!.id as String], subType: "poll_start")
                }
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.viewForController(view: self)?.present(alertController, animated: true, completion: nil)
    }
    
 
    var voteModel : VoteModel?{
        didSet{
            guard voteModel != nil else { return }
            voteTitleHeight = heightForView(text: voteModel!.title, font: UIFont.boldSystemFont(ofSize: 14), width: screenWidth - 80.0)
            if self.voteTitleHeight < 25 {
                self.voteTitleHeight = 25
            }
            voteHeaderView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: voteTitleHeight + 20)
            self.voteTitleLabel?.text = voteModel?.title
            self.voteTagLabel?.text = voteModel!.isAnonymous > 0 ? "anonymous" : "unanonymous"
            self.tableView.tableHeaderView = voteHeaderView
            self.tableView.reloadData()
            if self.is_mainUser {
                if voteModel?.status == 1 {
                    self.addSubview(voteStopButton)
                    voteStopButton.setTitle("terminate voting", for: .normal)
                    voteStopButton.snp.makeConstraints { (make) in
                        make.top.equalTo(tableView.snp.bottom).offset(10)
                        make.leftMargin.equalTo(30)
                        make.rightMargin.equalTo(-30)
                        make.height.equalTo(40)
                    }
                }else{
                    voteStopButton.removeFromSuperview()
                    self.addSubview(voteStopButton)
                    self.addSubview(reEditButton)
                    self.addSubview(relaunchButton)
                    
                    tableView.snp.remakeConstraints { (make) in
                        make.bottom.equalTo(self.snp.bottom).offset(-TabBar_Height - 100)
                    }
                    tableView.snp.makeConstraints { (make) in
                        make.top.equalTo(lineView.snp.bottom).offset(10)
                        make.left.right.equalTo(self)
                        make.bottom.equalTo(self.snp.bottom).offset(-TabBar_Height - 100)
                    }
                    
                    voteStopButton.snp.makeConstraints { (make) in
                        make.top.equalTo(tableView.snp.bottom).offset(10)
                        make.leftMargin.equalTo(30)
                        make.rightMargin.equalTo(-30)
                        make.height.equalTo(40)
                    }
                    
                    reEditButton.snp.makeConstraints { (make) in
                        make.top.equalTo(voteStopButton.snp.bottom).offset(10)
                        make.leftMargin.equalTo(30)
                        make.rightMargin.equalTo(-30)
                        make.height.equalTo(40)
                    }
                    
                    relaunchButton.snp.makeConstraints { (make) in
                        make.top.equalTo(reEditButton.snp.bottom).offset(10)
                        make.leftMargin.equalTo(30)
                        make.rightMargin.equalTo(-30)
                        make.height.equalTo(40)
                    }
                    
                    if voteModel?.is_publishing == 1{
                        voteStopButton.setTitle("stop publishing", for: .normal)
                        voteStopButton.removeTarget(self, action: #selector(stopVoteClick), for: .touchUpInside)
                        voteStopButton.addTarget(self, action: #selector(stopPublishVoteClick), for: .touchUpInside)
                    }else{
                        voteStopButton.setTitle("publish", for: .normal)
                        voteStopButton.removeTarget(self, action: #selector(stopVoteClick), for: .touchUpInside)
                        voteStopButton.addTarget(self, action: #selector(publishVoteClick), for: .touchUpInside)
                    }
                   
                }
            }else{
                tableView.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self.snp.bottom).offset(-SafeArea_BottomHeight - 10)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
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
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if voteModel == nil {
            return 0
        }
        return voteModel!.questions!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let qustionModel : VoteQustionModel = (voteModel?.questions![section])! as VoteQustionModel
        return qustionModel.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let voteResultCell = tableView.dequeueReusableCell(withIdentifier: "voteResultCell") as! VoteResultCell
        voteResultCell.indexPath = indexPath as NSIndexPath
        voteResultCell.model = voteModel
        voteResultCell.setNeedsDisplay()
        return voteResultCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let qustionModel : VoteQustionModel = (voteModel?.questions![section])! as VoteQustionModel
        //获取label高度
        let contentHeight = heightForView(text: "Question" + String(section + 1) + ":" + (qustionModel.content! as String), font: UIFont.boldSystemFont(ofSize: 14), width: screenWidth - 30.0)
        let qustionView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Int(screenWidth), height: Int(contentHeight) + 20))
        qustionView.backgroundColor = .white
        let qustionLabel : UILabel = UILabel.init(frame: CGRect.init(x: 15, y: 10, width:screenWidth - 30, height: contentHeight))
        qustionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        qustionLabel.numberOfLines = 0
        qustionView .addSubview(qustionLabel)
        qustionLabel.textColor = mainBlackColor
        qustionLabel.text = "Question" + String(section + 1) + ":" + (qustionModel.content! as String)
        return qustionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //获取label高度
        let qustionModel : VoteQustionModel = (voteModel?.questions![section])! as VoteQustionModel
        let contentHeight = heightForView(text: "Question" + String(section + 1) + ":" + (qustionModel.content! as String), font: UIFont.boldSystemFont(ofSize: 14), width: screenWidth - 30.0)
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
        
        voteTagLabel = UILabel.init(frame: CGRect.init(x: screenWidth - 110, y: 10, width: 100, height:20))
        voteTagLabel!.textColor = mainBlackColor
        voteTagLabel!.font = UIFont.systemFont(ofSize: 12)
        voteTagLabel!.textAlignment = .center
        voteTagLabel!.layer.borderWidth = 1
        voteTagLabel!.layer.borderColor = mainColor.cgColor
        voteTagLabel!.layer.cornerRadius = 2
        voteTagLabel!.layer.masksToBounds = true
        
        voteHeaderView.addSubview(voteTitleLabel!)
        voteHeaderView.addSubview(voteTagLabel!)
        return voteHeaderView
    }()

    private lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: .zero,style: .grouped)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.register(VoteResultCell.classForCoder(), forCellReuseIdentifier: "voteResultCell")
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    private lazy var voteStopButton : UIButton = {
        let voteStopButton = UIButton.init(frame: .zero)
        voteStopButton.addTarget(self, action: #selector(stopVoteClick) , for: .touchUpInside)
        voteStopButton.backgroundColor = mainColor
        voteStopButton.setTitle("Terminate Voting", for: .normal)
        voteStopButton.setTitleColor(.white, for: .normal)
        voteStopButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        voteStopButton.layer.borderWidth = 1
        voteStopButton.layer.borderColor = klineColor.cgColor
        voteStopButton.layer.cornerRadius = 4
        voteStopButton.layer.masksToBounds = true
        return voteStopButton
    }()
    
    private lazy var reEditButton : UIButton = {
        let reEditButton = UIButton.init(frame: .zero)
        reEditButton.addTarget(self, action: #selector(editVoteClick) , for: .touchUpInside)
        reEditButton.backgroundColor = .white
        reEditButton.setTitle("Edit Poll", for: .normal)
        reEditButton.setTitleColor(mainColor, for: .normal)
        reEditButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        reEditButton.layer.borderWidth = 1
        reEditButton.layer.borderColor = klineColor.cgColor
        reEditButton.layer.cornerRadius = 4
        reEditButton.layer.masksToBounds = true
        return reEditButton
    }()

    
    private lazy var relaunchButton : UIButton = {
        let relaunchButton = UIButton.init(frame: .zero)
        relaunchButton.addTarget(self, action: #selector(reVoteClick) , for: .touchUpInside)
        relaunchButton.backgroundColor = .white
        relaunchButton.setTitle("Pool Again", for: .normal)
        relaunchButton.setTitleColor(.red, for: .normal)
        relaunchButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        relaunchButton.layer.borderWidth = 1
        relaunchButton.layer.borderColor = klineColor.cgColor
        relaunchButton.layer.cornerRadius = 4
        relaunchButton.layer.masksToBounds = true
        return relaunchButton
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
