//
//  ScanViewController.swift
//  MyProject
//
//  Created by username on 19/08/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

protocol ScanViewControllerDelegate : class {
    func DelegateScanViewController(controller: ScanViewController, dataFromQrCode : String?)
}


public class ScanViewController : UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    
    var dataFromCamera : String?
    
    var delegate : ScanViewControllerDelegate?
    
    var captureSession : AVCaptureSession?
    
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func startReadingVideoOutput() {
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var input : AVCaptureDeviceInput? = nil
        do{
            input = try AVCaptureDeviceInput(device: captureDevice)
        }catch let error as NSError {
            print(error)
            return
        }
        self.captureSession = AVCaptureSession()
        
        let captureMetaDataOutput : AVCaptureMetadataOutput = AVCaptureMetadataOutput()
        
        self.captureSession?.addInput(input)
        self.captureSession?.addOutput(captureMetaDataOutput)
        
        var GlobalUserInitiatedQueue: dispatch_queue_t
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        
        GlobalUserInitiatedQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: GlobalUserInitiatedQueue)
        captureMetaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        videoPreviewLayer.videoGravity = kCAGravityResize
        videoPreviewLayer.frame = self.view.layer.bounds
        
        self.cameraView.layer.addSublayer(videoPreviewLayer)
        self.captureSession?.startRunning()

    }
    
    public override func viewDidLoad() {
        //code
    }
    
    
    
    public override func viewWillAppear(animated: Bool) {
        startReadingVideoOutput()
    }
    
    public override func viewDidDisappear(animated: Bool) {
        self.stopReading()
    }
    
    func stopReading(){
        self.captureSession?.stopRunning()
        self.captureSession = nil
        
        self.videoPreviewLayer?.removeFromSuperlayer()
        self.videoPreviewLayer = nil;
    }
    
    //AVCaptureMetadataOutputObjectsDelegate
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){        
        if (metadataObjects.count > 0){
            guard let metaDataObject : AVMetadataMachineReadableCodeObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.dataFromCamera = metaDataObject.stringValue
                self.sendDataToDelegateAndReturnToSuperView()
            })
        }
    }
    //End
    
    func sendDataToDelegateAndReturnToSuperView(){
        self.delegate?.DelegateScanViewController(self , dataFromQrCode: self.dataFromCamera)
        //self.session. removeOutput:self.session.outputs.firstObject];
        //self.captureSession?.removeOutput(self.captureSession?.outputs[0] as! AVCaptureOutput )
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backBtnTapped(sender: UIBarButtonItem) {        
        self.sendDataToDelegateAndReturnToSuperView()
    }
}
    

