//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Edward Morton on 5/12/19.
//  Copyright © 2019 Edward Morton. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

	// MARK: - Properties

	private let session = AVAudioSession.sharedInstance()
	private let noMicAccess: String = "Please Allow Mic Access in Settings!"
	var audioRecorder: AVAudioRecorder!

	// MARK: - IBOutlets

	@IBOutlet private weak var recordingLabel: UILabel!
	@IBOutlet private weak var recordButton: UIButton!
	@IBOutlet private weak var stopRecordingButton: UIButton!

	// MARK: - IBActions

	@IBAction private func recordAudio( _ sender: Any ) {
		configureUI( true )

		let dirPath = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[ 0 ] as String
		let recordingName = "recordedVoice.wav"
		let pathArray = [ dirPath, recordingName ]
		let filePath = URL( string: pathArray.joined( separator: "/" ) )

		checkMicPermission {
			granted in

			guard granted else {
				self.configureUI( false, true, self.noMicAccess )
				return
			}

			// try! session.setCategory( AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker )
			try! self.session.setCategory( AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker ) // Fixed above line with this
			try! self.session.setActive( true, options: .notifyOthersOnDeactivation )

			try! self.audioRecorder = AVAudioRecorder( url: filePath!, settings: [:] )

			self.audioRecorder.delegate = self
			self.audioRecorder.isMeteringEnabled = true
			self.audioRecorder.prepareToRecord() // simulator prints: ca_debug_string: inPropertyData == NULL
			self.audioRecorder.record()
		}
	}

	@IBAction private func stopRecording( _ sender: Any ) {
		configureUI( false )
		audioRecorder.stop()

		try! session.setActive( false )
	}

	// MARK: - Configure UI

	private func configureUI( _ isRecording: Bool, _ hasError: Bool = false, _ errorText: String = "Recording Unsuccessful." ) {
		guard !hasError else {
			stopRecordingButton.isEnabled = false
			recordButton.isEnabled = errorText.lowercased().contains( "mic access" ) ? false : true
			recordingLabel.text = errorText
			
			return
		}

		recordingLabel.text = isRecording ? "Recording In Progress..." : "Tap To Record"
		recordButton.isEnabled = !isRecording
		stopRecordingButton.isEnabled = isRecording
	}

	// MARK: - Audio Recorder Delegate

	func audioRecorderDidFinishRecording( _ recorder: AVAudioRecorder, successfully flag: Bool ) {
		guard flag else {
			configureUI( false, true )
			return
		}

		performSegue( withIdentifier: "stopRecording", sender: audioRecorder.url )
	}

	// MARK: - checkMicPermission

	// We should check that the user has granted Mic access and provide some indication of when it is not granted
	private func checkMicPermission( _ closure: @escaping ( _ granted: Bool ) -> () ) {
		if ( session.responds( to: #selector( AVAudioSession.requestRecordPermission( _: ) ) ) ) {
			session.requestRecordPermission( { ( granted: Bool ) -> () in
				DispatchQueue.main.async {
					closure( granted )
				}
			} )
		}
	}

	// MARK: - Prepare For Segue

	override func prepare( for segue: UIStoryboardSegue, sender: Any? ) {
		if segue.identifier == "stopRecording" {
			let playSoundsVC = segue.destination as! PlaySoundsViewController
			let recordedAudioUrl = sender as! URL

			playSoundsVC.recordedAudioUrl = recordedAudioUrl
		}
	}

	// MARK: - View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		stopRecordingButton.isEnabled = false

		checkMicPermission {
			granted in

			if !granted {
				self.configureUI( false, true, self.noMicAccess )
			}
		}
	}
}
