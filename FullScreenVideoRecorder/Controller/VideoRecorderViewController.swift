//
//  VideoRecorderViewController.swift
//  FullScreenVideoRecorder
//
//  Created by Chris Huang on 28/09/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import UIKit
import AVFoundation

class VideoRecorderViewController: UIViewController {

	@IBOutlet weak var cameraButton: UIButton!
	
	lazy var captureSession: AVCaptureSession = {
		let session = AVCaptureSession()
		session.sessionPreset = AVCaptureSession.Preset.high
		return session
	}()
	
	// Input Device
	var currentDevice: AVCaptureDevice?
	// Video output
	var videoOutput: AVCaptureMovieFileOutput?
	// Creating a preview layer
	var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Selecting input device
		if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
			currentDevice = device
		} else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
			currentDevice = device
		}
		
		// Get the input data source
		guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice!) else { return }
		
		// Configure AVCaptureMovieFileOutput
		videoOutput = AVCaptureMovieFileOutput()
		
		// Configure the session with the input and the output devices
		if captureSession.canAddInput(captureDeviceInput) {
			captureSession.addInput(captureDeviceInput)
			if captureSession.canAddOutput(videoOutput!) {
				captureSession.addOutput(videoOutput!)
			} else {
				print("captureSession can't add output")
			}
		} else {
			print("captureSession can't add input")
		}
		
		// Configure camera preview layer
		cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		view.layer.addSublayer(cameraPreviewLayer!)
		cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		cameraPreviewLayer?.frame = view.layer.frame
		
		// Bring the camera button to front
		view.bringSubview(toFront: cameraButton)
		
		// Start captureSession
		captureSession.startRunning()
	}
	
	
	@IBAction func unwind(segue: UIStoryboardSegue) {
	}
}
