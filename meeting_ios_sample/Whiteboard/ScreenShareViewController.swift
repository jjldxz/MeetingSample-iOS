//
//  ScreenShareViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/10/13.
//

import UIKit

struct screenShareInfo {
    var share_user: Int32!
    var share_name: String!
}

class ScreenShareViewController: UIViewController {

    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var screenShareView: UIView!
    
    @IBOutlet weak var speakerView: UIView!
    @IBOutlet weak var speakerVideoView: UIView!
    @IBOutlet weak var speakerNameLabel: UILabel!
    
    weak var delegate: ScreenShareViewControllerDelegate?
    var info: screenShareInfo?
    var isShow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.info != nil {
            self.screenTitleLabel.text = info!.share_name! + " screen share"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.screenShareVCDidDisplayUI(self.screenShareView)
    }
}

protocol ScreenShareViewControllerDelegate: NSObjectProtocol {
    func screenShareVCDidDisplayUI(_ videoView: UIView)
}
