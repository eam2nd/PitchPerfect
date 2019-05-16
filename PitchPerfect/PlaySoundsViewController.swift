//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Edward Morton on 5/13/19.
//  Copyright © 2019 Edward Morton. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

	// MARK: - Properties

	var recordedAudioUrl: URL!
	var audioFile:AVAudioFile!
	var audioEngine:AVAudioEngine!
	var audioPlayerNode: AVAudioPlayerNode!
	var stopTimer: Timer!

	private enum ButtonType: Int {
		case slow = 0, fast, chipmunk, vader, echo, reverb
	}

	// MARK: - IBOutlets

	@IBOutlet weak var slowSnailButton: UIButton!
	@IBOutlet weak var fastRabbitButton: UIButton!
	@IBOutlet weak var highPitchChipmunkButton: UIButton!
	@IBOutlet weak var lowPitchVaderButton: UIButton!
	@IBOutlet weak var echoButton: UIButton!
	@IBOutlet weak var reverbButton: UIButton!
	@IBOutlet weak var stopButton: UIButton!

	// MARK: - IBActions

	@IBAction private func stopButtonTapped( _ sender: AnyObject ) {
		stopAudio()
	}

	@IBAction private func playButtonTapped( _ sender: UIButton ) {
		switch( ButtonType( rawValue: sender.tag )! ) {
			case .slow:
				playSound( rate: 0.5 )
			case .fast:
				playSound( rate: 1.5 )
			case .chipmunk:
				playSound( pitch: 1000 )
			case .vader:
				playSound( pitch: -1000 )
			case .echo:
				playSound( echo: true )
			case .reverb:
				playSound( reverb: true )
		}

		configureUI( .playing )
	}

	// MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		setupAudio()

		// Apply scaleAspectFit to playback buttons to avoid distortion on smaller screens
		for button: UIButton in [
			slowSnailButton,
			fastRabbitButton,
			highPitchChipmunkButton,
			lowPitchVaderButton,
			echoButton,
			reverbButton
		] {
			button.imageView?.contentMode = .scaleAspectFit
		}
    }

	override func viewWillAppear( _ animated: Bool ) {
		super.viewWillAppear( animated )

		configureUI( .notPlaying )
	}
}
