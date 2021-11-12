//
//  SampleHandler.swift
//  MeetingSample_Share
//
//  Created by Fox Doggy on 2021/10/21.
//

import ReplayKit
import CLS_ShareSDK

class SampleHandler: RPBroadcastSampleHandler {

    private static let uploader:CLS_UploaderManager = {
        let manager = CLS_UploaderManager.shareManager()
        return manager
    }()
    var initStatus: Bool = false

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        debugPrint("broadcastStarted")
        let root_path : URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.OpenPlatformTeam.meeting-ios-sample")!
        let write_path = root_path.appendingPathComponent("Library/Caches/", isDirectory: true)
        let path = write_path.appendingPathComponent("shareInfo").appendingPathExtension("plist")

        guard  FileManager.default.isReadableFile(atPath: path.path) else {
            debugPrint("file can't readable")
            return
        }
        var data: Data?
        do {
            data = try Data.init(contentsOf: path)
        } catch {
            debugPrint(error)
            return
        }
        
        var info: Any?
        do {
            info = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed)
        } catch {
            debugPrint(error)
            return
        }
        
        guard info != nil else {
            return
        }
        let shareInfo = info as! NSDictionary

        let channel: NSNumber = shareInfo["room_id"] as! NSNumber
        let token: NSString = shareInfo["token"] as! NSString
        let appKey: NSString = shareInfo["app_key"] as! NSString
        let userId: NSNumber = shareInfo["user_id"] as! NSNumber
        
        debugPrint("read file: %@", shareInfo)
        
        SampleHandler.uploader.joinRTC(withUserId: userId, authToken: token as String, appKey: appKey as String, roomNumber: channel) { [weak self] success, error in
            guard let weak_self = self else {
                return
            }
            weak_self.initStatus = success
            if success {
                SampleHandler.uploader.startBroadcast()
            }
        }
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        if self.initStatus {
            SampleHandler.uploader.stopBroadcast()
        }
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            if self.initStatus {
                SampleHandler.uploader.sendVideoBuffer(sampleBuffer)
            }
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            if self.initStatus {
                SampleHandler.uploader.sendAudioAppBuffer(sampleBuffer)
            }
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            if self.initStatus {
                SampleHandler.uploader.sendAudioMicBuffer(sampleBuffer)
            }
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
}
