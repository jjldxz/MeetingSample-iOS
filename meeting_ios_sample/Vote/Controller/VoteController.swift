//
//  VoteController.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/3.
//

import UIKit

@objc class VoteController: UIViewController {
    @objc var voteId : NSString? {
        didSet {
            getVoteDetail()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "poll"
        self.view.backgroundColor = .white
        self.view.addSubview(voteView)
        
        self.getVoteDetail()
        
        voteView.snp.makeConstraints{(make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view).offset(NaviBar_Height)
        }
    }

    func getVoteDetail() {
        guard voteId != nil else {
            return
        }
        MeetingAPIRequest.meetingPollDetail(poll_id: Int(voteId!.intValue)) {[weak self] response in
            if response != nil {
                if let object : VoteModel = VoteModel.deserialize(from: (response as! Dictionary)) {
                    object.id = self!.voteId! as String
                    self!.voteView.voteModel = object
                }
            }
        }
    }
    
    lazy var voteView : VoteView = {
        let voteView = VoteView(frame: .zero)
        return voteView
    }()

}
