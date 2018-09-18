// Copyright (C) 2016-2017 Parrot SA
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions
//    are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//    * Neither the name of Parrot nor the names
//      of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written
//      permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    SUCH DAMAGE.
//
//  Created by Nicolas CHRISTE, <nicolas.christe@parrot.com>

import UIKit
import PlaygroundSupport

@objc(MainViewController)
public class MainViewController: DroneViewControllerBase {
    
    // view background colors
    public enum Color {
        case green, blue
    }
    
    // factory
    public class func makeViewController(color: MainViewController.Color) -> UIViewController {
        let bundle = Bundle(for: MainViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "MainViewController") as! MainViewController
        viewController.color = color
        return viewController
    }
    
    // current view color. Must be set before view is loaded
    private var color = Color.green
    
    // content
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var drone: UIImageView!
    @IBOutlet weak var opLabel: UILabel!
    @IBOutlet weak var shadow: UIImageView!
    // background: background1 is the front background
    @IBOutlet weak var background1: UIImageView!
    @IBOutlet weak var background2: UIImageView!
    @IBOutlet weak var background3: UIImageView!
    @IBOutlet weak var background4: UIImageView!
    
    private var isFlying = false
    
    private enum DroneAnimation {
        case none, takingOff, landing, hovering
    }
    private var droneAnimation = DroneAnimation.none
    
    private enum OpAnimation {
        case none, moveIn, on, moveOut
    }
    private var opAnimation = OpAnimation.none
    private var currentOpText: String?
    
    private enum DroneImage {
        case none, rs, mars, travis, blaze, maclane, swat, mambo, mamboCannon, mamboGrabber
    }
    private var droneImage = DroneImage.none
    
    // offset when the drone is landed (from screen bottom)
    private let droneLandedOffset: CGFloat = 412
    // postion when drone is flying as ratio of content view size
    private let droneFlyingHightRatio: CGFloat = 5.5
    
    // shadow top  relative to the droneoffset
    private let shadowOffset: CGFloat = 148
    
    // offset between op label and drone
    private let opLabelDroneOffset: CGFloat = -16
    
    // background offsets when drone is landed (from screen the top)
    private let background1LandedOffset: CGFloat = 170
    private let background2LandedOffset: CGFloat = 150
    private let background3LandedOffset: CGFloat = 140
    private let background4LandedOffset: CGFloat = 155
    
    // background offsets when drone is flying (from screen bottom)
    private let background1FlyingOffset: CGFloat = 180
    private let background2FlyingOffset: CGFloat = 214
    private let background3FlyingOffset: CGFloat = 284
    private let background4FlyingOffset: CGFloat = 300
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: liveViewSafeAreaGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: liveViewSafeAreaGuide.trailingAnchor)])
        
        switch color {
        case .green:
            background1.image = #imageLiteral(resourceName: "chap1back1")
            background2.image = #imageLiteral(resourceName: "chap1back2")
            background3.image = #imageLiteral(resourceName: "chap1back3")
            background4.image = #imageLiteral(resourceName: "chap1back4")
            shadow.image = #imageLiteral(resourceName: "chap1shadow")
        case .blue:
            background1.image = #imageLiteral(resourceName: "chap2back1")
            background2.image = #imageLiteral(resourceName: "chap2back2")
            background3.image = #imageLiteral(resourceName: "chap2back3")
            background4.image = #imageLiteral(resourceName: "chap2back4")
            shadow.image = #imageLiteral(resourceName: "chap2shadow")
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // drone landed
        layoutWithDroneLanded()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.droneAnimation = .none
        drone.stopAnimating()
        coordinator.animate(alongsideTransition: nil) { _ in
            if self.isFlying {
                self.layoutWithDroneFlying()
                self.runHoveringAnimation()
            } else {
                self.layoutWithDroneLanded()
            }
        }
    }
    
    override func updateContent() {
        super.updateContent()
        if let droneModel = droneController.droneModel {
            drone.isHidden = false
            shadow.isHidden = false
            updateDroneIconAccessibilityLabel(
                model: droneModel.model, subModel: droneModel.subModel, hasCannon: droneController.cannonPlugged,
                hasGrabber: droneController.grabberPlugged, flyingState: droneController.flyingState)
            if updateDroneImage(
                model: droneModel.model, subModel: droneModel.subModel, hasCannon: droneController.cannonPlugged,
                hasGrabber: droneController.grabberPlugged) {
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, drone)
            }
            
        } else {
            drone.isHidden = true
            shadow.isHidden = true
        }
        updateCurrentOp(droneController.currentOp)
        updateDroneAnimation(droneController.flyingState)
    }
    
    private func updateDroneAnimation(_ state: FlyingState) {
        if state == .takingOff && !isFlying {
            isFlying = true
            runTakeOffAnimation()
        } else if (state == .landing || state == .emergency) && isFlying {
            isFlying = false
            runLandAnimation()
        }
    }
    
    private func updateDroneImage(model: Model, subModel: SubModel, hasCannon: Bool, hasGrabber: Bool) -> Bool {
        switch model {
        case .rollingSpider:
            if droneImage != .rs {
                drone.image = #imageLiteral(resourceName: "RS_white")
                droneImage = .rs
                return true
            }
        case .cargo:
            switch subModel {
            case .mars:
                if droneImage != .mars {
                    drone.image = #imageLiteral(resourceName: "Mars")
                    droneImage = .mars
                    return true
                }
            case .travis: fallthrough
            default:
                if droneImage != .travis {
                    drone.image = #imageLiteral(resourceName: "Travis")
                    droneImage = .travis
                    return true
                }
            }
        case .night:
            switch subModel {
            case .blaze:
                if droneImage != .blaze {
                    drone.image = #imageLiteral(resourceName: "Blaze")
                    droneImage = .blaze
                    return true
                }
            case .maclane:
                if droneImage != .maclane {
                    drone.image = #imageLiteral(resourceName: "Maclane")
                    droneImage = .maclane
                    return true
                }
            case .swat: fallthrough
            default:
                if droneImage != .swat {
                    drone.image = #imageLiteral(resourceName: "Swat")
                    droneImage = .swat
                    return true
                }
            }
        case .mambo:
            if hasCannon {
                if droneImage != .mamboCannon {
                    drone.image = #imageLiteral(resourceName: "mambo_cannon")
                    droneImage = .mamboCannon
                    return true
                }
            } else if hasGrabber {
                if droneImage != .mamboGrabber {
                    drone.image = #imageLiteral(resourceName: "mambo_grabber")
                    droneImage = .mamboGrabber
                    return true
                }
            } else {
                if droneImage != .mambo {
                    drone.image = #imageLiteral(resourceName: "mambo_single")
                    droneImage = .mambo
                    return true
                }
            }
        }
        return false
    }
    
    private func updateDroneIconAccessibilityLabel(
        model: Model, subModel: SubModel, hasCannon: Bool, hasGrabber: Bool, flyingState: FlyingState) {
        let droneName: String
        switch model {
        case .rollingSpider:
            droneName = NSLocalizedString("Rolling Spider Drone", comment: "Drone icon accessibility")
        case .cargo:
            switch subModel {
            case .mars:
                droneName = NSLocalizedString("Airborne Cargo Mars Drone", comment: "Drone icon accessibility")
            case .travis: fallthrough
            default:
                droneName = NSLocalizedString("Airborne Cargo Travis Drone", comment: "Drone icon accessibility")
            }
        case .night:
            switch subModel {
            case .blaze:
                droneName = NSLocalizedString("Airborne Night Blaze Drone", comment: "Drone icon accessibility")
            case .maclane:
                droneName = NSLocalizedString("Airborne Night Maclane Drone", comment: "Drone icon accessibility")
            case .swat: fallthrough
            default:
                droneName = NSLocalizedString("Airborne Night Swat Drone", comment: "Drone icon accessibility")
            }
        case .mambo:
            if hasCannon {
                droneName = NSLocalizedString("Mambo drone with cannon", comment: "Drone icon accessibility")
            } else if hasGrabber {
                droneName = NSLocalizedString("Mambo drone with grabber", comment: "Drone icon accessibility")
            } else {
                droneName = NSLocalizedString("Mambo drone", comment: "Drone icon accessibility")
            }
        }
        
        let flyingStateText: String
        switch flyingState {
        case .takingOff:
            flyingStateText = NSLocalizedString("Taking Off", comment: "Flying state accessibility")
        case .landing:
            flyingStateText = NSLocalizedString("Landing", comment: "Flying state accessibility")
        case .flying:
            flyingStateText = NSLocalizedString("Flying", comment: "Flying state accessibility")
        default:
            flyingStateText = NSLocalizedString("Landed", comment: "Flying state accessibility")
        }
        
        drone.accessibilityLabel = "\(droneName), \(flyingStateText)"
    }
    
    private func runTakeOffAnimation() {
        droneAnimation = .takingOff
        UIView.animate(withDuration: 5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0,
                       options: [.beginFromCurrentState], animations: {
                        self.drone.frame.origin.y = self.contentView.frame.size.height / self.droneFlyingHightRatio
        }, completion: { _ in
            if self.droneAnimation == .takingOff {
                self.runHoveringAnimation()
            }
        })
        UIView.animate(withDuration: 1, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.shadow.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.shadow.alpha = 0
        }, completion: { _ in
            self.shadow.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
        UIView.animate(withDuration: 2, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.background1.frame.origin.y = self.contentView.frame.size.height - self.background1FlyingOffset
        }, completion: nil)
        
        UIView.animate(withDuration: 1.8, delay: 0.2, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.background2.frame.origin.y = self.contentView.frame.size.height - self.background2FlyingOffset
        }, completion: nil)
        
        UIView.animate(withDuration: 1.6, delay: 0.4, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.background3.frame.origin.y = self.contentView.frame.size.height - self.background3FlyingOffset
        }, completion: nil)
        
        UIView.animate(withDuration: 1.4, delay: 0.6, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.background4.frame.origin.y = self.contentView.frame.size.height - self.background4FlyingOffset
        }, completion: nil)
    }
    
    private func runLandAnimation() {
        droneAnimation = .landing
        UIView.animate(withDuration: 1.5, delay: 0.15, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.drone.frame.origin.y = self.computeDroneLandedPos()
        }, completion: { _ in
            self.droneAnimation = .none
        })
        
        self.shadow.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.7, delay: 0.8, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.shadow.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.shadow.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.background4.frame.origin.y = self.background4LandedOffset
        }, completion: nil)
        
        UIView.animate(withDuration: 1.3, delay: 0.2, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.background3.frame.origin.y = self.background3LandedOffset
        }, completion: nil)
        
        UIView.animate(withDuration: 1.1, delay: 0.4, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.background2.frame.origin.y = self.background2LandedOffset
        }, completion: nil)
        
        UIView.animate(withDuration: 0.9, delay: 0.6, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.background1.frame.origin.y = self.background1LandedOffset
        }, completion: nil)
    }
    
    private func runHoveringAnimation() {
        droneAnimation = .hovering
        self.drone.frame.origin.y = self.contentView.frame.size.height / self.droneFlyingHightRatio
        UIView.animate(withDuration: 1, delay: 0, options:
            [.curveLinear, .autoreverse, .repeat, .beginFromCurrentState], animations: {
                self.drone.frame.origin.y = self.contentView.frame.size.height / self.droneFlyingHightRatio + 10
        }, completion: { _ in
            self.droneAnimation = .none
        })
    }
    
    private func layoutWithDroneLanded() {
        drone.frame.origin.y = computeDroneLandedPos()
        shadow.frame.origin.y = computeDroneLandedPos() + shadowOffset
        opLabel.frame.origin.y = drone.frame.origin.y + drone.frame.height + opLabelDroneOffset
        background4.frame.origin.y = background4LandedOffset
        background3.frame.origin.y = background3LandedOffset
        background2.frame.origin.y = background2LandedOffset
        background1.frame.origin.y = background1LandedOffset
    }
    
    private func layoutWithDroneFlying() {
        drone.frame.origin.y = contentView.frame.size.height / droneFlyingHightRatio
        shadow.frame.origin.y = computeDroneLandedPos() + shadowOffset
        opLabel.frame.origin.y = drone.frame.origin.y + drone.frame.height + opLabelDroneOffset
        background4.frame.origin.y = contentView.frame.size.height - background4FlyingOffset
        background3.frame.origin.y = contentView.frame.size.height - background3FlyingOffset
        background2.frame.origin.y = contentView.frame.size.height - background2FlyingOffset
        background1.frame.origin.y = contentView.frame.size.height - background1FlyingOffset
    }
    
    private func computeDroneLandedPos() -> CGFloat {
        let pos = contentView.frame.size.height - droneLandedOffset
        if pos + drone.frame.size.height/2 > contentView.frame.size.height/2 {
            return pos
        } else {
            return contentView.frame.size.height/2 - drone.frame.size.height/2
        }
    }
    
    private func updateCurrentOp(_ op: DroneController.Operation?) {
        
        func getOpText(_ op: DroneController.Operation?) -> String? {
            if let op = op {
                switch op {
                case .turn(let angle):
                    if angle < 0 {
                        return NSLocalizedString("Turn Left", comment: "turn(.left) command")
                    } else if angle > 0 {
                        return NSLocalizedString("Turn Right", comment: "turn(.right) command")
                    }
                case .move(let params, _):
                    if params.lateralSpeed != 0  && params.longitudinalSpeed == 0 &&
                        params.rotationSpeed == 0 && params.verticalSpeed == 0 {
                        if params.lateralSpeed < 0 {
                            return NSLocalizedString("Move left", comment: "move(.left) command")
                        } else {
                            return NSLocalizedString("Move Right", comment: "move(.right) command")
                        }
                    } else if params.lateralSpeed == 0  && params.longitudinalSpeed != 0 &&
                        params.rotationSpeed == 0 && params.verticalSpeed == 0 {
                        if params.longitudinalSpeed < 0 {
                            return NSLocalizedString("Move Backward", comment: "move(.backward) command")
                        } else {
                            return NSLocalizedString("Move Forward", comment: "move(.froward) command")
                        }
                    } else if params.lateralSpeed == 0  && params.longitudinalSpeed == 0 &&
                        params.rotationSpeed == 0 && params.verticalSpeed != 0 {
                        if params.verticalSpeed < 0 {
                            return NSLocalizedString("Move Down", comment: "move(.down) command")
                        } else {
                            return NSLocalizedString("Move Up", comment: "move(.up) command")
                        }
                    }
                    return NSLocalizedString("Move", comment: "move(pitch:roll:gaz:yaw:) command")
                case .flip(let direction):
                    switch direction {
                    case .back:
                        return NSLocalizedString("Back Flip", comment: "flip(.back) command")
                    case .front:
                        return NSLocalizedString("Front Flip", comment: "flip(.front) command")
                    case .left:
                        return NSLocalizedString("Left Flip", comment: "flip(.left) command")
                    case .right:
                        return NSLocalizedString("Right Flip", comment: "flip(.right) command")
                    }
                case .fireCannon:
                    return NSLocalizedString("Fire Cannon", comment: "fireCannon() command")
                case .openGrabber:
                    return NSLocalizedString("Open Grabber", comment: "openGrabber() command")
                case .closeGrabber:
                    return NSLocalizedString("Close Grabber", comment: "closeGrabber() command")
                case .takePicture:
                    return NSLocalizedString("Take Picture", comment: "takePicture() command")
                default: break
                }
            }
            return nil
        }
        
        func getErrorText(error: DroneController.OpError) -> String {
            switch error {
            case .flipLowBat:
                return NSLocalizedString("Battery level too low to Flip", comment: "error")
            case .noCannon:
                return NSLocalizedString("Cannon not attached", comment: "error")
            case .noGrabber:
                return NSLocalizedString("Grabber not attached", comment: "error")
            }
        }
        
        let opText: String?
        if let latestError = latestError {
            opText = getErrorText(error: latestError)
        } else if droneController.droneModel != nil && droneController.flyingState == .landed {
            opText = NSLocalizedString("Landed", comment: "Landed command text")
        } else {
            opText = getOpText(op)
        }
        if opText != currentOpText {
            currentOpText = opText
            switch opAnimation {
            case .none:
                runOpInAnimation()
            case .on:
                runOpOutAnimation()
            default: break
            }
        }
    }
    
    private func runOpInAnimation() {
        if let text  = currentOpText {
            opLabel.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            opLabel.alpha = 0
            opLabel.text = currentOpText
            opLabel.isHidden = false
            if latestError != nil {
                opLabel.frame.origin.y = drone.frame.origin.y + drone.frame.height + opLabelDroneOffset
                opLabel.textColor = UIColor.red
            } else if isFlying {
                opLabel.frame.origin.y = contentView.frame.size.height / droneFlyingHightRatio
                    + drone.frame.height + opLabelDroneOffset
                opLabel.textColor = UIColor(red: 69.0/255, green: 86.0/255, blue: 89.0/255, alpha: 1)
            } else {
                opLabel.frame.origin.y = drone.frame.origin.y + drone.frame.height + opLabelDroneOffset
                opLabel.textColor = UIColor.white
            }
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, opLabel)
            opAnimation = .moveIn
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0,
                           options: [], animations: {
                            self.opLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                            self.opLabel.alpha = 1
            }, completion: { _ in
                self.opAnimation = .on
                if self.currentOpText != text {
                    self.runOpOutAnimation()
                }
            })
        }
    }
    
    private func runOpOutAnimation() {
        opAnimation = .moveOut
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
            self.opLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.opLabel.alpha = 0
        }, completion: { _ in
            self.opAnimation = .none
            self.opLabel.isHidden = true
            if self.currentOpText != nil {
                self.runOpInAnimation()
            }
        })
    }
}
