//
//  VoteListView.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/2.
//

import UIKit
import RxSwift

class VoteListView: UIView,UITableViewDelegate,UITableViewDataSource{
    
    fileprivate lazy var bag = DisposeBag()
    
    var modelArray: Array<VoteModelListItem>? {
        didSet {
//            guard modelArray != nil else { return }
            self.tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.modelArray = Array.init()
        self.addSubview(tableView)
        self.addSubview(nodataImageView)
        if SampleMeetingManager.defaultManager().user_info?.role != "attendee" {
            self.addSubview(voteButton)
        }
        self.addSubview(lineView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaInsets.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(0)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(SampleMeetingManager.defaultManager().user_info?.role == "host" ? -TabBar_Height : -SafeArea_BottomHeight)
        }
        
        nodataImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize.init(width: 100, height: 100))
            make.center.equalTo(tableView)
        }
        
        if SampleMeetingManager.defaultManager().user_info?.role == "host" {
            voteButton.snp.makeConstraints { (make) in
                make.top.equalTo(tableView.snp.bottom).offset(20)
                make.leftMargin.equalTo(30)
                make.rightMargin.equalTo(-30)
                make.height.equalTo(40)
            }
        }
    }
    
    @objc func creatVoteClick() {
        //判断是否是自己
        //是自己
        //未开始投票
//        if  {
//            
//        }
        if SampleMeetingManager.defaultManager().user_info?.role != "attendee" {
            self.viewForController(view: self)?.navigationController?.pushViewController(CreatVoteController(), animated: true)
        }
        
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ((modelArray?.isEmpty) != nil) {
            self.nodataImageView.isHidden = modelArray!.count != 0;
            return modelArray!.count
        }else{
           
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let voteModelListItem = modelArray![indexPath.row]
        let voteListCell = tableView.dequeueReusableCell(withIdentifier: "voteListCell") as! VoteListCell
        voteListCell.model = voteModelListItem
        return voteListCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let voteModelListItem = modelArray![indexPath.row]
        if  voteModelListItem.status == 0 {//未开始
            if  SampleMeetingManager.defaultManager().user_info?.role == "host" {//host身份
                let votePubLishVC = VotePublishViewController()
                voteModelListItem.roomId = String(SampleMeetingManager.defaultManager().meetingInfo!.number!) as NSString?
                votePubLishVC.voteId = voteModelListItem.id
                self.viewForController(view: self)?.navigationController?.pushViewController(votePubLishVC, animated: true)
            }
        }else {//进行中,已结束
            if  SampleMeetingManager.defaultManager().user_info?.role == "host" {//host身份
                let voteResultVC = VoteResultController()
                voteResultVC.voteId = voteModelListItem.id
                voteResultVC.is_pulishing = voteModelListItem.share == true ? "1" : "0"
                voteResultVC.is_mainUser = "1"
                self.viewForController(view: self)?.navigationController?.pushViewController(voteResultVC, animated: true)
            }else{//用户身份
                if voteModelListItem.share == true {
                    let voteResultVC = VoteResultController()
                    voteResultVC.voteId = voteModelListItem.id
                    voteResultVC.is_pulishing = "1"
                    voteResultVC.is_mainUser = "0"
                    self.viewForController(view: self)?.navigationController?.pushViewController(voteResultVC, animated: true)
                }else{
                    if SampleMeetingManager.defaultManager().vote_status == false && voteModelListItem.status == 1 {//未投票
                        let voteVC : VoteController = VoteController()
                        voteVC.voteId = voteModelListItem.id
                        self.viewForController(view: self)?.navigationController?.pushViewController(voteVC, animated: true)
                    } else {
                    let userResultVC = UserResultController()
                    userResultVC.voteId = voteModelListItem.id
                    self.viewForController(view: self)?.navigationController!.pushViewController(userResultVC, animated: true)
                }
            }
            }
        }
    }
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: .zero)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = .none
        tableView.register(VoteListCell.classForCoder(), forCellReuseIdentifier: "voteListCell")
        return tableView
    }()
    
    private lazy var voteButton : UIButton = {
        let voteButton = UIButton.init(frame: .zero)
        voteButton.addTarget(self, action: #selector(creatVoteClick) , for: .touchUpInside)
        voteButton.backgroundColor = mainColor
        voteButton.setTitle("Create Poll", for: .normal)
        voteButton.setTitleColor(.white, for: .normal)
        voteButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        voteButton.layer.cornerRadius = 4
        voteButton.layer.masksToBounds = true
        return voteButton
    }()
    
    lazy var lineView : UIView = {
        let lineView = UIView.init()
        lineView.backgroundColor = klineColor
        return lineView
    }()
    
    private lazy var nodataImageView : UIImageView = {
        let nodataImageView = UIImageView.init(frame: .zero)
        nodataImageView.image = UIImage.init(named: "meeting_null_icon")
        nodataImageView.isHidden = true
        return nodataImageView
    }()
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //获取当前页面的最顶层控制器
   func currentVc() -> UIViewController {
        let keywindow = UIApplication.shared.keyWindow
        let firstView: UIView = (keywindow?.subviews.first)!
        let secondView: UIView = firstView.subviews.first!
        let vc = viewForController(view: secondView)
        return vc!
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
