//
//  ViewController.swift
//  LLNetworkAccessibility-Swift
//
//  Created by lanlinxl on 12/07/2022.
//  Copyright (c) 2022 lanlinxl. All rights reserved.
//

import UIKit
import LLNetworkAccessibility_Swift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.textColor = .blue
        label.font = .systemFont(ofSize: 18, weight: .medium)
        view.addSubview(label)
        label.frame = CGRect(x: 150, y: 120, width: 100, height: 30)
        
        let button = UIButton(type: .custom)
        button.setTitle("设置页按钮", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        view.addSubview(button)
        button.frame = CGRect(x: 150, y: label.frame.maxY + 30, width: 100, height: 30)

        
        LLNetworkAccessibility.start()
        LLNetworkAccessibility.configAlertStyle(type: .custom,closeEnable: false,tintColor: .red)
        LLNetworkAccessibility.reachabilityUpdateCallBack = { state in
            guard let state = state else { return }
            switch state {
            case .available:
                label.text = "网络已授权"
            case .restricted:
                label.text = "网络没授权"
            case .unknown:
                label.text = "没有网络（飞行模式）"
            default:
                break
            }
      
        }
    }

    @objc func buttonClick(){
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
        
    }

}

