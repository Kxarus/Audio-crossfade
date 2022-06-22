//
//  ViewController.swift
//  Audio crossfade
//
//  Created by Roman Kiruxin on 12.04.2022.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {

    @IBOutlet weak var crossfadeNumber: UILabel!
    @IBOutlet weak var crossfadeSlider: UISlider!
    
    @IBOutlet weak var audio1: UIButton!
    @IBOutlet weak var audio2: UIButton!
    
    @IBOutlet weak var playBack: UIButton!
    
    var audioTitle1 = "Выберите аудиофайл №1"
    var audioTitle2 = "Выберите аудиофайл №2"
    
    var player1 = AVAudioPlayer()
    var player2 = AVAudioPlayer()
    var playerIsOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playBack.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        audio1.setTitle(audioTitle1, for: .normal)
        audio2.setTitle(audioTitle2, for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (audio1.titleLabel?.text != "Выберите аудиофайл №1") && (audio2.titleLabel?.text != "Выберите аудиофайл №2") {
            playBack.isHidden = false
        } else {
            playBack.isHidden = true
        }
    }
    
    @IBAction func unwindToMainScreen(_ segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "audio1":
            guard let destinationAudioList = segue.destination as? AudioListController else { return }
            destinationAudioList.buttonTag = 1
        case "audio2":
            guard let destinationAudioList = segue.destination as? AudioListController else { return }
            destinationAudioList.buttonTag = 2
        default:
            break
        }
    }
    
    fileprivate func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(Int(delay))) {
            closure()
        }
    }
    
    func playMusic1(crossfade: Double, duration: CMTime) {
        do {
            player1 = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: audioTitle1, ofType: "mp3")!) as URL)

            if player2.isPlaying == false {
                player1.play()
                delay(duration.seconds - crossfade) {
                    self.player1.setVolume(0.0000000001, fadeDuration: crossfade)
                }
            } else {
                player1.volume = 0.001
                player1.play()
                player1.setVolume(1.0, fadeDuration: crossfade)
                
                delay(duration.seconds - crossfade) {
                    self.player1.setVolume(0.000000001, fadeDuration: crossfade)
                }
            }
        } catch {
            print(Error.self)
        }
    }
    
    func playMusic2(crossfade: Double, duration: CMTime) {

        do {
            player2 = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: audioTitle2, ofType: "mp3")!) as URL)
            
            player2.volume = 0.00000001
            player2.play()
            player2.setVolume(1.0, fadeDuration: crossfade)
            delay(duration.seconds - crossfade) {
                self.player2.setVolume(0.000000001, fadeDuration: crossfade)
            }
        } catch {
            print(Error.self)
        }
    }

    @IBAction func musicPlayback(_ sender: Any) {

        crossfadeSlider.isHidden = true
        audio1.isEnabled = false
        audio2.isEnabled = false
        playBack.setTitle("Закончить воспроизведение", for: .normal)
        
        //crossfade
        let crossfade = Double(round(crossfadeSlider.value))
        
        //Вычисляем длину композиций
        guard let url1 = Bundle.main.url(forResource: audioTitle1, withExtension: "mp3") else { return }
        let avAsset1 = AVURLAsset(url: url1, options: nil)
        let durationAudio1 = avAsset1.duration
        guard let url2 = Bundle.main.url(forResource: audioTitle2, withExtension: "mp3") else { return }
        let avAsset2 = AVURLAsset(url: url2, options: nil)
        let durationAudio2 = avAsset2.duration
        
        //Вычисляем длины задержек
        let delay1: Double
        let delay2: Double
        
        if CMTimeGetSeconds(durationAudio1) < crossfade {
            delay1 = 0
        } else {
            delay1 = Double(CMTimeGetSeconds(durationAudio1)) - crossfade
        }

        if CMTimeGetSeconds(durationAudio2) < crossfade {
            delay2 = 0
        } else {
            delay2 = Double(CMTimeGetSeconds(durationAudio2)) - crossfade
        }
        
        let group = DispatchGroup()
        if playerIsOn == false {
            DispatchQueue.global().async { [self] in
                playerIsOn = true
                repeat {
                    group.enter()
                    if playerIsOn == true || player2.isPlaying == true {
                        playMusic1(crossfade: crossfade, duration: durationAudio1)
                    }
                    group.wait(timeout: .now() + delay1)

                    if player1.isPlaying {
                        playMusic2(crossfade: crossfade, duration: durationAudio2)
                    }

                    group.wait(timeout: .now() + delay2)
                    group.leave()
                    } while (playerIsOn == true)
            }
        } else {
            playerIsOn = false
            player1.stop()
            player2.stop()
            
            crossfadeSlider.isHidden = false
            audio1.isEnabled = true
            audio2.isEnabled = true
            playBack.setTitle("Начать воспроизведение", for: .normal)
        }
    }
    
    @IBAction func slider(_ sender: Any) {
        crossfadeNumber.text = String(Int(round(crossfadeSlider.value)))
    }
}

