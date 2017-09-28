//
//  VideoRecorderViewController.swift
//  FullScreenVideoRecorder
//
//  Created by Chris Huang on 28/09/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

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
	
	var isRecording = false
	
	@IBAction func capture(_ sender: UIButton) {
		if !isRecording {
			isRecording = true
			// Animate camera button to indicate it's recording
			UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
				self.cameraButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
			}, completion: nil)
			// Configure output path in temporary folder
			let outputPath = NSTemporaryDirectory() + "output.mov"
			let outputFileURL = URL(fileURLWithPath: outputPath)
			videoOutput?.startRecording(to: outputFileURL, recordingDelegate: self)
		} else {
			isRecording = false
			UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
				self.cameraButton.transform = CGAffineTransform(scaleX: 1, y: 1)
			}, completion: nil)
			cameraButton.layer.removeAllAnimations()
			videoOutput?.stopRecording()
		}
	}
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowAVPlayer" {
			guard let videoPlayerViewController = segue.destination as? AVPlayerViewController else { return }
			videoPlayerViewController.player = AVPlayer(url: sender as! URL)
		}
	}
}

extension VideoRecorderViewController: AVCaptureFileOutputRecordingDelegate {
	func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
		if error != nil { print(error?.localizedDescription ?? "") }
		performSegue(withIdentifier: "ShowAVPlayer", sender: outputFileURL)
	}
}
