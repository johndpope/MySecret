//
//  MSAlbumCreateableGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 10/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

class MSAlbumCreateableGridVC: MSAlbumGridVC {
    
    
    var didFinishCreateNewAlbumWithName:(String)->() = {_ in  }

    
    @objc func createNewAlbum() {
        
        let alert = UIAlertController(title: "New Album",message:"Enter a name for this album", cancelButtonTitle: "Cancel", okButtonTitle: "Save", validate:.nonEmpty) {[weak self] (result) in
            switch result{
            case .cancel:
                self?.dismiss(animated: true, completion: nil)
            case .ok(let text):
                self?.didFinishCreateNewAlbumWithName(text)
            }
        }
        present(alert, animated: true, completion: nil)
    }

}
