//
//  WhiteBroadViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/18.
//

import UIKit

class WhiteBroadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WhiteboardPageViewDrawDelegate {
    
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var backGrayView: UIView!
    @IBOutlet weak var drawMenuView: UICollectionView!
    @IBOutlet weak var colorMenuView: UICollectionView!
    var whiteboardBackView = UIView.init()
    var whiteboard:WhiteboardPageView?
    let whiteboardMenuList:Array<DXZEducationWhiteboardTrackStyle> = [.graffiti_Tool, .line_Tool, .rect_Tool, .circle_Tool, .text_Tool, .revoke_Tools, .clear_Tools, .color_Tools]
    let whiteboardColorList:Array<UIColor> = [.black, .darkGray, .darkText, .gray, .lightGray, .lightText, .white, .yellow, .green, .cyan, .blue, .purple, .red, .orange]
    var defaultWhiteboardTool:DXZEducationWhiteboardTrackStyle = .graffiti_Tool
    var defaultWhiteboradColor:UIColor = .black
    weak var delegate: WhiteBroadVCDelegate?
    var isSelfShare: Bool? {
        didSet {
            guard self.close_btn != nil else {
                return
            }
            self.close_btn.isHidden = !self.isSelfShare!
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.whiteboardBackView.isUserInteractionEnabled = true
        self.whiteboardBackView.bounds = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenWidth * 9 / 16.0)
        self.whiteboardBackView.center = CGPoint.init(x: screenWidth * 0.5, y: screenHeight * 0.5)
        self.whiteboardBackView.backgroundColor = UIColor.white;
        self.view.addSubview(self.whiteboardBackView)
        
        self.whiteboard = WhiteboardPageView.init(frame: CGRect.init(x: 0, y: 0, width: self.whiteboardBackView.width, height: self.whiteboardBackView.height))
        self.whiteboardBackView.addSubview(self.whiteboard!)
        self.whiteboard?.groupId = NSNumber.init(value: -1)
        self.whiteboard?.fontSize = 15.0
        self.whiteboard!.settingDrawTrackColor(self.defaultWhiteboradColor)
        self.whiteboard!.settingDrawPictureTrackStyle(self.defaultWhiteboardTool)
        self.whiteboard!.drawDelegate = self
        self.whiteboard?.buildNewPageAndScrollToLastIndex()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isSelfShare = false
        
        self.drawMenuView.register(UINib.init(nibName: "WhiteboardMenuCell", bundle: nil), forCellWithReuseIdentifier: "kWhiteboardMenuCellReuseId")
        self.drawMenuView.delegate = self
        self.drawMenuView.dataSource = self
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        self.drawMenuView.setCollectionViewLayout(layout, animated: true)
        
        self.colorMenuView.register(UINib.init(nibName: "WhiteboardColorMenuCell", bundle: nil), forCellWithReuseIdentifier: "kWhiteboardColorMenuCellReuseId")
        self.colorMenuView.delegate = self
        self.colorMenuView.dataSource = self
        let color_layout = UICollectionViewFlowLayout.init()
        color_layout.scrollDirection = .horizontal
        color_layout.minimumInteritemSpacing = 0.0
        color_layout.minimumLineSpacing = 0.0
        self.colorMenuView.setCollectionViewLayout(color_layout, animated: true)
    }

    @IBAction func closeWhiteboardAction(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.whiteboardDidDismiss()
        }
    }
    
    open func receivedDrawHistoryMessage(_ message: DrawPageHistoryDataInfo) {
        self.whiteboard!.loadHistoryDatas(message.pages, totleCount: message.pageCount)
    }
    
    open func receivedDrawShapeMessage(_ message: DrawShapeControlInfoModel) {
        self.whiteboard!.shapeDrawInView(withOperation: message)
    }
    
    open func receivedDrawPencilMessage(_ messaage: DrawLineControlInfoModel) {
        self.whiteboard!.pencilDrawInView(withInfo: messaage)
    }
    
    open func shareWhiteboardDidBeenClosed() {
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.whiteboardDidDismiss()
        }
    }
    
    /// UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.height, height: collectionView.height)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(self.drawMenuView) {
            return whiteboardMenuList.count
        } else {
            return whiteboardColorList.count
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(self.drawMenuView) {
            let cell:WhiteboardMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "kWhiteboardMenuCellReuseId", for: indexPath) as! WhiteboardMenuCell
            let menuType:DXZEducationWhiteboardTrackStyle = self.whiteboardMenuList[indexPath.row]
            switch menuType {
            case .graffiti_Tool:
                if self.defaultWhiteboardTool == .graffiti_Tool {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_hb_icon_select")
                } else {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_hb_icon")
                }
                cell.icon_view.backgroundColor = .white
                break
            case .line_Tool:
                if self.defaultWhiteboardTool == .line_Tool {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_zx_icon_select")
                } else {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_zx_icon")
                }
                cell.icon_view.backgroundColor = .white
                break
            case .rect_Tool:
                if self.defaultWhiteboardTool == .rect_Tool {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_jx_icon_select")
                } else {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_jx_icon")
                }
                cell.icon_view.backgroundColor = .white
                break
            case .circle_Tool:
                if self.defaultWhiteboardTool == .circle_Tool {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_yx_icon_select")
                } else {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_yx_icon")
                }
                cell.icon_view.backgroundColor = .white
                break
            case .NULL:
                cell.icon_view.image = nil
                cell.icon_view.backgroundColor = .white
                break
            case .clear_Tools:
                cell.icon_view.image = UIImage.init(named: "liveRoom_qc_icon")
                cell.icon_view.backgroundColor = .white
                break
            case .revoke_Tools:
                cell.icon_view.image = UIImage.init(named: "liveRoom_syb_icon")
                cell.icon_view.backgroundColor = .white
                break
            case .color_Tools:
                cell.icon_view.image = nil
                cell.icon_view.backgroundColor = self.defaultWhiteboradColor
                break
            case .text_Tool:
                if self.defaultWhiteboardTool == .text_Tool {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_wb_icon_select")
                } else {
                    cell.icon_view.image = UIImage.init(named: "liveRoom_wb_icon")
                }
                cell.icon_view.backgroundColor = .white
                break
            @unknown default:
                cell.icon_view.image = nil
                cell.icon_view.backgroundColor = self.defaultWhiteboradColor
                break
            }
            return cell
        } else {
            let cell:WhiteboardColorMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "kWhiteboardColorMenuCellReuseId", for: indexPath) as! WhiteboardColorMenuCell
            cell.colorView.backgroundColor = self.whiteboardColorList[indexPath.row]
            return cell
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(self.drawMenuView) {
            let menuType:DXZEducationWhiteboardTrackStyle = self.whiteboardMenuList[indexPath.row]
            switch menuType {
            case .graffiti_Tool, .line_Tool, .rect_Tool, .circle_Tool:
                self.defaultWhiteboardTool = menuType
                self.whiteboard?.settingDrawPictureTrackStyle(menuType)
                    collectionView.reloadData()
                    break
            case .text_Tool:
                self.defaultWhiteboardTool = menuType
                collectionView.reloadData()
                let alert = UIAlertController.init(title: "Text Input", message: "input your text and touch the whiteboard to draw", preferredStyle: .alert)
                alert.addTextField { textField in
                    textField.placeholder = "please input text what your will draw on the whiteboard"
                }
                alert.addAction(UIAlertAction.init(title: "Submit", style: .default, handler: {[weak self] action in
                    let text_field:UITextField = (alert.textFields?.first)!
                    self?.whiteboard?.inputDrawTextContent(text_field.text)
                }))
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: {[weak self] action in
                    self?.view.endEditing(true)
                }))
                self.present(alert, animated: true, completion: nil)
                break
            case .NULL:
                break
            case .clear_Tools:
                self.whiteboard?.removeAllLayerDrawingOnCurrentPage()
                break
            case .revoke_Tools:
                self.whiteboard?.previousStepOnCurrentPage()
                break
            case .color_Tools:
                self.colorMenuView.isHidden = !self.colorMenuView.isHidden
                break
            @unknown default:
                break
            }
        } else {
            self.defaultWhiteboradColor = self.whiteboardColorList[indexPath.row];
            self.colorMenuView.isHidden = !self.colorMenuView.isHidden
            self.drawMenuView.reloadData()
            self.whiteboard?.settingDrawTrackColor(self.defaultWhiteboradColor)
        }
    }
    
    /// WhiteboardPageViewDrawDelegate
    internal func sendDrawActionJsonStringDatas(_ sendMessage: String) {
        delegate?.whiteboardDrawMessage(sendMessage)
    }
}


protocol WhiteBroadVCDelegate: AnyObject {
    func whiteboardDrawMessage(_ message: String)
    func whiteboardDidDismiss()
}
