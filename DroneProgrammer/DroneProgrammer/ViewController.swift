//
//  ViewController.swift
//  DroneProgrammer
//
//  Created by CUI on 23.05.18.
//  Copyright © 2018 CUI. All rights reserved.
///

import UIKit

class ViewController: UIViewController, BebopDroneDelegate, UIAlertViewDelegate {
//    View controller of the "free flight"

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
//        initialize the service name
        self.service = service
    }
    
    @IBOutlet var videoView: H264VideoView!
    @IBOutlet var batteryLabel: UILabel!
    @IBOutlet var takeOffLandBt: UIButton!
    @IBOutlet var downloadMediasBt: UIButton!
    
    override func viewDidLoad() {
//      connect the drone and the service name when the view is loading
        super.viewDidLoad()

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
//        verify if the device is connected
        super.viewDidAppear(animated)
        if bebopDrone?.connectionState() != ARCONTROLLER_DEVICE_STATE_RUNNING {
            connectionAlertView?.show(connectionAlertView!,
                                      sender: connectionAlertView!)
        }
    }
    

    override func viewDidDisappear(_ animated: Bool) {
//        disconnect the device when we leave the view
        super.viewDidDisappear(animated)
        if (connectionAlertView != nil) {
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
            self.stateSem?.wait(timeout: DispatchTime.distantFuture)
            self.bebopDrone = nil
            // dismiss the alert view in main thread
            DispatchQueue.main.async(execute: {() -> Void in
                self.connectionAlertView?.dismiss(animated: true, completion: nil)
            })
        })
    }

    // MARK: BebopDroneDelegate
    func bebopDrone(_ bebopDrone: BebopDrone?, connectionDidChange state: eARCONTROLLER_DEVICE_STATE) {
//        control the connection state of the device and navigate between the views
        switch state {
        case ARCONTROLLER_DEVICE_STATE_RUNNING:
            connectionAlertView?.dismiss(animated: true, completion: nil)
        case ARCONTROLLER_DEVICE_STATE_STOPPED:
            stateSem?.signal()
            // Go back
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }

    func bebopDrone(_ bebopDrone: BebopDrone?, batteryDidChange batteryPercentage: CInt) {
//        set the battery label (not used)
        //batteryLabel.text = "\(batteryPercentage)%%"
    }

    func bebopDrone(_ bebopDrone: BebopDrone?, flyingStateDidChange state: eARCOMMANDS_ARDRONE3_PILOTINGSTATE_FLYINGSTATECHANGED_STATE) {
//        set the takeOff/Land button depending on the flying state
        switch state {
        case ARCOMMANDS_ARDRONE3_PILOTINGSTATE_FLYINGSTATECHANGED_STATE_LANDED:
//            (download media button not used)
            takeOffLandBt.setTitle("TakeOff", for: .normal)
            takeOffLandBt.isEnabled = true
            //downloadMediasBt.isEnabled = true
        case ARCOMMANDS_ARDRONE3_PILOTINGSTATE_FLYINGSTATECHANGED_STATE_FLYING, ARCOMMANDS_ARDRONE3_PILOTINGSTATE_FLYINGSTATECHANGED_STATE_HOVERING:
            takeOffLandBt.setTitle("Land", for: .normal)
            takeOffLandBt.isEnabled = true
            //downloadMediasBt.isEnabled = false
        default:
            takeOffLandBt.isEnabled = false
            //downloadMediasBt.isEnabled = false
        }
    }

    func bebopDrone(_ bebopDrone: BebopDrone?, configureDecoder codec: ARCONTROLLER_Stream_Codec_t) -> Bool {
//        enable video view (configure)
        return videoView.configureDecoder(codec)
    }

    func bebopDrone(_ bebopDrone: BebopDrone?, didReceive frame: UnsafeMutablePointer<ARCONTROLLER_Frame_t>) -> Bool {
//        enable video view (display video)
        return videoView.displayFrame(frame)
    }

    func bebopDrone(_ bebopDrone: BebopDrone?, didFoundMatchingMedias nbMedias: UInt) {
//        download media
        nbMaxDownload = Int(nbMedias)
        currentDownloadIndex = 1
        if nbMedias > 0 {
            downloadAlertController?.message = "Downloading medias"
            let customVC = UIViewController()
            downloadProgressView = UIProgressView(progressViewStyle: .default)
            downloadProgressView?.progress = 0
            customVC.view.addSubview(downloadProgressView!)
            customVC.view.addConstraint(
                NSLayoutConstraint(
                    item: downloadProgressView!,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: customVC.view,
                    attribute: .centerX,
                    multiplier: 1.0,
                    constant: 0.0)
                )
            customVC.view.addConstraint(
                NSLayoutConstraint(
                    item: downloadProgressView!,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: customVC.view.safeAreaLayoutGuide.bottomAnchor,
                    attribute: .top,
                    multiplier: 1.0,
                    constant: -20.0)
                )
            downloadAlertController?.setValue(customVC, forKey: "contentViewController")
        } else {
            downloadAlertController?.dismiss(animated: true, completion: {() -> Void in
                self.downloadProgressView = nil
                self.downloadAlertController = nil
            })
        }
    }
    
    func bebopDrone(_ bebopDrone: BebopDrone?, media mediaName: String?, downloadDidProgress progress: CInt) {
//        manage the download of the media
        let completedProgress = Float(currentDownloadIndex - 1) / Float(nbMaxDownload)
        let currentProgress = Float(Double(progress) / 100.0) / Float(nbMaxDownload)
        downloadProgressView?.progress = (completedProgress + currentProgress)
    }

    func bebopDrone(_ bebopDrone: BebopDrone?, mediaDownloadDidFinish mediaName: String?) {
//        check if the download is over
        currentDownloadIndex += 1
        if currentDownloadIndex > nbMaxDownload {
            downloadAlertController?.dismiss(animated: true, completion: {() -> Void in
                self.downloadProgressView = nil
                self.downloadAlertController = nil
            })
        }
    }

    // MARK: buttons click
    @IBAction func emergencyClicked(_ sender: Any) {
//        emergency button
        bebopDrone?.emergency()
    }

    @IBAction func takeOffLandClicked(_ sender: UIButton) {
//        takeOff/Land button (check flight state)
        switch bebopDrone?.flyingState() {
        case ARCOMMANDS_ARDRONE3_PILOTINGSTATE_FLYINGSTATECHANGED_STATE_LANDED:
            bebopDrone?.takeOff()
        case ARCOMMANDS_ARDRONE3_PILOTINGSTATE_FLYINGSTATECHANGED_STATE_FLYING, ARCOMMANDS_ARDRONE3_PILOTINGSTATE_FLYINGSTATECHANGED_STATE_HOVERING:
            bebopDrone?.land()
        default:
            break
        }
    }

    @IBAction func takePictureClicked(_ sender: Any) {
//        take picture button (not used)
        bebopDrone?.takePicture()
    }

    @IBAction func downloadMediasClicked(_ sender: Any) {
//        download media button (not used)
        downloadAlertController?.dismiss(animated: true) {() -> Void in }
        downloadAlertController = UIAlertController(title: "Download", message: "Fetching medias", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction?) -> Void in
            self.bebopDrone?.cancelDownloadMedias()
        })
        downloadAlertController?.addAction(cancelAction)
        let customVC = UIViewController()
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        customVC.view.addSubview(spinner)
        customVC.view.addConstraint(
            NSLayoutConstraint(
                item: spinner,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: customVC.view,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0.0)
            )
        customVC.view.addConstraint(
            NSLayoutConstraint(
                item: spinner,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: customVC.view.safeAreaLayoutGuide.bottomAnchor,
                attribute: .top,
                multiplier: 1.0,
                constant: -20.0)
            )
        downloadAlertController!.setValue(customVC, forKey: "contentViewController")
        present(downloadAlertController!, animated: true) {() -> Void in }
        bebopDrone?.downloadMedias()
    }

    @IBAction func gazUpTouchDown(_ sender: Any) {
//        move up when button is pressed
        bebopDrone?.setGaz(50)
    }
    
    @IBAction func gazUpTouchUp(_ sender: Any) {
//        stop the up move when the button is released
        bebopDrone?.setGaz(0)
    }

    @IBAction func gazDownTouchDown(_ sender: Any) {
//        move down when button is pressed
        bebopDrone?.setGaz(-50)
    }
    
    @IBAction func gazDownTouchUp(_ sender: Any) {
//        stop the down move when the button is released
        bebopDrone?.setGaz(0)
    }

    
    @IBAction func testButton(_ sender: Any){
//        this button execute a sequence of actions (take off, up 2sec, down 2sec, forward 2sec, backward 2sec, land)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
            self.bebopDrone?.takeOff()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.bebopDrone?.setGaz(50)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.bebopDrone?.setGaz(0)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: {
            self.bebopDrone?.setGaz(-50)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.0, execute: {
            self.bebopDrone?.setGaz(0)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 11.0, execute: {
            self.bebopDrone?.setFlag(1)
            self.bebopDrone?.setPitch(50)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.0, execute: {
            self.bebopDrone?.setFlag(0)
            self.bebopDrone?.setPitch(0)

        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
            self.bebopDrone?.setFlag(1)
            self.bebopDrone?.setPitch(-50)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 17.0, execute: {
            self.bebopDrone?.setFlag(0)
            self.bebopDrone?.setPitch(0)
            
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 19.0, execute: {
            self.bebopDrone?.land()
            
        })
        

    }

//    (yaw not used)

    @IBAction func yawLeftTouchDown(_ sender: Any) {
//       left rotation when button is pressed
        bebopDrone?.setYaw(-50)
    }
    
    @IBAction func yawLeftTouchUp(_ sender: Any) {
//        stop the left rotation when the button is released
        bebopDrone?.setYaw(0)
    }

    @IBAction func yawRightTouchDown(_ sender: Any) {
//       right rotation when button is pressed
        bebopDrone?.setYaw(50)
    }

    @IBAction func yawRightTouchUp(_ sender: Any) {
//        stop the right rotation when the button is released
        bebopDrone?.setYaw(0)
    }

    @IBAction func rollLeftTouchDown(_ sender: Any) {
//        move left when button is pressed
        bebopDrone?.setFlag(1)
        bebopDrone?.setRoll(-50)
    }
    
    @IBAction func rollLeftTouchUp(_ sender: Any) {
//        stop the left move when the button is released
        bebopDrone?.setFlag(0)
        bebopDrone?.setRoll(0)
    }

    @IBAction func rollRightTouchDown(_ sender: Any) {
//        move right when button is pressed
        bebopDrone?.setFlag(1)
        bebopDrone?.setRoll(50)
    }


    @IBAction func rollRightTouchUp(_ sender: Any) {
//        stop the right move when the button is released
        bebopDrone?.setFlag(0)
        bebopDrone?.setRoll(0)
    }

    @IBAction func pitchForwardTouchDown(_ sender: Any) {
//        move forward when button is pressed
        bebopDrone?.setFlag(1)
        bebopDrone?.setPitch(50)
    }
    
    @IBAction func pitchForwardTouchUp(_ sender: Any) {
//        stop the forward move when the button is released
        bebopDrone?.setFlag(0)
        bebopDrone?.setPitch(0)
    }

    @IBAction func pitchBackTouchDown(_ sender: Any) {
//        move backward when button is pressed
        bebopDrone?.setFlag(1)
        bebopDrone?.setPitch(-50)
    }


    @IBAction func pitchBackTouchUp(_ sender: Any) {
//        stop the backward move when the button is released
        bebopDrone?.setFlag(0)
        bebopDrone?.setPitch(0)
    }
    
    }

