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
import PlaygroundBluetooth
import CoreBluetooth

/// Abstract class for all drone views
public class DroneViewControllerBase: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    
    fileprivate (set) var liveViewConnectionOpened = false
    
    // latest operation error
    fileprivate(set) var latestError: DroneController.OpError?
    
    // drone controller
    let droneController = DroneController()
    // motion tracker
    fileprivate let motionTracker = MotionTracker()
    
    // PlaygroundBluetooth view
    fileprivate(set) var btView: PlaygroundBluetoothConnectionView?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        droneController.delegate = self
        motionTracker.delegate = self
        btView = PlaygroundBluetoothConnectionView(centralManager: droneController.ble.btManager)
        view.addSubview(btView!)
        NSLayoutConstraint.activate(
            [btView!.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 20),
             btView!.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)])
        btView?.delegate = self
        btView?.dataSource = self
        
        if myDrone != nil {
            if !droneController.ble.btManager.connectToLastConnectedPeripheral() {
                myDrone = nil
            }
        }
        updateContent()
    }
    
    func updateContent() {
        if let peripheral = droneController.ble.peripheral {
            switch droneController.batteryLevel {
            case .unknown:
                btView?.setBatteryLevel(nil, forPeripheral: peripheral)
            case .level(let percent, _):
                btView?.setBatteryLevel(Double(percent)/100.0, forPeripheral: peripheral)
            }
        }
    }
    
    fileprivate final func sendConnectionStatus() {
        send(event: .connected(droneController.connectionState == .connected))
    }
    
    fileprivate final func sendStatus() {
        send(event: .status(
            flyingState: droneController.flyingState,
            hasCannon: droneController.cannonPlugged,
            hasGrabber: droneController.grabberPlugged))
    }
}

/// Handle drone controller events
extension DroneViewControllerBase: DroneControllerDelegate {
    
    final func droneControllerDidFindDrone(droneModel: DroneModel) {
        DispatchQueue.main.async {
            self.updateContent()
        }
    }
    
    func droneControllerDidStop() {
        latestError = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateContent()
        }
    }
    
    func droneFirmwareOutOfDate() {
        DispatchQueue.main.async {
            if let peripheral = self.droneController.ble.peripheral {
                self.btView?.setFirmwareStatus(.outOfDate, forPeripheral: peripheral)
            }
        }
    }
    
    final func droneControllerConnectionStateDidChange(_ connectionState: DroneController.ConnectionState) {
        sendStatus()
        sendConnectionStatus()
        DispatchQueue.main.async {
            self.updateContent()
        }
    }
    
    final func droneControllerStateDidChange() {
        sendStatus()
        DispatchQueue.main.async {
            self.updateContent()
        }
    }
    
    final func opTerminated(error: DroneController.OpError?) {
        if let error = error {
            latestError = error
            DispatchQueue.main.async {
                self.updateContent()
            }
        }
        sendStatus()
        send(event: .cmdCompleted)
    }
    
    func motionTrackerStarted() {
    }
    
    func motiontrackerUpdate(lateralAngle: Int, longitudinalAngle: Int, lastEvent: MotionEvent) {
    }
    
    func motionTrackerEvent(_ event: MotionEvent) {
    }
}

extension DroneViewControllerBase: MotionTrackerDelegate {
    
    final func motionUpdate(lateralAngle: Int, longitudinalAngle: Int, lastEvent: MotionEvent) {
    }
    
    final func motionEvent(_ event: MotionEvent) {
        send(event: .motionEvent(event: event))
    }
}

extension DroneViewControllerBase: PlaygroundLiveViewMessageHandler {
    
    final  public func liveViewMessageConnectionOpened() {
        liveViewConnectionOpened = true
        latestError = nil
        updateContent()
    }
    
    final  public func liveViewMessageConnectionClosed() {
        liveViewConnectionOpened = false
        droneController.execute(op: .land)
        motionTracker.stop()
        updateContent()
    }
    
    final  public func receive(_ message: PlaygroundValue) {
        if let cmd = DroneViewProxy.Cmd(value: message) {
            switch cmd {
            case .getState:
                send(event: .status(
                    flyingState: droneController.flyingState,
                    hasCannon: droneController.cannonPlugged,
                    hasGrabber: droneController.grabberPlugged))
                send(event: .connected(droneController.connectionState == .connected))
                send(event: .cmdCompleted)
            case .takeOff:
                droneController.execute(op: .takeOff)
            case .land:
                droneController.execute(op: .land)
            case .turn(let angle):
                droneController.execute(op: .turn(angle: angle))
            case .move(let params, let duration):
                droneController.execute(op: .move(params: params, duration: duration))
            case .stopMoving:
                droneController.execute(op: .stopMoving)
            case .flip(let direction):
                droneController.execute(op: .flip(direction: direction))
            case .fireCannon:
                droneController.execute(op: .fireCannon)
            case .openGrabber:
                droneController.execute(op: .openGrabber)
            case .closeGrabber:
                droneController.execute(op: .closeGrabber)
            case .takePicture:
                droneController.execute(op: .takePicture)
            case .startMotionTracker:
                motionTracker.start()
                break
            }
        }
    }
    
    final  func send(event: DroneViewProxy.Evt) {
        if liveViewConnectionOpened {
            send(event.marshal())
        }
    }
}

extension DroneViewControllerBase: PlaygroundBluetoothConnectionViewDataSource {
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView,
                               itemForPeripheral peripheral: CBPeripheral,
                               withAdvertisementData advertisementData: [String : Any]?)
        -> PlaygroundBluetoothConnectionView.Item {
            // Provide display information associated with a peripheral item.
            let name = peripheral.name ?? ""
            let icon: UIImage
            if let advertisementData = advertisementData,
                let model = DroneBle.modelFrom(advertisementData: advertisementData) {
                icon = iconFor(model: model)
                droneController.ble.setModel(model, forPeripheral: peripheral)
            } else if let model = myDrone?.model {
                icon = iconFor(model: model)
            } else {
                icon = #imageLiteral(resourceName: "mambo_bt")
            }
            return PlaygroundBluetoothConnectionView.Item(name: name, icon: icon, issueIcon: icon,
                                                          firmwareStatus: nil, batteryLevel: nil)
    }
    
    func iconFor(model: Model) -> UIImage {
        switch model {
        case .cargo:
            return #imageLiteral(resourceName: "cargo_bt")
        case .night:
            return #imageLiteral(resourceName: "night_bt")
        case .mambo:
            return #imageLiteral(resourceName: "mambo_bt")
        case .rollingSpider:
            return #imageLiteral(resourceName: "spider_bt")
        }
    }
}

extension DroneViewControllerBase: PlaygroundBluetoothConnectionViewDelegate {
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView,
                               shouldDisplayDiscovered peripheral: CBPeripheral,
                               withAdvertisementData advertisementData: [String : Any]?, rssi: Double) -> Bool {
        if let advertisementData = advertisementData, peripheral.name != nil {
            return DroneBle.modelFrom(advertisementData: advertisementData) != nil
        }
        return false
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView,
                               titleFor state: PlaygroundBluetoothConnectionView.State) -> String {
        // Provide a localized title for the given state of the connection view.
        switch state {
        case .noConnection:
            return NSLocalizedString("Connect Drone", comment: "bt connect title")
        case .connecting:
            return NSLocalizedString("Connecting Drone", comment: "bt connect title")
        case .searchingForPeripherals:
            return NSLocalizedString("Searching for Drone", comment: "bt connect title")
        case .selectingPeripherals:
            return NSLocalizedString("Select a Drone", comment: "bt connect title")
        case .connectedPeripheralFirmwareOutOfDate:
            return NSLocalizedString("Connect to a Different Drone", comment: "bt connect title")
        }
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView,
                               firmwareUpdateInstructionsFor peripheral: CBPeripheral) -> String {
        // Provide firmware update instructions.
        return NSLocalizedString("To update your drone, please visit [this link](https://www.parrot.com/support)",
                                 comment: "firmware update instructions")
    }
}
