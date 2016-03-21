//
//  TweetIndex.swift
//  PeekInternDemo
//
//  Created by Rohin Bhushan on 3/19/16.
//  Copyright © 2016 rohinbhushan. All rights reserved.
//

import Foundation

// takes JSON Dictionary and stores desired info
struct Tweet {
    var avatar: String
    var user: String
    var text: String
    var id: String
    init(status: NSDictionary) {
        text = status["text"] as! String
        print(text)
        avatar = status["user"]!["profile_image_url"] as! String
        user = status["user"]!["name"] as! String
        id = status["id_str"] as! String
    }
}
