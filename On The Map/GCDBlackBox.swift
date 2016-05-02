//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Richard smith on 4/19/16.
//  Copyright © 2016 Richard smith. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}