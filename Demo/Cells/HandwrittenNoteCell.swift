//
//  HandwrittenNoteCell.swift
//  TableViewKitDemo
//
//  Created by Alek Åström on 2017-12-10.
//  Copyright © 2017 Alek Åström. All rights reserved.
//

import UIKit
import TableViewKit

class HandwrittenNoteCell: UITableViewCell, ReusableViewNib, DataSetupable {
   
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var bottomLabel: UILabel!
    
    struct Model: Hashable, AnyEquatable {
        var title: String
        var subtitle: String?
        
        var hashValue: Int {
            return title.hashValue ^ (subtitle?.hashValue ?? 0)
        }
    }
    
    func setup(_ model: HandwrittenNoteCell.Model) {
        topLabel.text = model.title
        bottomLabel.text = model.subtitle
        bottomLabel.isHidden = (model.subtitle == nil)
    }
    
    static func estimatedHeight(forWidth width: CGFloat, model: Model) -> CGFloat? {
        return 100 // TODO: Add better estimation
    }
}

func ==(lhs: HandwrittenNoteCell.Model, rhs: HandwrittenNoteCell.Model) -> Bool {
    return lhs.title == rhs.title
        && lhs.subtitle == rhs.subtitle
}
