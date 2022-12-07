//
//  ViewController.swift
//  LLNetworkAccessibilityDemo
//
//  Created by lzwk_lanlin on 2022/12/7.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.textColor = .blue
        label.font = .systemFont(ofSize: 18, weight: .medium)
        view.addSubview(label)
        label.frame = CGRect(x: 100, y: 200, width: 100, height: 30)
        
        LLNetworkAccessibility.shared.start()
        LLNetworkAccessibility.shared.configAlertInfo(type: .custom,closeEnable: false,tintColor: .red)
        LLNetworkAccessibility.shared.reachabilityUpdateCallBack = { state in
            guard let state = state else { return }
            label.text = state.rawValue
        }
    }
}

