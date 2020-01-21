//
//  ImageCell.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

// stepI: creating custom delegation - defind protocol
protocol ImageCellDelegate: AnyObject { // AnyObject requires ImageCellDelegate only works with class type
    // list required functions, initializers, variable
    func didLongPress(_ imageCell: ImageCell)
}

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    //stepII: creating custom delegation - define optional delegate variable
    weak var delegate: ImageCellDelegate?
    
    // setup long press gesture recognizer
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(longPressedAction(gesture:)))
        return gesture
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20.0
        backgroundColor = .orange
        
        // step3: long press setup - added gesture to view
        addGestureRecognizer(longPressGesture)
    }
    //step2: long press setup
    // function gets called when long press is activated
    @objc
    private func longPressedAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {// if gesture is active
            gesture.state = .cancelled
            return
        }
        //print("long press activated")
        
        //stepIII: creating custom delegation - explicitly use delegate object to notify of any updates e.g. notifying the ImagesViewController when the user long presses on the cell
        delegate?.didLongPress(self)
        // cell.delegate = self
        //imageViewController -> didLongPress(:)
    }
    
    
    public func configureCell(imageObject: ImageObject) {
        // convertion Data to UIImage
        guard let image = UIImage(data: imageObject.imageData) else {
            return
        }
        imageView.image = image
    }
    
}
