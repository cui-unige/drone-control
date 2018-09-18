//
//  TestingVC.swift
//  DroneProgrammer
//
//  Created by CUI on 12.07.18.
//  Copyright © 2018 CUI. All rights reserved.
//

import UIKit
    /*
class TestingVC: UIViewController, BebopDroneDelegate, UIAlertViewDelegate {

    
    @IBOutlet var coordoEntryX: UITextField!
    @IBOutlet var coordoEntryY: UITextField!
    @IBOutlet var coordoEntryZ: UITextField!
    
    var connectionAlertView: UIAlertController?
    var downloadAlertController: UIAlertController?
    var downloadProgressView: UIProgressView?
    var bebopDrone: BebopDrone?
    var stateSem: DispatchSemaphore?
    var nbMaxDownload: Int = 0
    var currentDownloadIndex: Int = 0
    
    var service: ARService!
    
    @objc
    func setService(_ service: ARService) {
        self.service = service
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coordoEntryX.delegate = self
        coordoEntryY.delegate = self
        coordoEntryZ.delegate = self
        
        stateSem = DispatchSemaphore(value: 0)
        bebopDrone = BebopDrone(service: service)
        bebopDrone?.delegate = self
        bebopDrone?.connect()
        connectionAlertView = UIAlertController.init(
            title: service?.name,
            message: "Connecting...",
            preferredStyle: .alert)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if bebopDrone?.connectionState() != ARCONTROLLER_DEVICE_STATE_RUNNING {
            connectionAlertView?.show(connectionAlertView!,
                                      sender: connectionAlertView!)
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (connectionAlertView != nil) {//}&& connectionAlertView?.isHidden == nil {
            connectionAlertView?.dismiss(animated: false, completion: nil)
        }
        connectionAlertView = UIAlertController(
            title: service?.name,
            message: "Disconnecting ...",
            preferredStyle: .alert
        )
        connectionAlertView?.show(connectionAlertView!, sender: connectionAlertView!)
        // in background, disconnect from the drone
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            self.bebopDrone?.disconnect()
            // wait for the disconnection to appear
            //Dispatch_semaphore_wait(stateSem!, DispatchTime.distantFuture)
            self.stateSem?.wait(timeout: DispatchTime.distantFuture)
            //DispatchSemaphore.wait(DispatchTime.distantFuture, stateSem!)
            self.bebopDrone = nil
            // dismiss the alert view in main thread
            DispatchQueue.main.async(execute: {() -> Void in
                self.connectionAlertView?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    // MARK: BebopDroneDelegate
    func bebopDrone(_ bebopDrone: BebopDrone?, connectionDidChange state: eARCONTROLLER_DEVICE_STATE) {
        switch state {
        case ARCONTROLLER_DEVICE_STATE_RUNNING:
            connectionAlertView?.dismiss(animated: true, completion: nil)
        case ARCONTROLLER_DEVICE_STATE_STOPPED:
            //stateSem!.signal()
            stateSem?.signal()
            // Go back
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    func bebopDrone(_ bebopDrone: BebopDrone?, batteryDidChange batteryPercentage: CInt) {
        //batteryLabel.text = "\(batteryPercentage)%%"
    }
    
    func bebopDrone(_ bebopDrone: BebopDrone?, flyingStateDidChange state: eARCOMMANDS_ARDRONE3_PILOTINGSTATE_FLYINGSTATECHANGED_STATE) {
        //        not used in this view controller
        
    }
    
    func bebopDrone(_ bebopDrone: BebopDrone?, configureDecoder codec: ARCONTROLLER_Stream_Codec_t) -> Bool {
        //        not used in this view controller
        return true
    }
    
    func bebopDrone(_ bebopDrone: BebopDrone?, didReceive frame: UnsafeMutablePointer<ARCONTROLLER_Frame_t>) -> Bool {
        //        not used in this view controller
        return true
    }
    
    func bebopDrone(_ bebopDrone: BebopDrone?, didFoundMatchingMedias nbMedias: UInt) {
        //        not used in this view controller
    }
    
    func bebopDrone(_ bebopDrone: BebopDrone?, media mediaName: String?, downloadDidProgress progress: CInt) {
        //        not used in this view controller
        
    }
    
    func bebopDrone(_ bebopDrone: BebopDrone?, mediaDownloadDidFinish mediaName: String?) {
        //        not used in this view controller
        
    }
 

}*/

