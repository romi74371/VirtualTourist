//
//  TaskCancelingCollectionCell.swift
//  VirtualTourist
//
//  Created by Roman Hauptvogel on 11/11/15.
//  Copyright © 2015 Roman Hauptvogel. All rights reserved.
//
import UIKit

class TaskCancelingCollectionViewCell : UICollectionViewCell {
    
    // The property uses a property observer. Any time its
    // value is set it canceles the previous NSURLSessionTask
    
    var imageName: String = ""
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}
