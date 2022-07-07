//
//  ViewController.swift
//  RoamExamp
//
//  Created by GeoSpark on 07/07/22.
//

import UIKit
import Roam

class ViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var createUserBtn: UIButton!
    @IBOutlet weak var requestLocationBTn: UIButton!
    @IBOutlet weak var startTrackingBtn: UIButton!
    @IBOutlet weak var stopTrackingBtn: UIButton!
    @IBOutlet weak var sdkVersionLabel: UILabel!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var updateTextfield: UITextField!
    
    var userIdString:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTextfield.delegate = self

        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { time in
            DispatchQueue.main.async {
                self.sdkVersionLabel.text = "SDK Version  " + self.getSDKVersion()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            updateButton(false)
            return
        }
        DispatchQueue.main.async {
            self.userId.text =  userId
        }
        self.updateButton(true)
        DispatchQueue.main.async {
            if UserDefaults.standard.bool(forKey: "trackings") == true {
                self.startTrackingBtn.isEnabled = false
                self.stopTrackingBtn.isEnabled = true
            }else{
                self.startTrackingBtn.isEnabled = true
                self.stopTrackingBtn.isEnabled = false
            }
        }
    }
    
    @IBAction func stopTracking(_ sender: Any) {
        Roam.stopTracking()
        self.startTrackingBtn.isEnabled = true
        self.stopTrackingBtn.isEnabled = false
        
        UserDefaults.standard.set(false, forKey: "trackings")
        UserDefaults.standard.synchronize()


    }
    
    @IBAction func startTracking(_ sender: Any) {
    
        UserDefaults.standard.set(true, forKey: "trackings")
        UserDefaults.standard.synchronize()
        
        
        let customOptions  = RoamTrackingCustomMethods()
        customOptions.allowBackgroundLocationUpdates = true //self.backLocationSegmentAction.selectedSegmentIndex == 1
        customOptions.pausesLocationUpdatesAutomatically = false//self.pauseSegmentAction.selectedSegmentIndex == 1
        customOptions.showsBackgroundLocationIndicator = true
        customOptions.desiredAccuracy = .kCLLocationAccuracyBestForNavigation//self.getDesiredAccuracy()
        customOptions.activityType = .fitness//self.getActivity()
        customOptions.useVisits = true
        customOptions.useSignificant = true
       customOptions.useStandardLocationServices = false
       customOptions.useRegionMonitoring  = true
        customOptions.updateInterval = 300
        Roam.startTracking(.custom, options: customOptions)
        
        self.startTrackingBtn.isEnabled = false
        self.stopTrackingBtn.isEnabled = true

    }
    
    @IBAction func requestAction(_ sender: Any) {
        Roam.requestLocation()
    }
    
    @IBAction func createAction(_ sender: Any) {
        Roam.createUser("Test User", nil) { user, error in
            if error == nil {
                
                UserDefaults.standard.set(user!.userId, forKey: "userId")
                UserDefaults.standard.synchronize()
                self.updateSubscribe()
                self.userIdString = user!.userId
                self.updateButton(true)
                self.showSimpleAlert("User Created", user!.userId)
            }else{
                self.showSimpleAlert("User Error ", "\(String(describing: error?.message))")
            }
        }
    }
    
    func updateButton(_ isUpdate:Bool){
        
        DispatchQueue.main.async {
            self.createUserBtn.isEnabled  = !isUpdate
            self.requestLocationBTn.isEnabled = isUpdate
            self.startTrackingBtn.isEnabled = isUpdate
            self.stopTrackingBtn.isEnabled = isUpdate
        }
    }
    
    func getSDKVersion() -> String{
        let str = UserDefaults.init(suiteName: "devmotionsdk")?.object(forKey: "RoamSDKVersionValue") as? String
        
        return str ?? "SDK not initialized"
    }
    
    func showSimpleAlert(_ tite:String, _ message:String) {
        
        DispatchQueue.main.async {
            self.userId.text = message

            let alert = UIAlertController(title: tite, message:message,preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func updateSubscribe(){
        print(userIdString)
        Roam.toggleListener(Events: true, Locations: true) { [self] user, error in
            if error == nil {
                Roam.subscribe(.Both, userIdString)
            }else{
                self.showSimpleAlert("Toggle listener", "")
            }
        }
    }
    
}

