//
//  StandardMusic.swift
//  StandardMusic
//
//  Created by Roman Kiruxin on 12.04.2022.
//

import Foundation

struct Music {
    let name:String
}

extension Music {
    static func getMusic() -> [Music] {

        return [
            Music(name: "Audio1"),
            Music(name: "Audio2"),
            Music(name: "Audio3")
        ]
    }
}
