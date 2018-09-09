//
//  FlightPlanVC.swift
//  DroneProgrammer
//
//  Created by CUI on 08.07.18.
//  Copyright © 2018 CUI. All rights reserved.
//

import UIKit


class FlightPlanVC: UIViewController, BebopDroneDelegate, UIAlertViewDelegate {
//    create the view controller of the flight plan view (see in the storyboard)
    
    var connectionAlertView: UIAlertController?
    var downloadAlertController: UIAlertController?
    var downloadProgressView: UIProgressView?
    var bebopDrone: BebopDrone?
    var stateSem: DispatchSemaphore?
    var nbMaxDownload: Int = 0
    var currentDownloadIndex: Int = 0
    var errorAlertView: UIAlertController?
    
    //
    var line: Int = 1
    
    let inter = Interpreter.init() // init Interpreter
    
    var tabCmd : [String] = [] // definition of the command name array
    
    var testEnterCmdTab : [String] = []
    var testInd: Int = 0
    
    var tabLengthCmd : [Double] = [] // definition of the command time array
    let time : [String] =  ["0","1","2","3","4","5","6","7","8","9"]
    
    var nbObs : Int = 0 // initialization the number of obstacles
    var tabObs: Array<Array<Double>> = [] // declaration of the obstacles coordinates array : [[x,y,z], [x,y,z], ...]
    var obsNumero: Int = 0
    var zone : [Int] = [-1000, 1000, -1000, 1000, -1000, 1000] // initialization of the area (max range)
    
    let moinsInfinity = -1000
    let plusInfinity = 1000
    var xMin = -1000
    var xMax = 1000
    var yMin = -1000
    var yMax = 1000
    var zMin = -1000
    var zMax = 1000
    
    var resTest : Bool = true // bool to know the result of "try flight plan"
    
    let listeAction : [String] = ["TAKE OFF()", "TAKEOFF()", "LAND()", "FORWARD()", "BACKWARD()", "LEFT()", "RIGHT()", "UP()", "DOWN()"] // definition of instructions name array
    
    // arrays declaration for "exec flight plan"
    var tabExec : [Int] = []
    var resTabExec : [Int] = []
    var tempsExec: Double = 0.0 // manage the execution time of an instruction
    var indexExec: Int = 0
    
    var service: ARService!
    
    @objc
    func setService(_ service: ARService) {
//        connection to a service
        self.service = service
    }
    
//    (you can use additional buttons)
//    @IBOutlet var videoView: H264VideoView!
//    @IBOutlet var batteryLabel: UILabel!
//    @IBOutlet var takeOffLandBt: UIButton!
//    @IBOutlet var downloadMediasBt: UIButton!
        
//  elements of the view controller
    @IBOutlet var progView: UITextView!
    @IBOutlet var obstacleEntry: UITextField!
    @IBOutlet var coordoEntryX: UITextField!
    @IBOutlet var coordoEntryY: UITextField!
    @IBOutlet var coordoEntryZ: UITextField!
    @IBOutlet var limXmin: UITextField!
    @IBOutlet var limXmax: UITextField!
    @IBOutlet var limYmin: UITextField!
    @IBOutlet var limYmax: UITextField!
    @IBOutlet var limZmin: UITextField!
    @IBOutlet var limZmax: UITextField!
    

    override func viewDidLoad() {
//        initialize the connection between the drone and the device (when the view is loaded)
        super.viewDidLoad()
        
        obstacleEntry.delegate = self
        coordoEntryX.delegate = self
        coordoEntryY.delegate = self
        coordoEntryZ.delegate = self
        limXmin.delegate = self
        limYmin.delegate = self
        limZmin.delegate = self
        limXmax.delegate = self
        limYmax.delegate = self
        limZmax.delegate = self
        
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
//        when the view appears, display an alert view if the device is not connected
        super.viewDidAppear(animated)
        if bebopDrone?.connectionState() != ARCONTROLLER_DEVICE_STATE_RUNNING {
            connectionAlertView?.show(connectionAlertView!,
                                      sender: connectionAlertView!)
        }
    }


    override func viewDidDisappear(_ animated: Bool) {
//        disconnect the drone if we leave the view
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
//        (not used)
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

    // MARK: buttons click
    
    @IBAction func emergency(_ sender: Any) {
//        cut off the motor
        bebopDrone?.emergency()
    }
    
    
    @IBAction func testClicked(_ sender: Any) {
//      link to the "validate instruction button"
//      call the function enterClicked() for each elements
        tabCmd = []
        tabLengthCmd = []
        testEnterCmdTab = []
        
//      retrieve each instruction in the text view
        for char in (progView.text.uppercased().replacingOccurrences(of: " ", with: "").components(separatedBy: "\n")) {
            print(char)
            // instert in the instruction array in the form : [name_instruction(null ou int), ...]
            testEnterCmdTab.append(char)
        }
        
        // go through the array, remove the empty instructions
        for elt in testEnterCmdTab {
            if (elt == "") {
                testEnterCmdTab.remove(at: testEnterCmdTab.index(of: "")!)
            }
            enterClicked(entryCommand: elt)
        }
    }
    
    
    
    func enterClicked(entryCommand: String) {
//      test if the flight plan is correctly written and fill the instruction array and the command time array
        
        // case of an empty instruction
        if (entryCommand == "") {
            print("Empty instruction is equal to no operation")
        }
//      if the instructions array is empty, the first instruction must be "takeoff()"
        else if (tabCmd.isEmpty == true) {
//          retrieve the instruction in the variable "tempoEntry"
            let tempoEntry = entryCommand.uppercased().replacingOccurrences(of: "[ 0123456789]", with: "", options: .regularExpression, range: nil)
            // case of a "takeoff()" or "TAKEOFF()" or "take off()"
            if (tempoEntry == "TAKE OFF()" || tempoEntry == "TAKEOFF()") {
//              append 3 sec in commands time array and the command name in the command array
                tabLengthCmd.append(3.0)
                print("length of instr: \(tabLengthCmd)")
                tabCmd.append(tempoEntry)
            } else {
                // alert view: takeoff missed error
                errorAlertView = UIAlertController(
                    title: "Error in instruction input",
                    message: "The first instruction must be: 'TAKE OFF()'",
                    preferredStyle: .alert)
                errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlertView!, animated: true, completion: nil)
                print("Error in instruction input")
                print("The first instruction must be: 'TAKE OFF()'")
            }
        // if the prog view is not empty
        } else if (tabCmd.isEmpty == false && tabCmd.last != "LAND()") {
            // retrieve the command name
            let tempoEntry = entryCommand.uppercased().replacingOccurrences(of: "[ 0123456789]", with: "", options: .regularExpression, range: nil)
            // retrive the instruction time
            let getLengthCmd = entryCommand.uppercased().replacingOccurrences(of: "[ ABCDEFGHIJKLMNOPQRSTUVWXYZ()]", with: "", options: .regularExpression, range: nil)
            
            // if there are two "takeoff()" following
            if (tempoEntry == "TAKEOFF()" || tempoEntry == "TAKE OFF()") && (tabCmd.last == "TAKE OFF()" || tabCmd.last == "TAKEOFF()") {
                // alert view: invalid sequence
                errorAlertView = UIAlertController(
                    title: "Error in instruction input",
                    message: "The instruction 'TAKE OFF()' cannot be launched after a 'TAKE OFF()' instruction",
                    preferredStyle: .alert)
                errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlertView!, animated: true, completion: nil)
                print("Error in instruction input")
                print("The instruction 'TAKE OFF()' cannot be launched after a 'TAKE OFF()' instruction")
            }
            // if the next instrucion is anything exept a "takeoff()"
            else if (listeAction.contains(tempoEntry)) {
                // case of a "land"
                if (tempoEntry == "LAND()") {
                    // FIXME: put the right time lapse to execute the landing properly at any position
                    // here we put 3 sec for the landing
                    tabLengthCmd.append(3.0)
                    print("length of instr: \(tabLengthCmd)")
                    tabCmd.append(tempoEntry)
                } else {
                    // case of anything else
                    // retrieve execution time
                    let getLengthCmdToDouble = Double(getLengthCmd)!
                    tabLengthCmd.append(getLengthCmdToDouble)
                    print("length of instr: \(tabLengthCmd)")
                    tabCmd.append(tempoEntry)
                }
            } else {
                // alert view: the instruction must be in the list
                errorAlertView = UIAlertController(
                    title: "Error in instruction input",
                    message: "Instructions must be contains in the list of instructions",
                    preferredStyle: .alert)
                errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlertView!, animated: true, completion: nil)
                print("Error in instruction input")
                print("Instructions must be contains in the list of instructions")
            }
            
        // if the last instruction is a "land()"
        } else if (tabCmd.isEmpty == false && tabCmd.last == "LAND()") {
            let tempoEntry = entryCommand.uppercased().replacingOccurrences(of: "[ 0123456789]", with: "", options: .regularExpression, range: nil)
            
            // if there are two "land()" following
            if (tempoEntry == "LAND()") {
                // alert view: error
                errorAlertView = UIAlertController(
                    title: "Error in instruction input",
                    message: "The instruction 'LAND()' cannot be launched after a 'LAND()' instruction",
                    preferredStyle: .alert)
                errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlertView!, animated: true, completion: nil)
                print("Error in instruction input")
                print("The instruction 'LAND()' cannot be launched after a 'LAND()' instruction")
            }
            
            // after a land, the next instruction must be "takeoff()" or nothing
            else if (listeAction.contains(tempoEntry)) {
                if (tempoEntry == "TAKE OFF()" || tempoEntry == "TAKEOFF()"  || tempoEntry == "") {
                    tabLengthCmd.append(3.0)
                    print("length of instr: \(tabLengthCmd)")
                    tabCmd.append(tempoEntry)
                } else {
                    errorAlertView = UIAlertController(
                        title: "Error in instruction input",
                        message: "The instruction after 'LAND()' must be 'TAKE OFF()' or nothing",
                        preferredStyle: .alert)
                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlertView!, animated: true, completion: nil)
                    print("Error in instruction input")
                    print("The instruction after 'LAND()' must be 'TAKE OFF()' or nothing")
                }
            } else {
                // else: syntaxe error
                errorAlertView = UIAlertController(
                    title: "Error in instruction input",
                    message: "Instructions must be contains in the list of instructions",
                    preferredStyle: .alert)
                errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlertView!, animated: true, completion: nil)
                print("Error in instruction input")
                print("Instructions must be contains in the list of instructions")
            }
        } else {
            print("Unknow error")
        }
        
        print("Instructions:", tabCmd)
    }
    
    func isStringAnInt(string: String) -> Bool {
//        test if the string is an integer
        return Int(string) != nil
    }
    
    @IBAction func enterNumbObs(_ sender: Any) {
//        button to enter the number of obstacle
        nbObs = 0
        tabObs = []
        
        let tmpBoolObs = isStringAnInt(string: obstacleEntry.text!)
        if (tmpBoolObs == true) {
            nbObs = Int(obstacleEntry.text!)!
        } else {
            errorAlertView = UIAlertController(
                title: "Error in obstacle input",
                message: "Please enter an integer",
                preferredStyle: .alert)
            errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlertView!, animated: true, completion: nil)
            print("error")
        }
        
        print("Number of obstacle: \(nbObs)")
        tabObs = Array(repeating: Array(repeating: 0, count: 3), count: nbObs)
        print("Initial obstacle's array: \(tabObs)")
    }
    

    @IBAction func insertObs(_ sender: Any) {
        // button to fill the obstacle array
        tabObs = enterObstacle(tableauObstacle: tabObs)
    }
    
    @IBAction func failInsertObs(_ sender: Any) {
//        button to reset obstacles in the array
        tabObs = Array(repeating: Array(repeating: 0, count: 3), count: nbObs)
        print("reset obstacle's coordonates: \(tabObs)")
        obsNumero = 0
    }
    
    @IBAction func enterLimitZone(_ sender: Any) {
//        button to initialize the limit zone
        zone = []
        
        let tmpValXMin = isStringAnInt(string: limXmin.text!)
        let tmpValXMax = isStringAnInt(string: limXmax.text!)
        let tmpValYMin = isStringAnInt(string: limYmin.text!)
        let tmpValYMax = isStringAnInt(string: limYmax.text!)
        let tmpValZMin = isStringAnInt(string: limZmin.text!)
        let tmpValZMax = isStringAnInt(string: limZmax.text!)
        
        if (tmpValXMin == true && tmpValXMax == true && tmpValYMin == true && tmpValYMax == true && tmpValZMin == true && tmpValZMax == true) {
            xMin = Int(limXmin.text!)!
            xMax = Int(limXmax.text!)!
            yMin = Int(limYmin.text!)!
            yMax = Int(limYmax.text!)!
            zMin = Int(limZmin.text!)!
            zMax = Int(limZmax.text!)!
        } else {
            errorAlertView = UIAlertController(
                title: "Error in coordonate input",
                message: "Please enter a number",
                preferredStyle: .alert)
            errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlertView!, animated: true, completion: nil)
            print("error")
        }
        
        // fill the zone
        zone.append(xMin)
        zone.append(xMax)
        zone.append(yMin)
        zone.append(yMax)
        zone.append(zMin)
        zone.append(zMax)
        // [XMIN, XMAX, YMIN, YMAX, ZMIN, ZMAX]
        
//      test if the coordonates are properly set
        if (xMin > xMax) {
            zone.removeAll()
            print("xMin must be lower or equal to xMax")
        } else if (yMin > yMax) {
            zone.removeAll()
            print("yMin must be lower or equal to yMax")
        } else if (zMin > zMax) {
            zone.removeAll()
            print("zMin must be lower or equal to zMax")
        } else {
            print("Coordonates of the zone: \(zone)")
        }
    }
    
    @IBAction func failLimitZone(_ sender: Any) {
//        remove the limit zone if an error is found
        zone.removeAll()
        print("reset zone: \(zone)")
    }
    
    
    @IBAction func tryPlan(_ sender: Any) {
//        button tryPlan
//        call the function "testObstacle()" in "Interpreter.swift" and give if the flight plan has passed the test
        resTest = inter.testObstacle(tabCommande: tabCmd, tabLengthCommand: tabLengthCmd, tabObstacle: tabObs, zoneLim: zone)
        
        // if the tests fail
        if (resTest == false) {
            // remove the instructions
            tabCmd.removeAll()
            errorAlertView = UIAlertController(
                title: "Error in flight plan",
                message: "Your flight plan didn't pass the test",
                preferredStyle: .alert)
            errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlertView!, animated: true, completion: nil)
            print("\nreset the array of instruction: \(tabCmd)")
            progView.text! = ""
            line = 1
            
        } else {
            // else the tests pass
            errorAlertView = UIAlertController(
                title: "Your flight plan passed tests successfully",
                message: nil,
                preferredStyle: .alert)
            errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlertView!, animated: true, completion: nil)
            print("\nYour flight plan passed tests successfully")
        }
    }
    
    func enterObstacle(tableauObstacle: [[Double]]) -> [[Double]] {
//        function to enter the obstacles coordonates and give the coordinates array
        var tmpTabObs = tableauObstacle
        print("avant remplissage: \(tmpTabObs)")
        
//        (rounded)
        let obsX = Double(coordoEntryX.text!)!.rounded()
        print(obsX)
        let obsY = Double(coordoEntryY.text!)!.rounded()
        print(obsY)
        let obsZ = Double(coordoEntryZ.text!)!.rounded()
        print(obsZ)
        
        if (obsNumero < nbObs) {
            tmpTabObs[obsNumero][0] = obsX
            tmpTabObs[obsNumero][1] = obsY
            tmpTabObs[obsNumero][2] = obsZ
            
            if (obsX == 0 && obsY == 0 && obsZ == 0) {
                print("please input a valide obstacle, [0,0,0] is the initial position of the drone: it cannot be an obstacle")
                print("apres remplissage: \(tmpTabObs)")
            } else {
                obsNumero += 1
                print("apres remplissage: \(tmpTabObs)")
            }
        } else {
            print("Coordonate of every obstacle are done")
            print("apres remplissage: \(tmpTabObs)")
        }
        return tmpTabObs
    }
    
    @IBAction func executePlan(_ sender: Any) {
//      button to execute the flight plan, call the function "execPlan()" in Interpreter.swift
        if (resTest == true) {
            
            resTabExec = inter.execPlan(tabCommande: tabCmd, tabExecution: tabExec)
            print(resTabExec)
            print("\nFLYING STATE:\n 0: landed state\n 1: taking off state \n 2: hovering\n 3: flying state\n 4: landing state\n 5: emergency state\n 6: user take off state\n 7: motor ramping state\n 8: emergency landing state\n\n")
            tempsExec = 0.0

//      for each instruction of the array (here represented by an interger), we use the tabLenghthCmd (contains the time of the instruction) with DispatchQueue asyncAfter to determine when and which instruction will be executed (because                                 all is executed at the same time)
            for instruction in resTabExec {
                
                print("instruction num \(indexExec) at time: \(tempsExec)")
                switch (instruction) {
                    case 0:
                        // takeOff()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + tempsExec + tabLengthCmd[indexExec], execute: {
                            NSLog("takeOff")
                            self.bebopDrone?.takeOff()
                        })
                        // FIXME: time of the execution
                        tempsExec = tempsExec + 4.0 /*tabLengthCmd[indexExec]*/
                        indexExec += 1
                        
                        break
                    
                    case 1:
                        // land()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec + tabLengthCmd[indexExec], execute: {
                            // FIXME: time of the execution
                            NSLog("land")
                            self.bebopDrone?.land()
                        })
                        tempsExec = tempsExec + 5.0/*tabLengthCmd[indexExec]*/
                        indexExec += 1
                        
                        break
                    case 2:
                        // rollRightTouchDown()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec, execute: {
                            NSLog("begin right")
                            self.bebopDrone?.setFlag(1)
                            self.bebopDrone?.setRoll(50)
                        })
                        print("instr tempo \(tempsExec + tabLengthCmd[indexExec])")
                        DispatchQueue.main.asyncAfter(deadline: .now()  + 2.0 + tempsExec + tabLengthCmd[indexExec], execute: {
                            // rollRightTouchUp()
                            self.bebopDrone?.setFlag(0)
                            self.bebopDrone?.setRoll(0)
                            NSLog("end right")
                        })
                        tempsExec = tempsExec + tabLengthCmd[indexExec] + 3
                        indexExec += 1
                        
                        break
                    case 3:
                        // rollLeftTouchDown()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec, execute: {
                            NSLog("begin left")
                            self.bebopDrone?.setFlag(1)
                            self.bebopDrone?.setRoll(-50)
                        })
                        print("instr tempo \(tempsExec + tabLengthCmd[indexExec])")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec + tabLengthCmd[indexExec], execute: {
                            // rollLeftTouchUp()
                            self.bebopDrone?.setFlag(0)
                            self.bebopDrone?.setRoll(0)
                            NSLog("end left")
                        })
                        tempsExec = tempsExec + tabLengthCmd[indexExec] + 3
                        indexExec += 1
                        
                        break
                    case 4:
                        // pitchForwardTouchDown()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec, execute: {
                            NSLog("begin front")
                            self.bebopDrone?.setFlag(1)
                            self.bebopDrone?.setPitch(50)
                        })
                        print("instr tempo \(tempsExec + tabLengthCmd[indexExec])")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec + tabLengthCmd[indexExec], execute: {
                            // pitchForwardTouchUp()
                            self.bebopDrone?.setFlag(0)
                            self.bebopDrone?.setPitch(0)
                            NSLog("end front")
                        })
                        tempsExec = tempsExec + tabLengthCmd[indexExec] + 3
                        indexExec += 1
                        
                        break
                    case 5:
                        // pitchBackTouchDown()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec, execute: {
                            NSLog("begin back")
                            self.bebopDrone?.setFlag(1)
                            self.bebopDrone?.setPitch(-50)
                        })
                        print("instr tempo \(tempsExec + tabLengthCmd[indexExec])")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec + tabLengthCmd[indexExec], execute: {
                            // pitchBackTouchUp()
                            self.bebopDrone?.setFlag(0)
                            self.bebopDrone?.setPitch(0)
                            NSLog("end back")
                        })
                        tempsExec = tempsExec + tabLengthCmd[indexExec] + 4
                        indexExec += 1
                        
                        break
                    case 6:
                        // gazUpTouchDown()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec, execute: {
                            NSLog("begin up")
                            self.bebopDrone?.setGaz(50)
                        })
                        print("instr tempo \(tempsExec + tabLengthCmd[indexExec])")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec + tabLengthCmd[indexExec], execute: {
                            // gazUpTouchUp()
                            self.bebopDrone?.setGaz(0)
                            NSLog("end up")
                        })
                        tempsExec = tempsExec + tabLengthCmd[indexExec] + 3
                        indexExec += 1
                        
                        break
                    case 7:
                        // gazDownTouchDown()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec, execute: {
                            NSLog("begin down")
                            self.bebopDrone?.setGaz(-50)
                        })
                        print("instr tempo \(tempsExec + tabLengthCmd[indexExec])")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + tempsExec + tabLengthCmd[indexExec], execute: {
                            // gazDownTouchUp()
                            self.bebopDrone?.setGaz(0)
                            NSLog("end down")
                        })
                        tempsExec = tempsExec + tabLengthCmd[indexExec] + 3
                        indexExec += 1
                        
                        break
                    default:
                        break
                }
            }
 
        } else {
            errorAlertView = UIAlertController(
                title: "Error at execution",
                message: "impossible to execute the flight plan because the plan don't passed test with success",
                preferredStyle: .alert)
            errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlertView!, animated: true, completion: nil)
            print("impossible to execute the flight plan because the plan don't passed test with success")
        }
        
    }
    
    
    
    
    // ---------- Func for button execute ------------
    
    func emergencyClicked() {
        bebopDrone?.emergency()
    }
    
    func takeOff() {
        bebopDrone?.takeOff()
    }
    
    func land() {
        bebopDrone?.land()
    }
    
    func gazUpTouchDown() {
        bebopDrone?.setGaz(50)
    }
    
    func gazDownTouchDown() {
        bebopDrone?.setGaz(-50)
    }
    
    func gazUpTouchUp() {
        bebopDrone?.setGaz(0)
    }
    
    func gazDownTouchUp() {
        bebopDrone?.setGaz(0)
    }
    
    /*func yawLeftTouchDown() {
        bebopDrone?.setYaw(-50)
    }
    
    func yawRightTouchDown() {
        bebopDrone?.setYaw(50)
    }
    
    func yawLeftTouchUp() {
        bebopDrone?.setYaw(0)
    }
    
    func yawRightTouchUp() {
        bebopDrone?.setYaw(0)
    }*/
    
    func rollLeftTouchDown() {
        bebopDrone?.setFlag(1)
        bebopDrone?.setRoll(-50)
    }
    
    func rollRightTouchDown() {
        bebopDrone?.setFlag(1)
        bebopDrone?.setRoll(50)
    }
    
    func rollLeftTouchUp() {
        bebopDrone?.setFlag(0)
        bebopDrone?.setRoll(0)
    }
    
    func rollRightTouchUp() {
        bebopDrone?.setFlag(0)
        bebopDrone?.setRoll(0)
    }
    
    func pitchForwardTouchDown() {
        bebopDrone?.setFlag(1)
        bebopDrone?.setPitch(50)
    }
    
    func pitchBackTouchDown() {
        bebopDrone?.setFlag(1)
        bebopDrone?.setPitch(-50)
    }
    
    func pitchForwardTouchUp() {
        bebopDrone?.setFlag(0)
        bebopDrone?.setPitch(0)
    }
    
    func pitchBackTouchUp() {
        bebopDrone?.setFlag(0)
        bebopDrone?.setPitch(0)
    }
}

extension FlightPlanVC : UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

























