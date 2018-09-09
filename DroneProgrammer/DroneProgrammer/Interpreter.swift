//
//  Interpreter.swift
//  DroneProgrammer
//
//  Created by CUI on 10.07.18.
//  Copyright © 2018 CUI. All rights reserved.
//

import Foundation
import UIKit

class Interpreter: UIAlertController{
//    for each instruction executed, it sets theorical coordinates of the drone as a three dimension point
//    for example: the position (2,3,1) mean the drone is approximatly at x=2m, y=3m and z=1m relative to a starting point (0,0,0)
    
    var errorAlertView: UIAlertController?
    
    // (not used)
    func parser(commande: String, tableau: [String]) -> [String] {
        return tableau
    }
    

    func testObstacle(tabCommande: [String], tabLengthCommand: [Double], tabObstacle: [[Double]], zoneLim: [Int]) ->Bool {
//      test if the drone can execute his flight plan properly which mean that neither obstacle is touched
//      give "true" if the flight plan is ready to be executed, else give false
        var x : Double = 0
        var y : Double = 0
        var z : Double = 0
        
        var indexLength: Int = 0
        
        var flightIsOk : Bool = false
        
        var posDrone : [Double] = [x,y,z]
        
        let intervalleX = zoneLim[0] ... zoneLim[1]
        let intervalleY = zoneLim[2] ... zoneLim[3]
        let intervalleZ = zoneLim[4] ... zoneLim[5]
        
        print("\nLes obstacles sont aux positions suivantes: \(tabObstacle)")
        
//      the last instruction must be a "land()"
        if (tabCommande.last == "LAND()") {
            for instruction in tabCommande {
                // test switch
                switch instruction {
                case "TAKE OFF()":
                    print("\nTAKE OFF()")
                    // saving coordinates
                    let saveX = x
                    let saveY = y
                    let saveZ = z
                    print("ancienne position: \(posDrone)")
                    z += 1 // take off = 1 meter
                    indexLength += 1
                    
                    // test intervalle
                    if (intervalleZ.contains(Int(ceil(z)))) {
                        let intervalle = saveZ ... z
                        if (tabObstacle.isEmpty == true) {
                            posDrone = [saveX,saveY,z]
                            print("nouvelle position: \(posDrone)")
                            flightIsOk = true
                        } else {
                            for obs in tabObstacle {
                                if (obs[0] == x && obs[1] == y && intervalle.contains(obs[2])) {
                                    z -= 1
                                    posDrone = [saveX,saveY,z]
                                    errorAlertView = UIAlertController(
                                        title: "Error in flight plan",
                                        message: "You touched an obstacle -> nouvelle position: \(posDrone)",
                                        preferredStyle: .alert)
                                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(errorAlertView!, animated: true, completion: nil)
                                    print("Error in flight, you touched an obstacle -> nouvelle position: \(posDrone)")
                                    flightIsOk = false
                                } else {
                                    posDrone = [saveX,saveY,z]
                                    print("nouvelle position: \(posDrone)")
                                    flightIsOk = true
                                }
                            }
                        }
                    } else {
                        errorAlertView = UIAlertController(
                            title: "Error in flight plan",
                            message: "You are out of the limit zone",
                            preferredStyle: .alert)
                        errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlertView!, animated: true, completion: nil)
                        print("You are out of the limit zone")
                        flightIsOk = false
                    }
                    break
                case "TAKEOFF()":
                    print("\nTAKE OFF()")
                    let saveX = x
                    let saveY = y
                    let saveZ = z
                    print("ancienne position: \(posDrone)")
                    z += 1
                    indexLength += 1
                    if (intervalleZ.contains(Int(ceil(z)))) {
                        let intervalle = saveZ ... z
                        if (tabObstacle.isEmpty == true) {
                            posDrone = [saveX,saveY,z]
                            print("nouvelle position: \(posDrone)")
                            flightIsOk = true
                        } else {
                            for obs in tabObstacle {
                                if (obs[0] == x && obs[1] == y && intervalle.contains(obs[2])) {
                                    z -= 1
                                    posDrone = [saveX,saveY,z]
                                    errorAlertView = UIAlertController(
                                        title: "Error in flight plan",
                                        message: "You touched an obstacle -> nouvelle position: \(posDrone)",
                                        preferredStyle: .alert)
                                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(errorAlertView!, animated: true, completion: nil)
                                    print("Error in flight, you touched an obstacle -> nouvelle position: \(posDrone)")
                                    flightIsOk = false
                                } else {
                                    posDrone = [saveX,saveY,z]
                                    print("nouvelle position: \(posDrone)")
                                    flightIsOk = true
                                }
                            }
                        }
                    } else {
                        errorAlertView = UIAlertController(
                            title: "Error in flight plan",
                            message: "You are out of the limit zone",
                            preferredStyle: .alert)
                        errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlertView!, animated: true, completion: nil)
                        print("You are out of the limit zone")
                        flightIsOk = false
                    }
                    break
                    
                case "LAND()":
                    print("\nLAND()")
                    let saveX = x
                    let saveY = y
                    let saveZ = z
                    print("ancienne position: \(posDrone)")
                    z -= 1
                    indexLength += 1
                    if (intervalleZ.contains(Int(ceil(z)))) {
                        let intervalle = z ... saveZ
                        if (tabObstacle.isEmpty == true) {
                            posDrone = [saveX,saveY,z]
                            print("nouvelle position: \(posDrone)")
                            flightIsOk = true
                        } else {
                            for obs in tabObstacle {
                                if (obs[0] == x && obs[1] == y && intervalle.contains(obs[2])) {
                                    z += 1
                                    posDrone = [saveX,saveY,z]
                                    errorAlertView = UIAlertController(
                                        title: "Error in flight plan",
                                        message: "You touched an obstacle -> nouvelle position: \(posDrone)",
                                        preferredStyle: .alert)
                                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(errorAlertView!, animated: true, completion: nil)
                                    print("Error in flight, you touched an obstacle -> nouvelle position: \(posDrone)")
                                    flightIsOk = false
                                } else {
                                    posDrone = [saveX,saveY,z]
                                    print("nouvelle position: \(posDrone)")
                                    flightIsOk = true
                                }
                            }
                        }
                    } else {
                        errorAlertView = UIAlertController(
                            title: "Error in flight plan",
                            message: "You are out of the limit zone",
                            preferredStyle: .alert)
                        errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlertView!, animated: true, completion: nil)
                        print("You are out of the limit zone")
                        flightIsOk = false
                    }
                    break
                case "RIGHT()":
                    print("\nRIGHT()")
                    let saveX = x
                    let saveY = y
                    let saveZ = z
                    print("ancienne position: \(posDrone)")
                    y -= tabLengthCommand[indexLength]
                    indexLength += 1
                    if (intervalleY.contains(Int(ceil(y)))) {
                        let intervalle = y ... saveY
                        if (tabObstacle.isEmpty == true) {
                            posDrone = [saveX,y,saveZ]
                            print("nouvelle position: \(posDrone)")
                            flightIsOk = true
                        } else {
                            for obs in tabObstacle {
                                if (obs[0] == x && intervalle.contains(obs[1]) && obs[2] == z) {
                                    y += tabLengthCommand[indexLength - 1]
                                    posDrone = [saveX,y,saveZ]
                                    errorAlertView = UIAlertController(
                                        title: "Error in flight plan",
                                        message: "You touched an obstacle -> nouvelle position: \(posDrone)",
                                        preferredStyle: .alert)
                                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(errorAlertView!, animated: true, completion: nil)
                                    print("Error in flight, you touched an obstacle -> nouvelle position: \(posDrone)")
                                    flightIsOk = false
                                } else {
                                    posDrone = [saveX,y,saveZ]
                                    print("nouvelle position: \(posDrone)")
                                    flightIsOk = true
                                }
                            }
                        }
                    } else {
                        errorAlertView = UIAlertController(
                            title: "Error in flight plan",
                            message: "You are out of the limit zone",
                            preferredStyle: .alert)
                        errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlertView!, animated: true, completion: nil)
                        print("You are out of the limit zone")
                        flightIsOk = false
                    }
                    break
                case "LEFT()":
                    print("\nLEFT()")
                    let saveX = x
                    let saveY = y
                    let saveZ = z
                    print("ancienne position: \(posDrone)")
                    y += tabLengthCommand[indexLength]
                    indexLength += 1
                    if (intervalleY.contains(Int(ceil(y)))) {
                        let intervalle = saveY ... y
                        if (tabObstacle.isEmpty == true) {
                            posDrone = [saveX,y,saveZ]
                            print("nouvelle position: \(posDrone)")
                            flightIsOk = true
                        } else {
                            for obs in tabObstacle {
                                if (obs[0] == x && intervalle.contains(obs[1]) && obs[2] == z) {
                                    y -= tabLengthCommand[indexLength - 1]
                                    posDrone = [saveX,y,saveZ]
                                    errorAlertView = UIAlertController(
                                        title: "Error in flight plan",
                                        message: "You touched an obstacle -> nouvelle position: \(posDrone)",
                                        preferredStyle: .alert)
                                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(errorAlertView!, animated: true, completion: nil)
                                    print("Error in flight, you touched an obstacle -> nouvelle position: \(posDrone)")
                                    flightIsOk = false
                                } else {
                                    posDrone = [saveX,y,saveZ]
                                    print("nouvelle position: \(posDrone)")
                                    flightIsOk = true
                                }
                            }
                        }
                    } else {
                        errorAlertView = UIAlertController(
                            title: "Error in flight plan",
                            message: "You are out of the limit zone",
                            preferredStyle: .alert)
                        errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlertView!, animated: true, completion: nil)
                        print("You are out of the limit zone")
                        flightIsOk = false
                    }
                    break
                case "FORWARD()":
                    print("\nFORWARD()")
                    let saveX = x
                    let saveY = y
                    let saveZ = z
                    print("ancienne position: \(posDrone)")
                    x += tabLengthCommand[indexLength]
                    indexLength += 1
                    if (intervalleX.contains(Int(ceil(x)))) {
                        let intervalle = saveX ... x
                        if (tabObstacle.isEmpty == true) {
                            posDrone = [x,saveY,saveZ]
                            print("nouvelle position: \(posDrone)")
                            flightIsOk = true
                        } else {
                            for obs in tabObstacle {
                                if (intervalle.contains(obs[0]) && obs[1] == y && obs[2] == z) {
                                    x -= tabLengthCommand[indexLength - 1]
                                    posDrone = [x,saveY,saveZ]
                                    errorAlertView = UIAlertController(
                                        title: "Error in flight plan",
                                        message: "You touched an obstacle -> nouvelle position: \(posDrone)",
                                        preferredStyle: .alert)
                                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(errorAlertView!, animated: true, completion: nil)
                                    print("Error in flight, you touched an obstacle -> nouvelle position: \(posDrone)")
                                    flightIsOk = false
                                } else {
                                    posDrone = [x,saveY,saveZ]
                                    print("nouvelle position: \(posDrone)")
                                    flightIsOk = true
                                }
                            }
                        }
                    } else {
                        errorAlertView = UIAlertController(
                            title: "Error in flight plan",
                            message: "You are out of the limit zone",
                            preferredStyle: .alert)
                        errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlertView!, animated: true, completion: nil)
                        print("You are out of the limit zone")
                        flightIsOk = false
                    }
                    break
                case "BACKWARD()":
                    print("\nBACKWARD()")
                    let saveX = x
                    let saveY = y
                    let saveZ = z
                    print("ancienne position: \(posDrone)")
                    x -= tabLengthCommand[indexLength]
                    indexLength += 1
                    if (intervalleX.contains(Int(ceil(x)))) {
                        let intervalle = x ... saveX
                        if (tabObstacle.isEmpty == true) {
                            posDrone = [x,saveY,saveZ]
                            print("nouvelle position: \(posDrone)")
                            flightIsOk = true
                        } else {
                            for obs in tabObstacle {
                                if (intervalle.contains(obs[0]) && obs[1] == y && obs[2] == z) {
                                    x += tabLengthCommand[indexLength - 1]
                                    posDrone = [x,saveY,saveZ]
                                    errorAlertView = UIAlertController(
                                        title: "Error in flight plan",
                                        message: "You touched an obstacle -> nouvelle position: \(posDrone)",
                                        preferredStyle: .alert)
                                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(errorAlertView!, animated: true, completion: nil)
                                    print("Error in flight, you touched an obstacle -> nouvelle position: \(posDrone)")
                                    flightIsOk = false
                                } else {
                                    posDrone = [x,saveY,saveZ]
                                    print("nouvelle position: \(posDrone)")
                                    flightIsOk = true
                                }
                            }
                        }
                    } else {
                        errorAlertView = UIAlertController(
                            title: "Error in flight plan",
                            message: "You are out of the limit zone",
                            preferredStyle: .alert)
                        errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlertView!, animated: true, completion: nil)
                        print("You are out of the limit zone")
                        flightIsOk = false
                    }
                    break
                case "UP()":
                    print("\nUP()")
                    let saveX = x
                    let saveY = y
                    let saveZ = z
                    print("ancienne position: \(posDrone)")
                    z += tabLengthCommand[indexLength]
                    indexLength += 1
                    if (intervalleZ.contains(Int(ceil(z)))) {
                        let intervalle = saveZ ... z
                        if (tabObstacle.isEmpty == true) {
                            posDrone = [saveX,saveY,z]
                            print("nouvelle position: \(posDrone)")
                            flightIsOk = true
                        } else {
                            for obs in tabObstacle {
                                if (obs[0] == x && obs[1] == y && intervalle.contains(obs[2])) {
                                    z -= tabLengthCommand[indexLength - 1]
                                    posDrone = [saveX,saveY,z]
                                    errorAlertView = UIAlertController(
                                        title: "Error in flight plan",
                                        message: "You touched an obstacle -> nouvelle position: \(posDrone)",
                                        preferredStyle: .alert)
                                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(errorAlertView!, animated: true, completion: nil)
                                    print("Error in flight, you touched an obstacle -> nouvelle position: \(posDrone)")
                                    flightIsOk = false
                                } else {
                                    posDrone = [saveX,saveY,z]
                                    print("nouvelle position: \(posDrone)")
                                    flightIsOk = true
                                }
                            }
                        }
                    } else {
                        errorAlertView = UIAlertController(
                            title: "Error in flight plan",
                            message: "You are out of the limit zone",
                            preferredStyle: .alert)
                        errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlertView!, animated: true, completion: nil)
                        print("You are out of the limit zone")
                        flightIsOk = false
                    }
                    break
                case "DOWN()":
                    print("\nDOWN()")
                    let saveX = x
                    let saveY = y
                    let saveZ = z
                    print("ancienne position: \(posDrone)")
                    z -= tabLengthCommand[indexLength]
                    indexLength += 1
                    if (intervalleZ.contains(Int(ceil(z)))) {
                        let intervalle = z ... saveZ
                        if (tabObstacle.isEmpty == true) {
                            posDrone = [saveX,saveY,z]
                            print("nouvelle position: \(posDrone)")
                            flightIsOk = true
                        } else {
                            for obs in tabObstacle {
                                if (obs[0] == x && obs[1] == y && intervalle.contains(obs[2])) {
                                    z += tabLengthCommand[indexLength - 1]
                                    posDrone = [saveX,saveY,z]
                                    errorAlertView = UIAlertController(
                                        title: "Error in flight plan",
                                        message: "You touched an obstacle -> nouvelle position: \(posDrone)",
                                        preferredStyle: .alert)
                                    errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(errorAlertView!, animated: true, completion: nil)
                                    print("Error in flight, you touched an obstacle -> nouvelle position: \(posDrone)")
                                    flightIsOk = false
                                } else {
                                    posDrone = [saveX,saveY,z]
                                    print("nouvelle position: \(posDrone)")
                                    flightIsOk = true
                                }
                            }
                        }
                    } else {
                        errorAlertView = UIAlertController(
                            title: "Error in flight plan",
                            message: "You are out of the limit zone",
                            preferredStyle: .alert)
                        errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlertView!, animated: true, completion: nil)
                        print("You are out of the limit zone")
                        flightIsOk = false
                    }
                    break
                default:
                    break
                }
            }
        } else {
            errorAlertView = UIAlertController(
                title: "Error in flight plan",
                message: "Your sequence of instruction must terminated with instruction: 'LAND'",
                preferredStyle: .alert)
            errorAlertView?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlertView!, animated: true, completion: nil)
            print("Error your sequence of instruction must terminated with instruction: 'LAND'")
            flightIsOk = false
        }

        return flightIsOk
    }
    
    
    func execPlan(tabCommande: [String], tabExecution: [Int]) -> [Int] {
//        build an array which each integer represent a instruction
        var tmpTabExec = tabExecution
        for instr in tabCommande {
            switch (instr) {
                case "TAKEOFF()":
                    tmpTabExec.append(0)
                    break
                case "TAKE OFF()":
                    tmpTabExec.append(0)
                    break
                case "LAND()":
                    tmpTabExec.append(1)
                    break
                case "RIGHT()":
                    tmpTabExec.append(2)
                    break
                case "LEFT()":
                    tmpTabExec.append(3)
                    break
                case "FORWARD()":
                    tmpTabExec.append(4)
                    break
                case "BACKWARD()":
                    tmpTabExec.append(5)
                    break
                case "UP()":
                    tmpTabExec.append(6)
                    break
                case "DOWN()":
                    tmpTabExec.append(7)
                    break
                default:
                    break
            }
        }
        return tmpTabExec
    }
    
}










