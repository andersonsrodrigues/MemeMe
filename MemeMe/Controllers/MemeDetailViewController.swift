//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Anderson Soares Rodrigues on 31/01/20.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

private let reuseNewMemeIdentifier = "MemeEditViewController"
private let reuseNotificationIdentifier = "reloadImage"

class MemeDetailViewController: UIViewController {
    
    // MARK: Properties
    var meme: Meme?
    var indexPathMeme: IndexPath?
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editMemeButton = UIBarButtonItem(title: "Editar", style: .plain, target: self, action: #selector(editMeme))
        editMemeButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = editMemeButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.imageView.image = self.meme?.memedImage
        self.subscribeToReloadImageNotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.unsubscribeReloadImageNotifications()
    }
    
    // MARK: - Functions
    
    @objc func editMeme() {
        let memeEditView = storyboard?.instantiateViewController(withIdentifier: reuseNewMemeIdentifier) as! MemeEditViewController
        memeEditView.indexPath = self.indexPathMeme
        memeEditView.meme = self.meme
        self.navigationController?.showDetailViewController(memeEditView, sender: self)
    }
    
    @objc func reloadImage(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Meme]
        {
            for meme in data {
                self.meme = meme.value
                self.imageView.image = meme.value.memedImage
            }
        }
    }
    
    // MARK: Table - Notifications
    func subscribeToReloadImageNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadImage(_:)), name: NSNotification.Name(rawValue: reuseNotificationIdentifier), object: nil)
    }
    
    func unsubscribeReloadImageNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: reuseNotificationIdentifier), object: nil)
    }
}
