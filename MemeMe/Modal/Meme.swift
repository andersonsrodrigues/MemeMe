//
//  Meme.swift
//  MemeMe-1.0
//
//  Created by Anderson Rodrigues on 11/11/2019.
//  Copyright © 2019 Anderson Rodrigues. All rights reserved.
//

import UIKit

struct Meme {
    let topText: String
    let bottomText: String
    let originalImage: UIImage
    let memedImage: UIImage
    
    func fullTitle() -> String {
        return "\(self.topText) \(self.bottomText)"
    }
}
