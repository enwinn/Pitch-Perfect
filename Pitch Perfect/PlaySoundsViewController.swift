//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Eric Winn on 3/21/15.
//  Copyright (c) 2018 Eric N. Winn. All rights reserved.
//

import UIKit
import AVFoundation

// NOTE: Full property sets and range checks are for future expansion
// NOTE: Renamed github remote repo from UDACITY to Pitch-Perfect
// NOTE: Add a 7th button for adhoc playback with more control with something like:
//       https://www.hackingwithswift.com/example-code/media/how-to-control-the-pitch-and-speed-of-audio-using-avaudioengine
// NOTE: Swift 4.2 change reference https://stackoverflow.com/questions/52413107/avaudiosession-setcategory-availability-in-swift-4-2


class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioPlayerNode: AVAudioPlayerNode!
    var audioPlayer: AVAudioPlayer!
    var receivedAudioFilename: URL!
    var receivedAudioName: String!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var stopTimer: Timer!
    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()

        stopButton.isEnabled = false
        
        // Debugging
//        print("receivedAudioName: \(String(describing: receivedAudioName))")
//        print("receivedAudioFilename: \(receivedAudioFilename.absoluteURL)")
        
        audioEngine = AVAudioEngine()
        audioPlayer = try? AVAudioPlayer(contentsOf: receivedAudioFilename)
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    
    // MARK: Actions
    @IBAction func playSoundForButton(_ sender: UIButton) {
        
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 2.0)
        case .chipmunk:
            playSound(pitch: 1200)
        case .vader:
            playSound(pitch: -700)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        
        configureUI(.playing)
    }

    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        
        stopAudio()
    }
    

    //MARK: Delegates
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (flag) {
            stopButton.isEnabled = false
        }
    }
}
