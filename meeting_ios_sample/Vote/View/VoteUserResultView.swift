//
//  VoteUserResultView.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/9.
//

import UIKit

class VoteUserResultView: UIView , UITableViewDelegate,UITableViewDataSource{
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
    
    @objc func delVoteClick(){//删除投票
        //删除投票后返回到投票列表页面（添加toast提示）
        
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
            self.voteTagLabel?.text = voteModel!.isAnonymous > 0 ? "anonymous": "unanonymous"
            self.tableView.tableHeaderView = voteHeaderView
            self.tableView.reloadData()
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
            make.bottom.equalTo(self.snp.bottom).offset(-SafeArea_BottomHeight)
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
        let voteUserResultCell = tableView.dequeueReusableCell(withIdentifier: "voteUserResultCell") as! VoteUserResultCell
        voteUserResultCell.indexPath = indexPath as NSIndexPath
        voteUserResultCell.model = voteModel
        voteUserResultCell.setNeedsDisplay()
        return voteUserResultCell
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
        tableView.register(VoteUserResultCell.classForCoder(), forCellReuseIdentifier: "voteUserResultCell")
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
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

