//
//  UIViewController+Extension.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 15/12/22.
//

import UIKit

extension UIViewController {
    func hideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
}
