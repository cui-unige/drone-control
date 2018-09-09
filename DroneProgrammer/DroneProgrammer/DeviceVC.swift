//
//  DeviceVC.swift
//  DroneProgrammer
//
//  Created by CUI on 28.05.18.
//  Copyright © 2018 CUI. All rights reserved.
//


import UIKit

let BEBOP_SEGUE = "bebopSegue"




class DeviceVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DroneDiscovererDelegate{
    //@IBOutlet var tableView: UITableView!
    @IBOutlet var tableView: UITableView!
    var service = ARService()
    var dataSource: NSArray = []
    var droneDiscoverer: DroneDiscoverer?
    var selectedService: ARService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = NSArray.init(array: dataSource)
        //dataSource = [Any]()
        droneDiscoverer?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.registerNotifications()
        droneDiscoverer?.startDiscovering()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.unregisterNotifications()
        droneDiscoverer?.stopDiscovering()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == BEBOP_SEGUE) && (selectedService != nil) {
            var viewController: ViewController
            viewController = segue.destination as! ViewController
            viewController.service = selectedService!
        }
    }
    
    // MARK: DroneDiscovererDelegate
    func droneDiscoverer(_ droneDiscoverer: DroneDiscoverer?, didUpdateDronesList dronesList: [Any]/*[Any]?*/) {
        //if let aList = dronesList {
            //dataSource = aList
        dataSource = dronesList as NSArray
        //}
        tableView.reloadData()
    }
    
    // MARK: notification registration
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(DeviceVC.enteredBackground(_:)), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DeviceVC.enterForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    // MARK: - application notifications
    @objc func enterForeground(_ notification: Notification?) {
        droneDiscoverer?.startDiscovering()
    }
    
    @objc func enteredBackground(_ notification: Notification?) {
        droneDiscoverer?.stopDiscovering()
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: NSInteger) -> NSInteger {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let simpleTableIdentifier:NSString = "SimpleTableItem"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier as String)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: simpleTableIdentifier as String)
        }
        let service = dataSource[IndexPath.row] as? ARService
        var networkType: NSString
        switch service?.network_type {
            case ARDISCOVERY_NETWORK_TYPE_NET:
                networkType = "IP (e.g. wifi)"
            case ARDISCOVERY_NETWORK_TYPE_BLE:
                networkType = "BLE"
            case ARDISCOVERY_NETWORK_TYPE_USBMUX:
                networkType = "libmux over USB"
            default:
                networkType = "Unknown"
        }
        cell?.textLabel?.text = NSString(format: "\(service!.name) on \(networkType) network" as NSString, (service?.name)!, networkType) as String
        return cell!
//        if let aName = service?.name {
//            cell?.textLabel?.text = "\(aName) on \(networkType) network"
//        }
//        if let aCell = cell {
//            return aCell
//        }
//        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedService = dataSource[indexPath.row] as? ARService
        switch selectedService?.product {
        case ARDISCOVERY_PRODUCT_ARDRONE, ARDISCOVERY_PRODUCT_BEBOP_2:
            performSegue(withIdentifier:BEBOP_SEGUE, sender: self)
            break
            
//        case ARDISCOVERY_PRODUCT_JS, ARDISCOVERY_PRODUCT_JS_EVO_LIGHT, ARDISCOVERY_PRODUCT_JS_EVO_RACE:
//            performSegue(withIdentifier: JS_SEGUE, sender: self)
//        case ARDISCOVERY_PRODUCT_MINIDRONE, ARDISCOVERY_PRODUCT_MINIDRONE_EVO_BRICK, ARDISCOVERY_PRODUCT_MINIDRONE_EVO_LIGHT, ARDISCOVERY_PRODUCT_MINIDRONE_DELOS3:
//            performSegue(withIdentifier: MINIDRONE_SEGUE, sender: self)
//        case ARDISCOVERY_PRODUCT_MINIDRONE_WINGX:
//            performSegue(withIdentifier: SWING_SEGUE, sender: self)
//        case ARDISCOVERY_PRODUCT_SKYCONTROLLER:
//            performSegue(withIdentifier: SKYCONTROLLER_SEGUE, sender: self)
//        case ARDISCOVERY_PRODUCT_SKYCONTROLLER_2, ARDISCOVERY_PRODUCT_SKYCONTROLLER_NG:
//            performSegue(withIdentifier: SKYCONTROLLER2_SEGUE, sender: self)
        default:
            break
        }
    }
}
