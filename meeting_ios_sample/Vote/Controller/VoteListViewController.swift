//
//  VoteListViewController.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/2.
//

import UIKit

class VoteListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Poll List"
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: mainBlackColor]
        
        NotificationCenter.default.addObserver(self, selector: #selector(backView), name:NSNotification.Name(rawValue: "popToPre"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getList), name:NSNotification.Name(rawValue: "reloadData"), object: nil)
        self.view.backgroundColor = .white
        self.view.addSubview(voteList)
        voteList.snp.makeConstraints{(make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view).offset(NaviBar_Height)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.getList()
    }
    
    @objc func backView(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func getList() {
        MeetingAPIRequest.meetingPollList(number: SampleMeetingManager.defaultManager().meetingInfo!.number!) {[weak self] response in
            if response != nil {
                if let object = [VoteModelListItem].deserialize(from: (response as! Array)) {
                    self!.voteList.modelArray?.removeAll()
                    self!.voteList.modelArray? = Array.init((object as! [VoteModelListItem]))
                }
            }
        }
    }

    lazy var voteList : VoteListView = {
        let voteList = VoteListView()
        return voteList
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


