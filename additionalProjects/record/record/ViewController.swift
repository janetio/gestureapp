//
//  ViewController.swift
//  record
//
//  Created by Grant Nakanishi on 4/24/23.
//

import UIKit
import CoreMotion
import simd
import TabularData
import CoreML

class ViewController: UIViewController {
    
    var classifier = try? testmodel(configuration: MLModelConfiguration())

    var attitudeX: [Double] = []
    var attitudeY: [Double] = []
    var attitudeZ: [Double] = []
    
    var gyroX: [Double] = []
    var gyroY: [Double] = []
    var gyroZ: [Double] = []
    
    var accX: [Double] = []
    var accY: [Double] = []
    var accZ: [Double] = []
    
    var gravityX: [Double] = []
    var gravityY: [Double] = []
    var gravityZ: [Double] = []
    
    private let headerText = "timestamp,attitudeX,attitudeY,attitudeZ,gyroX,gyroY,gyroZ,gravityX,gravityY,gravityZ,accX,accY,accZ"
    var recordText = ""
    var isRecording = false
    var count:Int = 1
    
    var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSensorUpdates()
    }
    
    @IBOutlet weak var console: UILabel!
    
    @IBAction func recordCsvAction(sender: UIButton) {
            if isRecording {
                stopRecording()
                
                var label = predict()
                
                if (label == nil){
                    label = " | Label is nil"
                }
                
                console.text! += label!
                
                
                //showSaveCsvFileAlert(fileName: String(count))
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
        motionManager.deviceMotionUpdateInterval = 0.1
            
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
        attitudeX.append(deviceMotion.attitude.pitch)
                   attitudeY.append(deviceMotion.attitude.roll)
                   attitudeZ.append(deviceMotion.attitude.yaw)
                   gyroX.append(deviceMotion.rotationRate.x)
                   gyroY.append(deviceMotion.rotationRate.y)
                   gyroZ.append(deviceMotion.rotationRate.z)
                   gravityX.append(deviceMotion.gravity.x)
                   gravityY.append(deviceMotion.gravity.y)
                   gravityZ.append(deviceMotion.gravity.z)
                   accX.append(deviceMotion.userAcceleration.x)
                   accY.append(deviceMotion.userAcceleration.y)
                   accZ.append(deviceMotion.userAcceleration.z)
            
                
            
        }
    
    func predict() -> String? {
        
        if(classifier == nil){
            console.text! += "Classifier is nil"
        }
            
        var accXMultiArray = try? MLMultiArray(accX)
        var accYMultiArray = try? MLMultiArray(accY)
        var accZMultiArray = try? MLMultiArray(accZ)
        
        var attitudeXMultiArray = try? MLMultiArray(attitudeX)
        var attitudeYMultiArray = try? MLMultiArray(attitudeY)
        var attitudeZMultiArray = try? MLMultiArray(attitudeZ)

        var gravityXMultiArray = try? MLMultiArray(gravityX)
        var gravityYMultiArray = try? MLMultiArray(gravityY)
        var gravityZMultiArray = try? MLMultiArray(gravityZ)
        
        var gyroXMultiArray = try? MLMultiArray(gyroX)
        var gyroYMultiArray = try? MLMultiArray(gyroY)
        var gyroZMultiArray = try? MLMultiArray(gyroZ)
        
        var stateInLength = 400
        
        var stateInMultiArray = try? MLMultiArray(shape: [stateInLength as NSNumber], dataType: MLMultiArrayDataType.double)
        
        var modelPrediction = try? classifier?.prediction(accX: accXMultiArray!, accY: accYMultiArray!, attitudeX: attitudeXMultiArray!, attitudeY: attitudeYMultiArray!, attitudeZ: attitudeZMultiArray!, gravityX: gravityXMultiArray!, gravityY: gravityYMultiArray!, gravityZ: gravityZMultiArray!, gyroX: gyroXMultiArray!, gyroY: gyroYMultiArray!, gyroZ: gyroZMultiArray!, stateIn: stateInMultiArray!)
        
        if(modelPrediction == nil){
            console.text! += " | modelPrediction is nil"
        }
        
        return modelPrediction?.label
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
