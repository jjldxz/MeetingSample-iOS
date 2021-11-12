//
//  UserResultController.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/9.
//

import UIKit

class UserResultController: UIViewController {
    var voteId : NSString?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Poll Result"
        self.view.backgroundColor = .white

        self.view.addSubview(voteUserResultView)
        self.getVoteResult()
        NotificationCenter.default.addObserver(self, selector: #selector(backView), name:NSNotification.Name(rawValue: "popToPreR"), object: nil)
        voteUserResultView.snp.makeConstraints{(make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view).offset(NaviBar_Height)
        }
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
        }else{
            NotificationCenter.default.removeObserver(self)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func getVoteResult() {
        let parameterDic : NSDictionary = ["id":voteId!]
        print("parameterDic = \(parameterDic)")
        MeetingAPIRequest.meetingPollResult(poll_id: Int(voteId!.intValue)) { [weak self] response in
            if response != nil {
                if let object : VoteModel = VoteModel.deserialize(from: (response as! Dictionary<String, Any>)){
                    object.id = self!.voteId! as String
                    self!.voteUserResultView.voteModel = object
                }
            }
        }
    }

    lazy var voteUserResultView : VoteUserResultView = {
        let voteUserResultView = VoteUserResultView(frame: .zero)
        return voteUserResultView
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
