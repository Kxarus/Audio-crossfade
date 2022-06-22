//
//  AudioListController.swift
//  AudioListController
//
//  Created by Roman Kiruxin on 12.04.2022.
//

import UIKit

class AudioListController: UITableViewController {

    private let musicList = Music.getMusic()
    private var audioName = ""
    
    var buttonTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMainScreen" {
            guard let destinationController = segue.destination as? ViewController else { return }
                if buttonTag == 1 {
                    destinationController.audioTitle1 = audioName
                } else if buttonTag == 2 {
                    destinationController.audioTitle2 = audioName
                }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = musicList[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let cell = tableView.cellForRow(at: indexPath)
        audioName = cell?.textLabel?.text ?? "Ошибка, выберите еще раз"
        
        performSegue(withIdentifier: "toMainScreen", sender: audioName)
    }
}
