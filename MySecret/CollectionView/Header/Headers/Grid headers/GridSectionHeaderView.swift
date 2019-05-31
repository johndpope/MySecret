//
//  GridSectionHeaderView.swift
//  MySecret
//
//  Created by Amir lahav on 21/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit


protocol GridSectionHeaderViewProtocol:class {
    func didSelectHeader(at indexPath:IndexPath?)
}


class GridSectionHeaderView: CollectionViewHeader, ConfigurableCell, SelectableHeaderReuseableView {
    @IBOutlet weak var headerBarBackground: UIView?
    {
        didSet{
            
        }
    }
    
    func load() {
        print("should load header")
    }
    
     @IBOutlet weak var blurView: UIVisualEffectView?{
        didSet{
            
        }
    }
    
    
    func update(_ indexPath: IndexPath?) {
        currentIndexPath = indexPath
    }
    
    
    
    var currentIndexPath:IndexPath? = nil
    
    @IBOutlet weak var selectBtn: UIButton?{
        didSet{
            selectBtn?.setTitle("Select", for: .normal)
            selectBtn?.contentHorizontalAlignment = .right
            selectBtn?.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)

        }
    }
    
    @IBAction func selectBtnAction(_ sender: UIButton) {
        isSelected = !isSelected
        delegate?.didSelectHeader(at: currentIndexPath)
        print("touch me")
    }
    
    @IBOutlet weak var title: UILabel?
    {
        didSet{
            guard let title = title else {
                return
            }
            /// config label

        }
    }
    
    
    var isSelected:Bool = false {
        didSet{
            let title = isSelected ? "Deselect" : "Select"
            selectBtn?.setTitle(title, for: .normal)
        }
    }
    
    func select(_ isSelected:Bool)
    {
        self.isSelected = isSelected
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        blurView?.isHidden = true
        headerBarBackground?.isHidden = false
    }
    
    func bind(data:MSHeaderViewableProtocol, completion:(Bool)->())
    {
        title?.text = data.title
        isSelected = data.isSelected
        selectBtn?.isHidden = data.selectButtonIsHidden
        currentIndexPath = data.currentIndexPath
    }
    
    override func prepareForReuse() {
        currentIndexPath = nil
        blurView?.isHidden = true
        headerBarBackground?.isHidden = false
    }
    
    func pinned(_ pinned:Bool)
    {
        headerBarBackground?.isHidden = pinned
        blurView?.isHidden = !pinned
    }
    
}
