//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Eric Winn on 3/21/15.
//  Copyright (c) 2015 Eric N. Winn. All rights reserved.
//

import UIKit
import AVFoundation


class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var stopButton: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopButton.enabled = false
        
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()
        
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioSpeed(0.5)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        playAudioSpeed(2.0)
    }
    
    @IBAction func stopAudioPlay(sender: UIButton) {
        stopAllAudio()
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1200, rate: 1.0, overlap: 8.0)
    }
    
    @IBAction func DarthVaderButton(sender: UIButton) {
        playAudioWithVariablePitch(-800, rate: 1.0, overlap: 8.0)
    }
    
    func playAudioSpeed (speed: Float) {
        setAudioSession()
        stopAllAudio()
        
        // Always start at the beginning of the track
        audioPlayer.currentTime = 0.0
        
        // Rate default is 1.0. Range is 0.5 to 2.0 (half to double)
        switch speed {
        case 0.5...2.0:
            audioPlayer.rate = speed
        default:
            audioPlayer.rate = 1.0
        }
        
        audioPlayer.delegate = self
        audioPlayer.meteringEnabled = true
        
        stopButton.enabled = true
        audioPlayer.play()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if (flag) {
            stopButton.enabled = false
        }
    }
    
    func playAudioWithVariablePitch(pitch: Float, rate: Float, overlap: Float){
        setAudioSession()
        stopAllAudio()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        var changeReverbEffect = AVAudioUnitReverb()
        
        changeReverbEffect.loadFactoryPreset(.LargeChamber)
        changeReverbEffect.wetDryMix = 20.0
        
        // Pitch is defined in cents. Default is 1.0. Range is -2400.0 to 2400.0 One octave is 1200 cents, one semitone is 100 cents
        switch pitch {
            case -2400.0...2400.0:
                changePitchEffect.pitch = pitch
            default:
                changePitchEffect.pitch = 1.0
        }
        
        // Rate default is 1.0. Range is 1/32 to 32.0
        switch rate {
            case 1/32...32/0:
                changePitchEffect.rate = rate
            default:
                changePitchEffect.rate = 1.0
        }
        
        //Higher value results in fewer artifacts in output signal. Default value is 8.0. Range is 3.0 to 32.0
        switch overlap {
            case 3.0...32.0:
                changePitchEffect.overlap = overlap
            default:
                changePitchEffect.overlap = 8.0
        }
        
        audioEngine.attachNode(changePitchEffect)
        audioEngine.attachNode(changeReverbEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: changeReverbEffect, format: nil)
        audioEngine.connect(changeReverbEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile,
            atTime: nil,
            completionHandler: audioPlayerNodeCompletion)
        audioEngine.startAndReturnError(nil)
        
        stopButton.enabled = true
        audioPlayerNode.play()
        
    }
    
    // ref: http://www.ios-developer.net/iphone-ipad-programmer/development/threads/updating-ui-controls-on-background-threads
    // ref: Sameer pointed this out to me during our study group on 3/30/2015
    func audioPlayerNodeCompletion() {
        dispatch_async(dispatch_get_main_queue(), {
            // Seems to fire a bit before audio ends, why?
            self.stopButton.enabled = false
        })
    }
    
    func stopAllAudio() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        stopButton.enabled = false
    }
    
    func setAudioSession() {
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
    }
}

