//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Eric Winn on 3/15/15.
//  Copyright (c) 2018 Eric N. Winn. All rights reserved.
//

// NOTE: Renamed github remote repo from UDACITY to Pitch-Perfect
// NOTE: Swift 4.2 change reference https://stackoverflow.com/questions/52413107/avaudiosession-setcategory-availability-in-swift-4-2

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: URL!
    var recordingSession: AVAudioSession!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordLabel.text = "Tap to Record"
        stopButton.isHidden = true
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        
//        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
//        let currentDateTime = NSDate()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyyMMdd-HHmmss"
//
//        let recordingName = formatter.string(from: currentDateTime as Date) + ".wav"
//        let pathArray = [dirPath, recordingName]
//        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch _ {
            self.loadFailUI()
        }
        
        
//        audioRecorder = try? AVAudioRecorder(URL: filePath!, settings: nil)
//        audioRecorder = try? AVAudioRecorder(url: filePath!, settings: [:])
//        audioRecorder.delegate = self
//        audioRecorder.isMeteringEnabled = true
//        audioRecorder.record()
        
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getRecordingURL() -> URL {
                let currentDateTime = NSDate()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd-HHmmss"
                let recordingName = formatter.string(from: currentDateTime as Date) + ".m4a"
        return getDocumentsDirectory().appendingPathComponent(recordingName)
    }
    
    func startRecording() {
        recordLabel.text = "recording..."
        stopButton.isHidden = false
        recordButton.isEnabled = false
        
//        let audioURL = RecordSoundsViewController.getRecordingURL()
//        print(audioURL.absoluteString)
        recordedAudio = RecordSoundsViewController.getRecordingURL()
        print(recordedAudio.absoluteString)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordedAudio, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            self.performSegue(withIdentifier: "stopRecording", sender: recordedAudio)
        } else {
            recordButton.isEnabled = true
            recordLabel.text = "Tap to Record"
            stopButton.isHidden = true
            
            let ac = UIAlertController(title: "Recording failed", message: "There was a problem recording, please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func loadFailUI() {
        recordLabel.text = "Recording failed: please ensure the app has access to your microphone."
        recordLabel.numberOfLines = 0
    }
    
//    // NOTE: The delegate calls this function
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if (flag) {
//            // Step 1 - Save the recorded audio
//            recordedAudio = RecordedAudio(filePathUrl: recorder.url as NSURL, title: recorder.url.lastPathComponent)
//
//            // Step 2 - perform segue
//            self.performSegue(withIdentifier: "stopRecording", sender: recordedAudio) }
//        else {
//            recordButton.isEnabled = true
//            recordLabel.text = "Tap to Record"
//            stopButton.isHidden = true
//        }
//    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC: PlaySoundsViewController = segue.destination as! PlaySoundsViewController
//            let data = sender as! RecordedAudio
            let data = sender as! URL
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopButton(sender: UIButton) {
        finishRecording(success: true)
        
//        recordLabel.text = "Tap to Record"
//        stopButton.isHidden = true
//        recordButton.isEnabled = true
        
//        audioRecorder.stop()
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setActive(false)
//        } catch _ {
//        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
