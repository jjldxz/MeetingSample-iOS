//
//  CreatVoteController.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/2.
//

import UIKit

class CreatVoteController: UIViewController {
    var voteModel : VoteModel?
    var isUpdate : Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Poll"
        self.view.backgroundColor = .white
        if self.voteModel == nil {
            self.voteModel = VoteModel()
        }
        
        self.view.addSubview(creatVoteView)
        self.addNavButton()
        creatVoteView.snp.makeConstraints{(make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view).offset(NaviBar_Height)
        }
        
        
    }
    
    @objc func publishVote() {
        self.creatVoteView.endEditing(true)
  
        guard voteModel!.title.isEmpty == false else {
            debugPrint("[vote error] inputPollTopic")
            return
        }

        for qustion : VoteQustionModel in voteModel!.creatquestions as! [VoteQustionModel]{
            var count = 0
            for qustionTitle : VoteOptionModel in qustion.itemArray as! [VoteOptionModel] {
                if qustionTitle.content!.length > 0 {
                    count += 1
                }
            }
            guard count > 1 else {
                debugPrint("[vote error] Make sure there are more than two options for each question")
                return
            }
        }
   
        let quetionArray : NSMutableArray = NSMutableArray.init()
        for qustion : VoteQustionModel in voteModel!.creatquestions as! [VoteQustionModel]{
            let optionsArray : NSMutableArray = NSMutableArray.init()
            for voteOption : VoteOptionModel in qustion.itemArray as! [VoteOptionModel] {
                if voteOption.content!.length > 0{
                    let dic = ["content":voteOption.content]
                    optionsArray.add(dic)
                }
            }
            if qustion.content!.length == 0 {
                debugPrint("[vote error] inputQuestions")
                    return
            }
            let qustionDic = ["options" : optionsArray,"content":qustion.content! as String,"is_single":qustion.isSingle!] as [String : Any]
            quetionArray.add(qustionDic)
        }
       
        if isUpdate == true {
            MeetingAPIRequest.meetingPollUpdate(number: (SampleMeetingManager.defaultManager().meetingInfo?.number)!, questions: quetionArray as! Array<NSMutableArray>, title: voteModel!.title, isAnonymous: voteModel!.isAnonymous > 0 ? true : false) {[weak self] response in
                if response != nil {
                    let vorePulishVC = VotePublishViewController()
                    vorePulishVC.voteId = self!.voteModel!.id as NSString
                    
                    self!.navigationController?.pushViewController(vorePulishVC, animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil,userInfo: nil)
                }
            }
        } else {
            MeetingAPIRequest.meetingPollCreate(number: (SampleMeetingManager.defaultManager().meetingInfo?.number)!, questions: quetionArray as! Array<NSMutableArray>, title: voteModel!.title, isAnonymous: voteModel!.isAnonymous > 0 ? true : false) {[weak self] response in
                if response != nil {
                    let voteListItemModel : VoteModelListItem = VoteModelListItem.deserialize(from: (response as! [String : Any]))!
                    let vorePulishVC = VotePublishViewController()
                    vorePulishVC.voteId = voteListItemModel.id! as NSString
                    SampleMeetingManager.defaultManager().hostSendCustomControlMessageToRoom(["vote_id" : voteListItemModel.id! as NSString], subType: "poll_start")
                    self!.navigationController?.pushViewController(vorePulishVC, animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil,userInfo: nil)
                }
            }
        }
    }
    
    func addNavButton() {
        let button = UIButton(frame:CGRect(x:0, y:0, width:18, height:18))
        button.addTarget(self, action: #selector(publishVote), for: .touchUpInside)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(mainColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems = [barButton]
    }

    lazy var creatVoteView : CreatVoteView = {
        let creatVoteView = CreatVoteView.init(frame: CGRect.zero, voteModel: voteModel!)
        return creatVoteView
    }()

}
