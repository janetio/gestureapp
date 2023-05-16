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
import SwiftUI
import AVFoundation

struct Gestures {
    static var upDown = "updown"
    static var wave = "wave"
}

class ViewController: UIViewController {
    
    var classifier = try? MyActivityClassifier_1(configuration: MLModelConfiguration())
    
    let stateInLength = 400
    let predictionWindow = 100
    
    //Definition in viewDidLoad()
    var stateInMultiArray : MLMultiArray?
    
    var stateInZeroes : [Double] = []
    
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
    
    private let headerText = "attitudeX,attitudeY,attitudeZ,gyroX,gyroY,gyroZ,gravityX,gravityY,gravityZ,accX,accY,accZ"
    var recordText = ""
    var isRecording = false
    var count:Int = 1
    
    var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...(stateInLength - 1) {
            stateInZeroes.append(0.0)
        }

        stateInMultiArray = try? MLMultiArray(stateInZeroes)

        startSensorUpdates()
    }
    
    @IBOutlet weak var console: UILabel!
    
    func resetMotionArrays(){
        attitudeX = []
        attitudeY = []
        attitudeZ = []
        
        gyroX = []
        gyroY = []
        gyroZ = []
        
        accX = []
        accY = []
        accZ = []
        
        gravityX = []
        gravityY = []
        gravityZ = []
        
        stateInMultiArray = try? MLMultiArray(stateInZeroes)
    }
    
    @IBAction func tutorialPressed(_ sender: UIButton) {
        
        let tutorial = Tutorial()
        let host = UIHostingController(rootView: tutorial)
        self.present(host, animated: true)
        
    }
    
    @IBAction func editGestures(_ sender: UIButton) {
        
        let edit = EditGestures()
        let host = UIHostingController(rootView: edit)
        self.present(host, animated: true)
        
    }
    
    @IBAction func recordCsvAction(sender: UIButton) {
            if isRecording {
                stopRecording()
                
                let result = predict()
                if result[0] == "UpDown" {
                    var utterance = AVSpeechUtterance(string: Gestures.upDown)
                    speak(utterance: utterance)
                } else {
                    var utterance = AVSpeechUtterance(string: Gestures.wave)
                    speak(utterance: utterance)
                }
                
                console.text = "Predicted: " + result[0]! + "\n\nProbabilities:\n" + result[1]!
                
                //showSaveCsvFileAlert(fileName: String(count))
                count = count + 1
                
                sender.setTitle("START", for: .normal)
                
            } else {
                
                startRecording()
                resetMotionArrays()
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
    
    func speak(utterance: AVSpeechUtterance) {
//        @State var utterance: AVSpeechUtterance
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
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
    
    
    
    func predict() -> [String?] {
        
        if(classifier == nil){
            console.text! += " Classifier is nil "
        }
        
        let length = accX.count
        
        print("Length of gesture (# of data points)")
        print(length)
        print("")
        
        if(length < predictionWindow){
            // Too short of a gesture
            return ["Try doing the gesture for longer\n",""]
        }
        
        //The math here could be better i think, but it works ('shares' the trimming from the front and back of the data
        var numOfLoops = length / predictionWindow
        var start = (length % predictionWindow) / 2
        let orgStart = start
        
        var prediction : String? = ""
        var predictionLabel : String? = ""
        
        var accXMultiArray : MLMultiArray?
        var accYMultiArray : MLMultiArray?
        var accZMultiArray : MLMultiArray?
        
        var attitudeXMultiArray : MLMultiArray?
        var attitudeYMultiArray : MLMultiArray?
        var attitudeZMultiArray : MLMultiArray?

        var gravityXMultiArray : MLMultiArray?
        var gravityYMultiArray : MLMultiArray?
        var gravityZMultiArray : MLMultiArray?
        
        var gyroXMultiArray : MLMultiArray?
        var gyroYMultiArray : MLMultiArray?
        var gyroZMultiArray : MLMultiArray?
                
        for i in 1...numOfLoops{
            
            accXMultiArray = try? MLMultiArray(accX[start ... orgStart + (i * predictionWindow) - 1])
            accYMultiArray = try? MLMultiArray(accY[start ... orgStart + (i * predictionWindow) - 1])
            accZMultiArray = try? MLMultiArray(accZ[start ... orgStart + (i * predictionWindow) - 1])
           
            attitudeXMultiArray = try? MLMultiArray(attitudeX[start ... orgStart + (i * predictionWindow) - 1])
            attitudeYMultiArray = try? MLMultiArray(attitudeY[start ... orgStart + (i * predictionWindow) - 1])
            attitudeZMultiArray = try? MLMultiArray(attitudeZ[start ... orgStart + (i * predictionWindow) - 1])

            gravityXMultiArray = try? MLMultiArray(gravityX[start ... orgStart + (i * predictionWindow) - 1])
            gravityYMultiArray = try? MLMultiArray(gravityY[start ... orgStart + (i * predictionWindow) - 1])
            gravityZMultiArray = try? MLMultiArray(gravityZ[start ... orgStart + (i * predictionWindow) - 1])
           
            gyroXMultiArray = try? MLMultiArray(gyroX[start ... orgStart + (i * predictionWindow) - 1])
            gyroYMultiArray = try? MLMultiArray(gyroY[start ... orgStart + (i * predictionWindow) - 1])
            gyroZMultiArray = try? MLMultiArray(gyroZ[start ... orgStart + (i * predictionWindow) - 1])
            
            let modelPrediction = try? classifier?.prediction(accX: accXMultiArray!, accY: accYMultiArray!, accZ: accZMultiArray!, attitudeX: attitudeXMultiArray!, attitudeY: attitudeYMultiArray!, attitudeZ: attitudeZMultiArray!, gravityX: gravityXMultiArray!, gravityY: gravityYMultiArray!, gravityZ: gravityZMultiArray!, gyroX: gyroXMultiArray!, gyroY: gyroYMultiArray!, gyroZ: gyroZMultiArray!, stateIn: stateInMultiArray!)
            
            if(modelPrediction == nil){
                return ["FAILED: modelPrediction is nil\n",""]
            }
            
            stateInMultiArray = modelPrediction?.stateOut
            
            prediction = modelPrediction?.label
            
            let maxProb = modelPrediction?.labelProbability.max {a,b in a.value < b.value}
            
            if(maxProb!.value < 0.98){
                prediction = "Other"
            }
                
            predictionLabel = modelPrediction?.labelProbability.description
            
            start += 100
        }
        
        return [prediction, predictionLabel]
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
