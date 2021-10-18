//
//  File.swift
//  
//
//  Created by 陳世爵 on 2021/10/18.
//

import UIKit

class TextField: UITextField {
    
    var contentInset: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: contentInset, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: contentInset, dy: 0)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        super.rightViewRect(forBounds: bounds)
            .offsetBy(dx: -contentInset, dy: 0)
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }
    
}
