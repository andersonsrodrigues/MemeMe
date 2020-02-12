//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Anderson Soares Rodrigues on 31/01/20.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

private let reuseCollectionIdentifier = "memeCollectionCell"
private let reuseDetailIdentifier = "MemeDetailView"
private let reuseNotificationIdentifier = "reloadCollection"
private let reuseNewMemeIdentifier = "MemeEditViewController"

// MARK: - SentMemesCollectionViewController: UICollectionViewController

class SentMemesCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    var memes: [Meme]!
    
    // MARK: - Outlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.renderCollectionFlowLayout()
        self.addNewMemeButton()
        self.subscribeToReloadTableNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadAllMemes()
        self.collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.unsubscribeReloadTableNotifications()
    }

    // MARK: Collection View Data Source

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCollectionIdentifier, for: indexPath as IndexPath) as! SentMemeCollectionViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
    
        cell.memeImageView.image = meme.memedImage
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: reuseDetailIdentifier) as! MemeDetailViewController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        detailController.indexPathMeme = indexPath
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    @objc func reloadCollection(_ notification: Notification) {
        self.loadAllMemes()
        self.collectionView.reloadData()
    }
    
    // MARK: - Collection View Flow Layout
    
    func renderCollectionFlowLayout() {
        let space:CGFloat = 3.0
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        var dimension = (width - (2 * space)) / 3.0
        
        if width > height {
            dimension = (height - (2 * space)) / 3.0
        }

        self.flowLayout.minimumInteritemSpacing = space
        self.flowLayout.minimumLineSpacing = space
        self.flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // MARK: - Actions
    
    @objc func newMeme() {
        let memeEditView = storyboard?.instantiateViewController(withIdentifier: reuseNewMemeIdentifier) as! MemeEditViewController
        self.present(memeEditView, animated: true, completion: nil)
    }
    
    // MARK: Table - Notifications
    func subscribeToReloadTableNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollection(_:)), name: NSNotification.Name(rawValue: reuseNotificationIdentifier), object: nil)
    }
    
    func unsubscribeReloadTableNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: reuseNotificationIdentifier), object: nil)
    }

    // MARK: - Meme Functions
    
    func loadAllMemes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.memes = appDelegate.memes
    }
    
    // MARK: - General Functions
    
    func addNewMemeButton() {
        let addNewMeme = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newMeme))
        addNewMeme.tintColor = .white
        self.navigationItem.rightBarButtonItem = addNewMeme
    }
}
