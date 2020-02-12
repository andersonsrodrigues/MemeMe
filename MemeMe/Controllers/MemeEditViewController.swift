//
//  ViewController.swift
//  ImagePickerExperiment
//
//  Created by Anderson Rodrigues on 11/11/2019.
//  Copyright © 2019 Anderson Rodrigues. All rights reserved.
//

import UIKit

// MARK: - MemeEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate

class MemeEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var meme: Meme?
    var indexPath: IndexPath?
    var isEditingMeme: Bool = false

    // MARK: - IBOutlets
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var albumBarButton: UIBarButtonItem!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    @IBOutlet weak var toolbarTop: UIToolbar!
    @IBOutlet weak var toolbarBottom: UIToolbar!

    // MARK: - Text Attributes
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
        self.setupTextFieldStyle(toTextField: self.topTextField, withText: "TOP")
        self.setupTextFieldStyle(toTextField: self.bottomTextField, withText: "BOTTOM")
        
        // Scale the image to have an aspect Fitted
        self.imagePickerView.contentMode = .scaleAspectFit
        
        if let meme = self.meme {
            self.imagePickerView.image  = meme.originalImage
            self.topTextField.text      = meme.topText
            self.bottomTextField.text   = meme.bottomText
            self.isEditingMeme          = true
            
            self.setSituationButtons(true)
        } else {
            self.setSituationButtons(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribe notifications of keyboard
        self.subscribeToKeyboardNotification()
        
        // Disable/Enable camera button if the source has available
        self.cameraBarButton.isEnabled  = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove any subscribe notifications of keyboard
        self.unsubscribeKeyboardNotifications()
    }
    
    // MARK: - TextFields
    
    // Function to setup text fields and its features
    func setupTextFieldStyle(toTextField textField: UITextField, withText initText: String) {
        textField.defaultTextAttributes     = memeTextAttributes
        textField.delegate                  = memeMeTextFieldDelegate
        textField.textAlignment             = .center
        textField.autocapitalizationType    = .allCharacters
        textField.borderStyle               = .none
        
        textField.text = initText
    }
    
    // MARK: - Actions
    
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
                
                if (!self.isEditingMeme) {
                    NotificationCenter.default.post(name: NSNotification.Name("reloadTable"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("reloadCollection"), object: nil)
                }
            }
        }
        
        if let popoverPres = activityView.popoverPresentationController {
            popoverPres.barButtonItem = self.shareBarButton
        }
        
        self.present(activityView, animated: true, completion: nil)
    }

    // Action to cancel the meme image and return to begin
    @IBAction func cancelButton(_ sender: Any) {
        self.setSituationButtons(false)
        
        self.imagePickerView.image  = nil
        
        self.topTextField.text      = "TOP"
        self.bottomTextField.text   = "BOTTOM"
        
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Picker Controller Delegate & Initializes
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[.originalImage] as? UIImage {
            self.imagePickerView.image = imagePicked
            self.setSituationButtons(true)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Initialize picker controller
    func invokePickerController(_ type: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        
        present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Features
    
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
    
    // MARK: - Keyboard - Notifications
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Memed Functions

    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: self.generateMemedImage())
        
        // And then add it to the memes array in the Application Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if self.isEditingMeme {
            appDelegate.memes[(self.indexPath!).row] = meme
            
            NotificationCenter.default.post(name: NSNotification.Name("reloadImage"), object: nil, userInfo: ["meme": meme])
        } else {
            appDelegate.memes.append(meme)
        }
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        self.hideToolbars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        self.hideToolbars(false)
        
        return memedImage
    }
    
    // MARK: - Toolbar & Buttons Functions
    func setSituationButtons(_ enabled: Bool) {
        self.shareBarButton.isEnabled   = enabled
    }
    
    func hideToolbars(_ hide: Bool) {
        self.toolbarTop.isHidden = hide
        self.toolbarBottom.isHidden = hide
    }
}

