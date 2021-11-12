//
//  CreatVoteView.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/2.
//

import UIKit

class CreatVoteView: UIView,UITableViewDelegate,UITableViewDataSource,CellClickProtocol,HeaderClickProtocol{
    
    var voteTitleCell : CreatVoteCell?
    
    var voteDescriptionCell : CreatVoteCell?
    
    var voteModel : VoteModel?
    
    var currentAddIndexPath : NSIndexPath?
    
    init(frame: CGRect,voteModel:VoteModel) {
        self.voteModel = voteModel
        super.init(frame: frame)
        self.addSubview(tableView)
        self.addSubview(doneButton)
        self.addSubview(lineView)
        
        let tapAction = UITapGestureRecognizer.init { [weak self] gesture in
            self?.endEditing(true)
        }
        self.addGestureRecognizer(tapAction)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaInsets.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(-TabBar_Height)
        }
        
        doneButton.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.leftMargin.equalTo(30)
            make.rightMargin.equalTo(-30)
            make.height.equalTo(40)
        }
    }
    
    func anonymousSelect(anonymous: Bool) {
        voteModel?.isAnonymous = anonymous ? 0 : 1
    }
    
    func voteTypeSelect(section: Int, selectType: Int) {
        let qustionModel : VoteQustionModel = voteModel!.creatquestions![section - 10002] as! VoteQustionModel
        qustionModel.isSingle = selectType == 0 ? 1 : 0
    }
    
    @objc func addItem(sender:UIButton) {
        let qustionModel : VoteQustionModel = voteModel?.creatquestions![sender.tag - 10002] as! VoteQustionModel
        self.currentAddIndexPath = NSIndexPath.init(row: qustionModel.itemArray!.count, section: sender.tag - 10000)
        let voteOption : VoteOptionModel = VoteOptionModel()
        qustionModel.itemArray?.add(voteOption)
        if qustionModel.itemArray?.count == 10 {
            tableView .reloadData()
        }else{
            tableView.insertRows(at: [IndexPath.init(row: self.currentAddIndexPath!.row, section: self.currentAddIndexPath!.section)], with: .fade)
        }
    }
    
    func removeItem(section: Int, indexPath: NSIndexPath) {
        let qustionModel : VoteQustionModel = voteModel?.creatquestions![indexPath.section - 2] as! VoteQustionModel
        qustionModel.itemArray?.removeObject(at: indexPath.row)
        tableView.reloadData()
    }
    
    func removeQustion(section: Int) {
        voteModel?.creatquestions?.removeObject(at: section - 10002)
        tableView.reloadData()
        if (voteModel?.creatquestions!.count)! < 10 {
            doneButton.isHidden = false
        }
    }
    
    @objc func creatVote() {
        let voteQustion = VoteQustionModel.init()
        voteModel?.creatquestions?.add(voteQustion)
        tableView.reloadData()
        if voteModel?.creatquestions?.count == 10 {
            doneButton.isHidden = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + (voteModel?.creatquestions!.count)!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return 1
            default:
                let qustionModel : VoteQustionModel = voteModel?.creatquestions![section - 2] as! VoteQustionModel
                return qustionModel.itemArray!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                voteTitleCell = tableView.dequeueReusableCell(withIdentifier: "voteTitleCell") as? CreatVoteCell
                voteTitleCell?.indexPath = indexPath as NSIndexPath;
                voteTitleCell?.setVoteModel(voteModel: voteModel!)
                return voteTitleCell!
            case 1:
                let voteAnonymousCell  = tableView.dequeueReusableCell(withIdentifier: "voteAnonymousCell") as! CreatVoteCell
                voteAnonymousCell.indexPath = indexPath as NSIndexPath;
                voteAnonymousCell.setVoteModel(voteModel: voteModel!)
                voteAnonymousCell.delegate = self
                return voteAnonymousCell
            default:
                let voteItemCell  = tableView.dequeueReusableCell(withIdentifier: "voteItemCell") as! CreatVoteCell
                voteItemCell.delegate = self
                voteItemCell.indexPath = indexPath as NSIndexPath;
                voteItemCell.setVoteModel(voteModel: voteModel!)
                return voteItemCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section <= 1 {
            return 10
        }else{
            return 111
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section <= 1 {
            let headerView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 60))
            headerView.backgroundColor = klineColor
            return headerView
        }else{
            let creatVoteHeaderView : CreatVoteHeaderView = CreatVoteHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 111),voteModel: voteModel!,section:section)
            creatVoteHeaderView.delegate = self
            creatVoteHeaderView.tag = 10000 + section;
            creatVoteHeaderView.setVoteModel(voteModel: voteModel!)
            return creatVoteHeaderView
        }

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section > 1{
            let qustionModel : VoteQustionModel = voteModel?.creatquestions![section - 2] as! VoteQustionModel
            return qustionModel.itemArray!.count >= 10 ? 0 : 50
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section > 1{
            let qustionModel : VoteQustionModel = voteModel?.creatquestions![section - 2] as! VoteQustionModel
            if qustionModel.itemArray!.count == 10 {
                let addItemView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 1))
                return addItemView
            }else{
                let addItemView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 50))
                addItemView.backgroundColor = .white
                let addItemButton : UIButton = UIButton.init(frame: CGRect.init(x: (screenWidth - 100) / 2, y: 0, width: 100, height: 50))
                addItemButton.tag = 10000 + section
                addItemButton.addTarget(self, action: #selector(addItem(sender:)), for: .touchUpInside)
                addItemButton.backgroundColor = .white
                addItemButton.setTitle("Add Choice", for: .normal)
                addItemButton.setTitleColor(mainColor, for: .normal)
                addItemButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                addItemView.addSubview(addItemButton)
                return addItemView
            }
        }else{
            let addItemView : UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 1))
            return addItemView
        }
    }
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: .zero , style: .grouped)
        tableView.backgroundColor = .white
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = .none
        tableView.register(VoteTitleCell.classForCoder(), forCellReuseIdentifier: "voteTitleCell")
        tableView.register(VoteDescriptionCell.classForCoder(), forCellReuseIdentifier: "voteDescriptionCell")
        tableView.register(VoteItemTypeCell.classForCoder(), forCellReuseIdentifier: "voteItemTypeCell")
        tableView.register(VoteItemCell.classForCoder(), forCellReuseIdentifier: "voteItemCell")
        tableView.register(VoteAnonymousCell.classForCoder(), forCellReuseIdentifier: "voteAnonymousCell")
        return tableView
    }()
    
    private lazy var doneButton : UIButton = {
        let doneButton = UIButton.init(frame:.zero)
        doneButton.addTarget(self, action: #selector(creatVote), for: .touchUpInside)
        doneButton.setTitle("Add Question", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        doneButton.backgroundColor = mainColor
        doneButton.layer.cornerRadius = 4
        doneButton.layer.masksToBounds = true
        return doneButton
    }()
    
    lazy var lineView : UIView = {
        let lineView = UIView.init()
        lineView.backgroundColor = klineColor
        return lineView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
