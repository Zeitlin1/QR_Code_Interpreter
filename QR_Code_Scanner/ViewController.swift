//
//  ViewController.swift
//  QR_Code_Scanner
//
//  Created by Anthony on 12/6/16.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var securitySource = SecuritySequence()
    
    var counter = 0
    
    var isRecording: Bool = false
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var captureDevice : AVCaptureDevice?
    
    var sequenceCounter = 0
    
    var matchCounter = 0
    
    @IBOutlet weak var qrCodeFrameView: UIView!
    
    @IBOutlet weak var uiPreview: UIView!
    
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var tapLabel: UILabel!
    
    @IBAction func StartButtonPressed(_ sender: Any) {
        
        if isRecording == false {
            lblStatus.text = "RECORDING!"
            tapLabel.isHidden = true
            print(startRecording())
            isRecording = true
        } else {
            lblStatus.text = "Not Recording"
            tapLabel.isHidden = false
            print(stopRecording())
            isRecording = false
        }
    }
    
    

    override func viewDidLoad() {
     
        super.viewDidLoad()
        
        uiPreview.center = view.center
        
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        
        qrCodeFrameView.layer.borderWidth = 2
        
        qrCodeFrameView.center = view.center
        
        view.addSubview(qrCodeFrameView)
        
        view.bringSubview(toFront: qrCodeFrameView)
    }
    
    func stopRecording() -> String {
        
        self.videoPreviewLayer?.session.stopRunning()
        
        lblStatus.text = "Not Recording"
       
        tapLabel.isHidden = false
       
        isRecording = false
        
        return ("checked \(counter) objects to find matches")
    }
    
    
    func startRecording() -> String {
        
        view.bringSubview(toFront: qrCodeFrameView)
        
        counter = 0
        
        view.bringSubview(toFront: tapLabel)
        
     
            do {
              
                if let devices = AVCaptureDevice.devices() {
               
                for captureDevice in devices {
                   
                    if ((captureDevice as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                       
        //    if((captureDevice as AnyObject).position == AVCaptureDevicePosition.front) {
            if((captureDevice as AnyObject).position == AVCaptureDevicePosition.back) {

                            
                            let device = captureDevice as? AVCaptureDevice
                          
                            do {
                                
                            let input = try AVCaptureDeviceInput(device: device)
                                
                                
                let captureSession = AVCaptureSession()
                
                captureSession.sessionPreset = AVCaptureSessionPreset1280x720
                
            //TURN THIS ON PRIOR TO PRODUCTION
            // captureSession.sessionPreset = AVCaptureSessionPreset3840x2160
                
                captureSession.addInput(input)
                
                let captureMetadataOutput = AVCaptureMetadataOutput()
                
                captureSession.addOutput(captureMetadataOutput)
                
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                
                captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                
                        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                        videoPreviewLayer?.frame = uiPreview.frame
                        
                        view.layer.addSublayer(videoPreviewLayer!)
                
                        view.bringSubview(toFront: qrCodeFrameView)
                
                        captureSession.startRunning()
                                
                            } catch {
                               print("CAMERA INPUT NOT COMPLETED")
                            }
                        }
            
                        }
                    }
                }
        }
                return "Recording in Progress"
    }
    
    func sha256(data : NSData) -> NSData {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
        let res = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
     
        return res
    }
    
    func hashData(dataObject: AVMetadataMachineReadableCodeObject) -> String {

        let data = dataObject.hashValue.data

        let hashValue1 = sha256(data: data)

        let stringHash1 = String(describing: hashValue1)
      
/**** ONLY USE THIS section FOR A BLOOM ARRAY
        // use modulo of array length to get the array position we want to set to "1"
        let modulo1 = hashValue1.uint8 % 250
        // set array index to "1"
        self.bloomArray[Int(modulo1)] = 1
        print("bloomArray's index at:\(Int(modulo1)): set to \(bloomArray[Int(modulo1)])")
ONLY USE THIS Section FOR A BLOOM ARRAY */
        
        print("Checking QR Code Hash:\(stringHash1)")
        
        return stringHash1
    }
    
    /****** PRINT INFO ******/
    
    func printInfo() {
        
      //   print("the security sequence set is: \(securitySource)")
        
         print("STOP")
    }
    /************* Capture # Hashes **************/
    
    func captureScanSequence(dataObject: AVMetadataMachineReadableCodeObject) {
        
        print(dataObject.hashValue)
        
        let data = dataObject.hashValue.data
        
        let hashValue1 = sha256(data: data) /*This is the first hash of our data*/
        
        let stringHash1 = String(describing: hashValue1) /*This is the string of our first hash*/
        
        securitySource.addOn(val: stringHash1, num: sequenceCounter)
        
        sequenceCounter += 1
        
        print("value of: \(stringHash1) added to public array at \(securitySource.count)")
        
        if securitySource.count == scanSequenceDepth {
            print(stopRecording())
        }
        // sleep for millionths of seconds
        usleep(useconds_t(10000))

    }
    
    /****** CHECK HASH VS. SEQUENCE ******/
    
    func checkSequence(dataObject: AVMetadataMachineReadableCodeObject) -> Bool {
        
        print(dataObject.hashValue)
        
        tapLabel.text = String(describing: counter)
        
        view.bringSubview(toFront: tapLabel)
        
        let data = dataObject.hashValue.data
        
        let hashValue1 = sha256(data: data) /*This is the first hash of our data*/
        
        let stringHash1 = String(describing: hashValue1) /*This is the string of our first hash*/
        
        let tempArray = securitySource.publicArray
        
        for (i, v) in tempArray {
            
            if stringHash1 == v {
                
                securitySource.publicArray[i] = nil
                
                matchCounter += 1
                
                let left = Int(Double(scanSequenceDepth) / Double(scanSequenceMultiplier))
               
                print("\(matchCounter) matches of \(left) needed")
                
                print("REMOVED HASH FROM SEQUENCE \(stringHash1)")
            
                
                if matchCounter >= left {
                    
                    print("MATCH THRESHOLD MET")
                    
                    self.view.backgroundColor = UIColor.green
                    
                    return true
                    
                }
                print("Matching hash found at hash: \(stringHash1)")
                
                //securitySource.publicArray = tempArray
            }
        }
        return false
    }


    
// THIS func IS FIRED WHENEVER OUTPUT IS CONNECTED TO DEVICE AND IT SENSES QR CODE OBJECT
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            
            printInfo()
          
            qrCodeFrameView.frame = CGRect.zero
            
            tapLabel.text = "No QR detected"
            
    } else {
            
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

            if metadataObj.type == AVMetadataObjectTypeQRCode {
                
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
                qrCodeFrameView?.frame = metadataObj.bounds
                
                if metadataObj.stringValue != nil {
                    
                    /****** USE CAPTURE TO SET THE RING'S CODE *****/
                    if securitySource.count < scanSequenceDepth {
                        
                    captureScanSequence(dataObject: metadataObj)
                    
                    } else {
                    /***** USE TO CHECK HASH AGAINST CAPTURED SEQUENCE (OR BLOOM FILTER) *****/
                        sequenceCounter = 0
                    /***** CHECK CURRENT SCANNED HASH AGAINST scanSequence *****/
                        if checkSequence(dataObject: metadataObj) == true {
                                print(stopRecording())
                        }
                    }
            }
        }
    }
        counter += 1
        
}

}

extension NSData {
// converts 8 bit ints
    var uint8: UInt8 {
    
        get {
        
            var number: UInt8 = 0
            
            self.getBytes(&number, length: MemoryLayout<UInt8>.size)
            
            return number
        }
    }

// adds data as a self property for encoding
    var string: String {
    
        get {
        
            if let string = NSString(data: self as Data, encoding: String.Encoding.utf8.rawValue) {
            
                return string as String
            
            } else {
            
                print("STRING NOT WORKING")
                
                return ""
            }
        }
    }
    
}

extension Int {
    
    var data: NSData {
       
        var int = self
        
        return NSData(bytes: &int, length: MemoryLayout<Int>.size)
    
    }
    
}

extension UInt8 {
    
    var data: NSData {
    
        var int = self
        
        return NSData(bytes: &int, length: MemoryLayout<UInt8>.size)
    
    }
    
}


extension String {
    
    var data: NSData {
       
        if let data = self.data(using: String.Encoding.utf8) {
        
            return data as NSData
        
        } else {
            
            print("DATA STRING NOT WORKING")
            
            return NSData()
        }
    }
}

extension NSString {
    
    var data: NSData {
       
        if let data = self.data(using: String.Encoding.utf8.rawValue) {
        
            return data as NSData
        
        } else {
        
            print("DATA STRING NOT WORKING")
            
            return NSData()
        }
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
   
    mutating func remove(object: Element) {
    
        if let index = index(of: object) {
        
            remove(at: index)
        }
    }
}
