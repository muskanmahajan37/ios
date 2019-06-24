//
//  FilesTableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 08/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import Lightbox
import AVFoundation
import GoogleCast

class FilesViewController: BaseUIViewController, GCKSessionManagerListener,
GCKRemoteMediaClientListener, GCKRequestDelegate {
    
    enum PlaybackMode: Int {
        case none = 0
        case local
        case remote
    }
    
    var mediaInfo: GCKMediaInformation? {
        didSet {
            print("setMediaInfo: \(String(describing: mediaInfo))")
        }
    }
    
    public var sessionManager: GCKSessionManager!
    public var mediaInformation: GCKMediaInformation?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sessionManager = GCKCastContext.sharedInstance().sessionManager
    }
    
    public var playbackMode = PlaybackMode.none
    
    // Mark - Server properties, will be set from presenting class
    public var directory: ServerFile?
    public var share: ServerShare!
    
    private var castButton: GCKUICastButton!
    
    // Mark - TableView data properties
    internal var serverFiles: [ServerFile] = [ServerFile]()
    internal var filteredFiles: [ServerFile] = [ServerFile]()
    
    internal var fileSort = FileSort.modifiedTime
    
    /*
     KVO context used to differentiate KVO callbacks for this class versus other
     classes in its class hierarchy.
     */
    internal var playerKVOContext = 0
    
    // Mark - UIKit properties
    @IBOutlet var filesTableView: UITableView!
    internal var refreshControl: UIRefreshControl!
    internal var downloadProgressAlertController : UIAlertController?
    internal var progressView: UIProgressView?
    internal var docController: UIDocumentInteractionController?
    
    @objc internal var player: AVPlayer!
    
    internal var isAlertShowing = false
    internal var presenter: FilesPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = FilesPresenter(self)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        filesTableView.addSubview(refreshControl)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        filesTableView.addGestureRecognizer(longPressGesture)
        
        self.navigationItem.title = getTitle()
        
        presenter.getFiles(share, directory: directory)
        
        castButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                                   width: CGFloat(24), height: CGFloat(24)))
        castButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(castDeviceDidChange),
                                               name: NSNotification.Name.gckCastStateDidChange,
                                               object: GCKCastContext.sharedInstance())
    }
    
    @objc func castDeviceDidChange(_: Notification) {
        if GCKCastContext.sharedInstance().castState != .noDevicesAvailable {
            // You can present the instructions on how to use Google Cast on
            // the first time the user uses you app
            GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: castButton)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // showDownloadsIconIfOfflineFileExists()
        presenter.loadOfflineFiles()
        let hasConnectedSession: Bool = (sessionManager.hasConnectedSession())
        if hasConnectedSession, (playbackMode != .remote) {
            //populateMediaInfo(false, playPosition: 0)
            //switchToRemotePlayback()
            // Do: Cast the video
            
        } else if sessionManager.currentSession == nil, (playbackMode != .local) {
            //switchToLocalPlayback()
            // Do: Play locally
            
        }
        sessionManager.add(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            sessionManager.remove(self)
            super.viewWillDisappear(animated)
    }
    
    @objc func handleLongPress(sender: UIGestureRecognizer) {
        
        let touchPoint = sender.location(in: filesTableView)
        if let indexPath = filesTableView.indexPathForRow(at: touchPoint) {
            
            let file = self.filteredFiles[indexPath.row]
            
            if file.isDirectory { return }
            
            let download = self.creatAlertAction(StringLiterals.download, style: .default) { (action) in
                let file = self.filteredFiles[indexPath.row]
                self.presenter.makeFileAvailableOffline(file)
            }!
            let state = presenter.checkFileOfflineState(file)

            let share = self.creatAlertAction(StringLiterals.share, style: .default) { (action) in
                self.presenter.shareFile(file, fileIndex: indexPath.row,
                                         from: self.filesTableView.cellForRow(at: indexPath))
            }!
            
            let removeOffline = self.creatAlertAction(StringLiterals.removeOfflineMessage, style: .default) { (action) in
            }!
            
            let stop = self.creatAlertAction(StringLiterals.stopDownload, style: .default) { (action) in
            }!
            
            var actions = [UIAlertAction]()            
            actions.append(share)

            if state == .none {
                actions.append(download)
            } else if state == .downloaded {
                actions.append(removeOffline)
            } else if state == .downloading {
                actions.append(stop)
            }
            
            let cancel = self.creatAlertAction(StringLiterals.cancel, style: .cancel, clicked: nil)!
            actions.append(cancel)
            
            self.createActionSheet(title: "",
                                   message: StringLiterals.chooseOne,
                                   ltrActions: actions,
                                   preferredActionPosition: 0,
                                   sender: filesTableView.cellForRow(at: indexPath))
        }
    }
    
    @objc func userClickMenu(sender: UIGestureRecognizer) {
        handleLongPress(sender: sender)
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        presenter.getFiles(share, directory: directory)
    }
    
    func getTitle() -> String? {
        if directory != nil {
            return directory!.name
        }
        return share!.name
    }
    
    internal func setupDownloadProgressIndicator() {
        downloadProgressAlertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView?.setProgress(0.0, animated: true)
        progressView?.frame = CGRect(x: 10, y: 100, width: 250, height: 2)
        downloadProgressAlertController?.view.addSubview(progressView!)
        let height:NSLayoutConstraint = NSLayoutConstraint(item: downloadProgressAlertController!.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 120)
        downloadProgressAlertController?.view.addConstraint(height);
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc: FilesViewController = segue.destination as! FilesViewController
        vc.share = self.share
        vc.directory = filteredFiles[(filesTableView.indexPathForSelectedRow?.row)!]
    }
    
    // MARK: - GCKSessionManagerListener
    
    func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
        print("MediaViewController: sessionManager didStartSession \(session)")
        //setQueueButtonVisible(true)
        //switchToRemotePlayback()
    }
    
    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
        print("MediaViewController: sessionManager didResumeSession \(session)")
        //setQueueButtonVisible(true)
        //switchToRemotePlayback()
    }
    
    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
        print("session ended with error: \(String(describing: error))")
        let message = "The Casting session has ended.\n\(String(describing: error))"
        if let window = appDelegate!.window {
            Toast.displayMessage(message, for: 3, in: window)
        }
        //setQueueButtonVisible(false)
        //switchToLocalPlayback()
    }
    
    func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError error: Error?) {
        if let error = error {
            showAlert(withTitle: "Failed to start a session", message: error.localizedDescription)
        }
        //setQueueButtonVisible(false)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertView(title: title,
                                message: message,
                                delegate: nil,
                                cancelButtonTitle: "OK",
                                otherButtonTitles: "")
        alert.show()
    }
    
    func sessionManager(_: GCKSessionManager,
                        didFailToResumeSession _: GCKSession, withError _: Error?) {
        if let window = UIApplication.shared.delegate?.window {
            Toast.displayMessage("The Casting session could not be resumed.",
                                 for: 3, in: window)
        }
        //setQueueButtonVisible(false)
        //switchToLocalPlayback()
    }
}
