//
//  VoteResultController.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/3.
//

import UIKit

@objc class VoteResultController: UIViewController,reloadViewProtocol {
    @objc var voteId : NSString?
    @objc var is_pulishing : NSString?
    @objc var is_mainUser : NSString?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Poll Result"
        self.view.backgroundColor = .white
        self.view.addSubview(voteResultView)
        self.getVoteResult()
        
        voteResultView.snp.makeConstraints{(make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view).offset(NaviBar_Height)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(backView), name:NSNotification.Name(rawValue: "popToPreR"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getVoteResult), name:NSNotification.Name(rawValue: "reloadCommitData"), object: nil)
    }
    
    @objc func backView(){
        let mineVC = VoteListViewController()
        var targetVC : UIViewController!
        for  controller in self.navigationController!.viewControllers {
            if controller.isKind(of: mineVC.classForCoder) {
                targetVC = controller
            }
        }
        if targetVC != nil {
            NotificationCenter.default.removeObserver(self)
            self.navigationController?.popToViewController(targetVC, animated: true)
        }else{
            NotificationCenter.default.removeObserver(self)
//            targetVC = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2]
//            self.navigationController?.popToViewController(targetVC, animated: true)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func getVoteResult() {
        let parameterDic : NSDictionary = ["id":voteId!]
        print("parameterDic = \(parameterDic)")
        MeetingAPIRequest.meetingPollResult(poll_id: Int(voteId!.intValue)) { [weak self] response in
            if response != nil {
                if let object : VoteModel = VoteModel.deserialize(from: response as? Dictionary) {
                    object.is_publishing = self!.is_pulishing!.isEqual(to: "0") ? 0 : 1
                    object.id = self!.voteId! as String
                    self!.voteResultView.voteModel = object
                }
            } else {
                
            }
        }
    }
    
    func reloadView() {
        self.getVoteResult()
    }

    lazy var voteResultView : VoteResultView = {
        let voteResultView = VoteResultView(frame: .zero)
        voteResultView.is_mainUser = self.is_mainUser!.isEqual(to: "1")
        voteResultView.delegate = self
        return voteResultView
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
