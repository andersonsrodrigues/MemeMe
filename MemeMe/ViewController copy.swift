//
//  ViewController.swift
//  ImagePickerExperiment
//
//  Created by Anderson Rodrigues on 11/11/2019.
//  Copyright © 2019 Anderson Rodrigues. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: IBOutlets
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var albumBarButton: UIBarButtonItem!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    @IBOutlet weak var toolbarBottom: UIToolbar!

    // MARK: Text Attributes
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "Impact", size: 40)!,
        NSAttributedString.Key.strokeWidth: -5.0
    ]
    
    let memeMeTextFieldDelegate = MemeMeTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize defaults informations to Top and Bottom text fields
        self.initTextField()
        
        // Scale the image to have an aspect Fitted
        self.imagePickerView.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribe notifications of keyboard
        self.subscribeToKeyboardNotification()
        
        // Disable/Enable camera button if the source has available
        self.cameraBarButton.isEnabled  = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Define situation of buttons from navigation bar
        self.setSituationButtons(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove any subscribe notifications of keyboard
        self.unsubscribeKeyboardNotifications()
    }
    
    // MARK: TextFields
    
    // Function to provide an initialization for TextFields
    func initTextField() {
        self.topTextField.delegate      = memeMeTextFieldDelegate
        self.bottomTextField.delegate   = memeMeTextFieldDelegate
        
        self.topTextField.text      = "TOP"
        self.bottomTextField.text   = "BOTTOM"
        
        self.topTextField.defaultTextAttributes     = memeTextAttributes
        self.bottomTextField.defaultTextAttributes  = memeTextAttributes
        
        self.topTextField.textAlignment     = .center
        self.bottomTextField.textAlignment  = .center
        
        self.topTextField.borderStyle       = .none
        self.bottomTextField.borderStyle    = .none
    }
    
    // MARK: Actions
    
    // Action for pick an image from album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        self.invokePickerController(.photoLibrary)
    }
    
    // Action for pick an image from camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        self.invokePickerController(.camera)
    }
    
    // Action to show the activity view for options to share the meme image
    @IBAction func shareAnImage(_ sender: Any) {
        let memedImage = self.generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityView.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                self.save()
                self.showAlert("Image saved successfully")
            }
        }
        
        if let popoverPres = activityView.popoverPresentationController {
            popoverPres.barButtonItem = self.shareBarButton
        }
        
        present(activityView, animated: true, completion: nil)
    }

    // Action to cancel the meme image and return to begin
    @IBAction func cancelButton(_ sender: Any) {
        self.setSituationButtons(false)
        
        self.imagePickerView.image  = nil
        
        self.topTextField.text      = "TOP"
        self.bottomTextField.text   = "BOTTOM"
    }

    // MARK: Picker Controller Delegate & Initializes
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[.originalImage] as? UIImage {
            self.imagePickerView.image = imagePicked
            self.setSituationButtons(true)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Initialize picker controller
    func invokePickerController(_ sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        switch sourceType {
        case .camera:
            pickerController.sourceType = .camera
        case .photoLibrary:
            pickerController.sourceType = .photoLibrary
        default:
            pickerController.sourceType = .photoLibrary
        }

        present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: Keyboard Features
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if self.bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Keyboard - Notifications
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Memed Functions

    func save() {
        let memedImage = self.generateMemedImage()
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        self.navigationController?.navigationBar.isHidden = true
        self.toolbarBottom.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        self.navigationController?.navigationBar.isHidden = false
        self.toolbarBottom.isHidden = false
        
        return memedImage
    }
    
    func setSituationButtons(_ enabled: Bool) {
        self.shareBarButton.isEnabled   = enabled
        self.cancelBarButton.isEnabled  = enabled
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController()
        alertController.message = message
        
        let okButton = UIAlertAction(title: "ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okButton)
        
        if let alertPopover = alertController.popoverPresentationController {
            alertPopover.sourceView = self.view
        }
        
        present(alertController, animated: true, completion: nil)
    }
}

