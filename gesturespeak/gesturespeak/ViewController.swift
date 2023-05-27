//
//  ViewController.swift
//  gesturespeak
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
    static var upDown = "updown updown updown"
    static var wave = "wave wave wave"
}

class ViewController: UIViewController {
    
    var debug = false
    
    let debugFontSize = 15.0
    let fontSize = 46.0
    
    let synthesizer = AVSpeechSynthesizer()
    
    var classifier = try? gesturespeak_model(configuration: MLModelConfiguration())
    
    let stateInLength = 400
    let predictionWindow = 100
    
    let threshold = 0.85
    
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
    
    @IBOutlet weak var startGesture: UIButton!
    
   
    
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
    
    @IBAction func debugClicked(_ sender: UIButton) {
        if debug {
            debug = false
            sender.setTitle("Debug: OFF", for: .normal)
            console.font.withSize(fontSize)
            console.font = UIFont(descriptor: console.font.fontDescriptor, size: fontSize)
            
        } else {
            debug = true
            sender.setTitle("Debug: ON", for: .normal)
            console.font.withSize(debugFontSize)
            console.font = UIFont(descriptor: console.font.fontDescriptor, size: debugFontSize)
        }
    }
    
    @IBAction func touchDown(sender: UIButton) {
        
        startRecording()
        resetMotionArrays()
        sender.setTitle("Gesturing!", for: .normal)
        
    }
    
    func exitedGestureButton(sender: UIButton){
        stopRecording()
        
        let result = predict()
        
        if result[0] == "UpDown" {
            speak(input: Gestures.upDown)
        }
        if result[0] == "Wave"
        {
            speak(input: Gestures.wave)
        }
        if result[0] == "Other" {
            speak(input: "Other other other")
        }
        
        console.text = result[0]!
        if debug{
            
            console.text! += "\n\nProbabilities:\n" + result[1]!
            
        }
        
        //showSaveCsvFileAlert(fileName: String(count))
        count = count + 1
        
        sender.setTitle("Hold during gesture", for: .normal)
    }
    
    @IBAction func touchUpInside(sender: UIButton) {
        
        exitedGestureButton(sender: sender)
        
       
        
    }
    
    @IBAction func touchUpOutside(sender: UIButton) {
        exitedGestureButton(sender: sender)
        
    }
    
    
    func stopRecording() {
            isRecording = false
    }
    
    func startRecording() {
            recordText = ""
            recordText += headerText + "\n"
            isRecording = true
    }
    
    func speak(input: String) {
        
        var input_mod = ""
        input_mod += input
        
        print("input_mod: ")
        print(input_mod)
        print("")
        
        var utterance = AVSpeechUtterance(string: input_mod)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
//        var synthesizer = AVSpeechSynthesizer()
        self.synthesizer.speak(utterance)
        
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
            return ["Try doing the gesture for longer.\n",""]
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
            
            if(maxProb!.value < threshold){
                prediction = "Other"
            }
                
            predictionLabel = modelPrediction?.labelProbability.description
            
            start += 100
        }
        
        return [prediction, predictionLabel]
    }
}
