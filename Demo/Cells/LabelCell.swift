//
//  LabelCell.swift
//  TableViewKitDemo
//
//  Created by Alek Åström on 2017-12-10.
//  Copyright © 2017 Alek Åström. All rights reserved.
//

import UIKit
import TableViewKit

class LabelCell: UITableViewCell, ReusableViewClass, DataSetupable {
    
    struct Model: Hashable, AnyEquatable {
        let text: String
        
        var hashValue: Int {
            return text.hashValue
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ model: Model) {
        textLabel?.text = model.text
    }
    
}

func ==(lhs: LabelCell.Model, rhs: LabelCell.Model) -> Bool {
    return lhs.text == rhs.text
}
