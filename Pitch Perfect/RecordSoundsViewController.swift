//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Eric Winn on 3/15/15.
//  Copyright (c) 2018 Eric N. Winn. All rights reserved.
//

// NOTE: Renamed github remote repo from UDACITY to Pitch-Perfect

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var audioName: String!
    var audioFilename: URL!
    var recordingSession: AVAudioSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordLabel.text = "Tap to Record"
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        // Annoying Swift 4.1 and iOS 10+ issue: https://stackoverflow.com/questions/52413107/avaudiosession-setcategory-availability-in-swift-4-2
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
        } catch {
            //            self.loadFailUI(alertTitle: "Audio session error", alertMessage: "Could not initialize audio session.")
            print("Could not set audio session category: \(error.localizedDescription)")
        }
        do {
            try recordingSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            //            self.loadFailUI(alertTitle: "Audio session error", alertMessage: "Could not initialize audio session.")
            print("Could not set audio session active: \(error.localizedDescription)")
        }

        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.startRecording()
                } else {
                    self.loadFailUI(alertTitle: "Permissions error", alertMessage: "Use of microphone was not approved.")
                }
            }
        }
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getRecordingURL() -> URL {
        // Placeholder for future developtment
//        let currentDateTime = NSDate()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyyMMdd-HHmmss"
//        let recordingName = formatter.string(from: currentDateTime as Date) + ".m4a"
        let recordingName = "PitchPerfect.m4a"

        // Debugging...
        print("recordingName: \(recordingName)")
        return getDocumentsDirectory().appendingPathComponent(recordingName)
    }
    
    func startRecording() {
        recordLabel.text = "recording..."
        stopButton.isEnabled = true
        recordButton.isEnabled = false
        audioFilename = RecordSoundsViewController.getRecordingURL()
        audioName = audioFilename.lastPathComponent
        
        //Debugging...
//        print("audioFilename.absoluteURL: \(audioFilename.absoluteURL)")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = false
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch {
            loadFailUI(alertTitle: "Start recording", alertMessage: "Error trying to start the audio recorder")
        }
    }
    
    func loadFailUI(alertTitle: String, alertMessage: String) {
        let ac = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @IBAction func stopButton(sender: UIButton) {
        recordLabel.text = "Tap to Record"
        recordButton.isEnabled = true
        stopButton.isEnabled = false
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch _ {
            loadFailUI(alertTitle: "Audio session error", alertMessage: "Error trying to set the audio session to inactive.")
        }
    }
    
    // NOTE: The delegate calls this function
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            loadFailUI(alertTitle: "Finish recording", alertMessage: "Something interrupted the attempt to finsih the recording.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            // Work-around until I figure out why the seque was not passing the URL value...
            playSoundsVC.receivedAudioName = audioName
//            let recordedAudioURL = sender as! URL
//            playSoundsVC.receivedAudioFilename = recordedAudioURL
        }
    }
    
}

