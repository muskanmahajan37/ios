//
//  FilesBaseCollectionViewCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 19..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit
import SwipeCellKit

class FilesBaseCollectionCell: SwipeCollectionViewCell{
    override func awakeFromNib() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hex: "1E2023")
        selectedBackgroundView = backgroundView
    }
    
    func setupArtWork(serverFile: ServerFile, iconImageView: UIImageView){
        let type = serverFile.mimeType
        
        guard let url = ServerApi.shared!.getFileUri(serverFile) else {
            AmahiLogger.log("Invalid file URL, thumbnail generation failed")
            return
        }
        
        switch type {
            
        case MimeType.image:
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "image"), options: .refreshCached)
            break
            
        case .video:
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "video"), options: .refreshCached)
            if iconImageView.image != nil {
                AmahiLogger.log("Video Thumbnail for \(url) obtained from cache")
            } else {
                iconImageView.image = UIImage(named: "video")
                DispatchQueue.global(qos: .background).async {
                    let image = VideoThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        // Code to be executed on the main thread here
                        iconImageView.image = image
                    }
                }
            }
            break
            
        case .audio:
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "audio"), options: .refreshCached)
            if iconImageView.image != nil {
                AmahiLogger.log("Audio Thumbnail for \(url) obtained from cache")
            } else {
                iconImageView.image = UIImage(named: "audio")
                DispatchQueue.global(qos: .background).async {
                    let image = AudioThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        // Code to be executed on the main thread here
                        iconImageView.image = image
                    }
                }
            }
            break
            
        case .presentation, .document, .spreadsheet:
            
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "file"), options: .refreshCached)
            if iconImageView.image != nil {
                AmahiLogger.log("Document Thumbnail for \(url) obtained from cache")
            } else {
                iconImageView.image = UIImage(named: "file")
                
                DispatchQueue.global(qos: .background).async {
                    let image = PDFThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        // Code to be executed on the main thread here
                        iconImageView.image = image
                    }
                }
            }
            
        default:
            iconImageView.image = UIImage(named: "file")
            break
        }
    }
}
