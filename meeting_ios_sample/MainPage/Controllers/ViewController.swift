//
//  ViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/8/30.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var join_btn: UIButton!
    @IBOutlet weak var fast_meeting_btn: UIButton!
    @IBOutlet weak var reserve_btn: UIButton!
    @IBOutlet weak var meeting_table_list: UITableView!
    
    var meetingList = Array<meetingInfoStruct>.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Meeting Sample"
        // Do any additional setup after loading the view.
        self.meeting_table_list.delegate = self
        self.meeting_table_list.dataSource = self
        self.meeting_table_list.register(UINib.init(nibName: "MeetingListCell", bundle: nil), forCellReuseIdentifier: "kMeetingListCell")
//        self.meeting_table_list.separatorStyle = .none
        self.meeting_table_list.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let token = UserDefaults.standard.object(forKey: "api_token")
        if (token == nil) {
            let loginVC = LoginViewController.init()
            let loginNaviController = UINavigationController.init(rootViewController: loginVC)
            loginNaviController.modalPresentationStyle = .fullScreen
            self.navigationController?.present(loginNaviController, animated: true, completion: nil)
        } else {
            MeetingAPIRequest.shareManager.settingUserAuthToken(token: (token as! String))
            LoginUserDataModel.manager.authToken = (token as! String)
            LoginUserDataModel.manager.userId = Int32(UserDefaults.standard.integer(forKey: "user_id"))
            LoginUserDataModel.manager.user_name = UserDefaults.standard.string(forKey: "user_name")
            
            let date = Date()
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "yyyy-MM-dd"
            let day:String = dateFormate.string(from: date)
            let beginTimeAt:String = day.appending("T00:00:00+08:00")
            let endTimeAt:String = day.appending("T23:59:59+08:00")
            MeetingAPIRequest.meetingList(startAt: beginTimeAt, endAt: endTimeAt) {[weak self] response in
                if response != nil {
                    let responseList = response as! Array<Any>
                    let result:Array<meetingInfoStruct> = JSON(withJSONObject: responseList, modelType: [meetingInfoStruct].self)!
                    self!.meetingList = result
                    self!.meeting_table_list.reloadData()
                } else {
                    let loginVC = LoginViewController.init()
                    let loginNaviController = UINavigationController.init(rootViewController: loginVC)
                    loginNaviController.modalPresentationStyle = .fullScreen
                    self?.navigationController?.present(loginNaviController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // button action
    @IBAction func joinMeetingAction(_ sender: Any) {
        self.navigationController?.pushViewController(JoinMeetingViewController(), animated: true)
    }
    
    @IBAction func fastMeetingAction(_ sender: Any) {
        self.navigationController?.pushViewController(FastMeetingViewController(), animated: true)
    }
    
    @IBAction func reserveMeetingAction(_ sender: Any) {
        self.navigationController?.pushViewController(ReserveMeetingViewController(), animated: true)
    }
    
    // table view delegate & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.meetingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeetingListCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "kMeetingListCell", for: indexPath) as? MeetingListCell
        let data_model:meetingInfoStruct = self.meetingList[indexPath.row]
        cell?.handleDatasWith(model: data_model)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:MeetingListCell = tableView.cellForRow(at: indexPath) as! MeetingListCell
        let info_struct:meetingInfoStruct = cell.data!
        guard info_struct.status! < 2 else {
            debugPrint("meeting is closed: " + String(info_struct.number!))
            return
        }
        let meetingJoinInfo:MeetingJoinInfo = MeetingJoinInfo.init(meeting_code: info_struct.number, meeting_nickname: info_struct.name, meeting_muteType: 0, meeting_type: .fromList, is_admin: info_struct.ownerId! == LoginUserDataModel.manager.userId!, carmera_status: true, audio_status: true, speaker_status: true)
        let meetingVC = MeetingViewController()
        meetingVC.settingMeetingInfoMessage(info: info_struct, setting_info: meetingJoinInfo)
        meetingVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(meetingVC, animated: true, completion: nil)
    }
}

