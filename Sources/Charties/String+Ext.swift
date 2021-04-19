//
//  String+Ext.swift
//  
//
//  Created by Pablo Cornejo on 4/18/21.
//

import UIKit

extension String {
   func size(withFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return size(withAttributes: fontAttributes)
    }
}
