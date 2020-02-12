//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Anderson Soares Rodrigues on 31/01/20.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

private let reuseTableIdentifier = "memeTableCell"
private let reuseDetailIdentifier = "MemeDetailView"
private let reuseNotificationIdentifier = "reloadTable"
private let reuseNewMemeIdentifier = "MemeEditViewController"

// MARK: - SentMemesTableViewController: UITableViewController

class SentMemesTableViewController: UITableViewController {
    
    // MARK: - Properties
    var memes: [Meme]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addNewMemeButton()
        self.subscribeToReloadTableNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadAllMemes()
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        self.unsubscribeReloadTableNotifications()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseTableIdentifier) as! SentMemeTableViewCell
        let meme = memes[(indexPath as NSIndexPath).row]
        
        cell.memeLabel?.text = meme.fullTitle()
        cell.memeImageView?.image = meme.memedImage
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: reuseDetailIdentifier) as! MemeDetailViewController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        detailController.indexPathMeme = indexPath
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteMemeByIndexPath(indexPath)
        }
    }
    
    @objc func reloadTable(_ notification: Notification) {
        self.loadAllMemes()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0;
    }
    
    // MARK: - Actions
    
    @objc func newMeme() {
        let memeEditView = storyboard?.instantiateViewController(withIdentifier: reuseNewMemeIdentifier) as! MemeEditViewController
        self.present(memeEditView, animated: true, completion: nil)
    }
    
    // MARK: Table - Notifications
    func subscribeToReloadTableNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable(_:)), name: NSNotification.Name(rawValue: reuseNotificationIdentifier), object: nil)
    }
    
    func unsubscribeReloadTableNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: reuseNotificationIdentifier), object: nil)
    }

    // MARK: - Meme Functions
    
    func loadAllMemes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.memes = appDelegate.memes
    }
    
    func deleteMemeByIndexPath(_ index: IndexPath) {
        tableView.beginUpdates()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.memes.remove(at: index.row)
        appDelegate.memes = self.memes
        self.tableView.deleteRows(at: [index], with: .automatic)
        
        tableView.endUpdates()
    }
    
    // MARK: - General Functions
    
    func addNewMemeButton() {
        let addNewMeme = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newMeme))
        addNewMeme.tintColor = .white
        self.navigationItem.rightBarButtonItem = addNewMeme
    }
}
