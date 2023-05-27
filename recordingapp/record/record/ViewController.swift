//
//  ViewController.swift
//  record
//
//  Created by Grant Nakanishi on 4/24/23.
//This app was used to collect motion data and turn them into csv files to train classifier
//credit to FollowTheDarkside/SensorDataRecorder github repository from which
//much of the code was taken and modified from.

import UIKit
import CoreMotion
import simd

class ViewController: UIViewController {

    var attitude = SIMD3<Double>.zero
    var gyro = SIMD3<Double>.zero
    var gravity = SIMD3<Double>.zero
    var acc = SIMD3<Double>.zero
    private let headerText = "attitudeX,attitudeY,attitudeZ,gyroX,gyroY,gyroZ,gravityX,gravityY,gravityZ,accX,accY,accZ"
    var recordText = ""
    var isRecording = false
    var count:Int = 1
    
    var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSensorUpdates()
    }
    
    @IBAction func recordCsvAction(sender: UIButton) {
            if isRecording {
                stopRecording()
                
                showSaveCsvFileAlert(fileName: String(count))
                count = count + 1
                
                sender.setTitle("START", for: .normal)
            }else{
                startRecording()
                sender.setTitle("STOP", for: .normal)
            }
        }
    
    
    func stopRecording() {
            isRecording = false
    }
    
    func startRecording() {
            recordText = ""
            recordText += headerText + "\n"
            isRecording = true
    }
    
    func startSensorUpdates() {
        motionManager.deviceMotionUpdateInterval = 0.0000000001
            
            // start sensor updates
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                    self.getMotionData(deviceMotion: motion!)
    
                    })
    }
    
    func stopSensorUpdates() {
            if motionManager.isDeviceMotionAvailable{
                motionManager.stopDeviceMotionUpdates()
            }
        }
    
    func getMotionData(deviceMotion:CMDeviceMotion) {
            attitude.x = deviceMotion.attitude.pitch
            attitude.y = deviceMotion.attitude.roll
            attitude.z = deviceMotion.attitude.yaw
            gyro.x = deviceMotion.rotationRate.x
            gyro.y = deviceMotion.rotationRate.y
            gyro.z = deviceMotion.rotationRate.z
            gravity.x = deviceMotion.gravity.x
            gravity.y = deviceMotion.gravity.y
            gravity.z = deviceMotion.gravity.z
            acc.x = deviceMotion.userAcceleration.x
            acc.y = deviceMotion.userAcceleration.y
            acc.z = deviceMotion.userAcceleration.z
            
                
            var text = ""
                
            text += String(attitude.x) + ","
            text += String(attitude.y) + ","
            text += String(attitude.z) + ","
            text += String(gyro.x) + ","
            text += String(gyro.y) + ","
            text += String(gyro.z) + ","
            text += String(gravity.x) + ","
            text += String(gravity.y) + ","
            text += String(gravity.z) + ","
            text += String(acc.x) + ","
            text += String(acc.y) + ","
            text += String(acc.z)
                
            recordText += text + "\n"
            
        }
    
    func saveSensorDataToCsv(fileName:String) {
            
            let filePath = NSHomeDirectory() + "/Documents/" + fileName + ".csv"
            
            do{
                try recordText.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
                print("Success to Write CSV")
            }catch let error as NSError{
                print("Failure to Write CSV\n\(error)")
            }
        }
    
    func showSaveCsvFileAlert(fileName:String){
        let alertController = UIAlertController(title: "Save CSV file", message: "Enter file name to add.", preferredStyle: .alert)
        
        let defaultAction:UIAlertAction =
            UIAlertAction(title: "OK",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            let textField = alertController.textFields![0] as UITextField
                            self.saveSensorDataToCsv(fileName: textField.text!)
            })
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            self.showDeleteRecordedDataAlert(fileName: fileName)
            })
        
        alertController.addTextField { (textField:UITextField!) -> Void in
            alertController.textFields![0].text = fileName
        }
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showDeleteRecordedDataAlert(fileName:String){
            let alertController = UIAlertController(title: "Delete recorded data", message: "Do you delete recorded data?", preferredStyle: .alert)
            
            let defaultAction:UIAlertAction =
                UIAlertAction(title: "OK",
                              style: .default,
                              handler:{
                                (action:UIAlertAction!) -> Void in
                                // delete recorded data
                })
            let cancelAction:UIAlertAction =
                UIAlertAction(title: "Cancel",
                              style: .cancel,
                              handler:{
                                (action:UIAlertAction!) -> Void in
                                self.showSaveCsvFileAlert(fileName: fileName)
                })
            
            alertController.addAction(defaultAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
    
}
