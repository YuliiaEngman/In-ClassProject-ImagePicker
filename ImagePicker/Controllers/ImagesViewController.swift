//
//  ViewController.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation // we want to use AVMakeRect() to maintain image aspect ratio

class ImagesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var imageObjects = [ImageObject]()
    
    private let imagePickerController = UIImagePickerController()
    
    private let dataPersistance = PersistenceHelper(filename: "images.plist")
    
    private var selectedImage: UIImage? {
        didSet {
            // gets called when new image is selected
            appendNewPhotoToCollection()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // set UIImagePickerController delegate as this view controller
        imagePickerController.delegate = self
        
        loadImageObjects()
    }
    
    private func appendNewPhotoToCollection() {
        guard let image = selectedImage else {
                print("image is nil")
                return
        }
        print("original image size is \(image.size)")
        
        //resize image
        let size = UIScreen.main.bounds.size
        
        // we will maintain the aspect ratio of the image
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        //resize image
        let resizeImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
        
        print("resized image size is \(resizeImage.size)")
        
        // jpegData(compressionQuality: 1.0 converts UIImage to Data
        guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // create an ImageObject using image selected
        let imageObject = ImageObject(imageData: resizedImageData, date: Date())
        
        //insert new imageObject into imageObjects
        imageObjects.insert(imageObject, at: 0)
        
        // create an indexPath for insertion into collection view
        let indexPath = IndexPath(row: 0, section: 0)
        
        // insert new cell into collection view
        collectionView.insertItems(at: [indexPath])
        
        //persist imageObject to documents directory
        do {
            try dataPersistance.create(item: imageObject)
        } catch {
            print("saving error: \(error)")
        }
    }
    
    private func loadImageObjects() {
        do {
            imageObjects = try dataPersistance.loadEvents()
        } catch {
            print("loading objects error: \(error)")
        }
    }
    
    @IBAction func addPictureButtonPressed(_ sender: UIBarButtonItem) {
        //print("button pressed")
        
        // present an action sheet to the user
        // actions: camera, photo library, cancel
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet) // we can use alert instead of actionsheet - this case in will apear in the middle of screen, now everything apears from the bottom
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] alertAction in self?.showImageController(isCameraSelected: true)
            
        }
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { [weak self] alertAction in
            self?.showImageController(isCameraSelected: false)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // check if camera is available
        // if camera is not available the app will crash
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func showImageController(isCameraSelected: Bool) {
        // source type default will be .photoLibrary
        imagePickerController.sourceType = .photoLibrary
        
        if isCameraSelected {
            imagePickerController.sourceType = .camera
        }
        present(imagePickerController, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource
extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // StepIV: creating custom delegation - must have an instance of object Bcreating custom delegation
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {
            fatalError("could not downcast to an ImageCell")
        }
        let imageObject = imageObjects[indexPath.row]
        cell.configureCell(imageObject: imageObject)
        // StepV: creating custom delegation - set delegate object
        // similar ro tableView.delegate = self
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.80
        return CGSize(width: itemWidth, height: itemWidth)  }
}

extension ImagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    // most important - what is that image - here image is come in shape of the dictionary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // we need to access the UIImagePickerController.InfoKey.originalImage key to get the UIImage that was selected
        // since we get back Any type - optional, therefore we have to unwrap it
        // now we have to downcast to UIImage (before it was just Any)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selected not found")
            return
        }
        selectedImage = image
        dismiss(animated: true)
    }
}

// StepVI: creating custom delegation - conform to delegate
extension ImagesViewController: ImageCellDelegate {
    func didLongPress(_ imageCell: ImageCell) {
        print("cell was selected")
    }
}

// more here: https://nshipster.com/image-resizing/
// MARK: - UIImage extension
extension UIImage {
    func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

