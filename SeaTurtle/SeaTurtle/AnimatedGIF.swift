//
//  AnimatedGIF.swift
//  SeaTurtle
//
//  Created by David Kopec on 6/29/18.
//  Copyright © 2018 David Kopec. All rights reserved.
//

import Foundation
import ImageIO

struct AnimatedGIF {
    struct GIFWriteError: LocalizedError {
        
    }
    
    let images: [CGImage]
    let delay: Double // in seconds
    let loop: Int // number of times to loop (0 is forever)
    
    func write(destinationURL: URL) {
        // based on Apple example code
        // https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/ImageIOGuide/ikpg_dest/ikpg_dest.html#//apple_ref/doc/uid/TP40005462-CH219-SW3
        
        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loop]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): delay]] as CFDictionary

        
        let url = destinationURL as CFURL
        guard let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) else {
            print("Could not create destination for \(images.count) frames of GIF at \(url)")
            return
        }
        CGImageDestinationSetProperties(destination, fileProperties)
        
        for image in images {
            CGImageDestinationAddImage(destination, image, frameProperties)
        }
        
        if !CGImageDestinationFinalize(destination) {
            // error occured because finalize returned false
            print("Could not finalize \(images.count) frames of GIF at \(url)")
        }
    }
}
