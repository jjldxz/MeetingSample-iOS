//
//  VotePublishViewController.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/9.
//

import UIKit

class VotePublishViewController: UIViewController {
    var voteId : NSString?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Poll"
        self.view.backgroundColor = .white
        self.view.addSubview(votePublishView)
        NotificationCenter.default.addObserver(self, selector: #selector(backView), name:NSNotification.Name(rawValue: "popToPrev"), object: nil)
        votePublishView.snp.makeConstraints{(make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view).offset(NaviBar_Height)
        }
        
        self.getVoteDetail()
    }
    
    @objc func backView(){
        let mineVC = VoteListViewController()
        var targetVC : UIViewController!
        for controller in self.navigationController!.viewControllers {
            if controller.isKind(of: mineVC.classForCoder) {
                targetVC = controller
            }
        }
        if targetVC != nil {
            NotificationCenter.default.removeObserver(self)
            self.navigationController?.popToViewController(targetVC, animated: true)
        }
    }
    
    func getVoteDetail() {
        MeetingAPIRequest.meetingPollDetail(poll_id: Int(voteId!.intValue)) {[weak self] response in
            if response != nil {
                if let object : VoteModel = VoteModel.deserialize(from: (response as! Dictionary<String, Any>)){
                    object.id = self!.voteId! as String
                    self!.votePublishView.voteModel = object
                }
            }
        }
    }

    lazy var votePublishView : VotePublishView = {
        let votePublishView = VotePublishView(frame: .zero)
        return votePublishView
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
