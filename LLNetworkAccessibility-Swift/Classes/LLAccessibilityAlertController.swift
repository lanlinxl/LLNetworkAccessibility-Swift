//
//  LLAccessibilityAlertController.swift
//  test
//
//  Created by lzwk_lanlin on 2022/12/2.
//  Copyright © 2022 Weike. All rights reserved.
//

import Foundation
import UIKit

class LLAccessibilityAlertController: UIViewController {
    /// 弹框背景view
    private lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.layer.cornerRadius = 12
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = .white
        return bgView
    }()
    
    /// 关闭
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return button
    }()

    /// 主标题
    private lazy var titleLb: UILabel = {
        let titleLb = UILabel()
        titleLb.font = .systemFont(ofSize: 16, weight: .medium)
        titleLb.textColor = UIColor(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 1.0)
        titleLb.textAlignment = .center
        titleLb.text = "开启网络权限"
        return titleLb
    }()

    /// 副标题
    private lazy var desLabel1: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 150 / 255.0, green: 154 / 255.0, blue: 173 / 255.0, alpha: 1.0)
        label.text = "1.跳转到设置页后，点击 无线数据"
        return label
    }()
    
    private lazy var desImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = imageNamed(name: "LLAccessibilityImage1")
        return imageView
    }()
    
    private lazy var desLabel2: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 150 / 255.0, green: 154 / 255.0, blue: 173 / 255.0, alpha: 1.0)
        label.text = "2.选中 WLAN 与蜂窝网络"
        return label
    }()
    
    private lazy var desImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = imageNamed(name: "LLAccessibilityImage2")
        return imageView
    }()
    
    lazy var setButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("立即设置", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitleColor(UIColor(red: 242 / 255.0, green: 246 / 255.0, blue: 252 / 255.0, alpha: 1.0), for: .highlighted)
        button.addTarget(self, action: #selector(setButtonClick), for: .touchUpInside)
        return button
    }()
    
    /// 弹框是否可关闭
    var closeAlertEnable: Bool = false
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        setupBaseView()
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    func setupBaseView() {
        view.addSubview(closeButton)
        closeButton.frame = view.bounds

        view.addSubview(bgView)
        bgView.addSubview(titleLb)
        bgView.addSubview(desLabel1)
        bgView.addSubview(desImageView1)
        bgView.addSubview(desLabel2)
        bgView.addSubview(desImageView2)
        bgView.addSubview(setButton)
        bgView.frame = CGRect(x: UIScreen.main.bounds.size.width / 2 - 130, y: UIScreen.main.bounds.size.height / 2 - 110, width: 260, height: 220)
        titleLb.frame = CGRect(x: 0, y: 16, width: 260, height: 20)
        desLabel1.frame = CGRect(x: 20, y: 50, width: 240, height: 12)
        desImageView1.frame = CGRect(x: 20, y: desLabel1.frame.maxY + 4, width: 220, height: 32)
        desLabel2.frame = CGRect(x: 20, y: desImageView1.frame.maxY + 8, width: 220, height: 12)
        desImageView2.frame = CGRect(x: 20, y: desLabel2.frame.maxY + 4, width: 220, height: 32)
        let line = UIView()
        line.backgroundColor = UIColor(red: 242 / 255.0, green: 246 / 255.0, blue: 252 / 255.0, alpha: 1.0)
        bgView.addSubview(line)
        line.frame = CGRect(x: 0, y: desImageView2.frame.maxY + 16, width: 260, height: 0.5)
        setButton.frame = CGRect(x: 0, y: line.frame.maxY , width: 260, height: 44)
    }
    
    @objc func setButtonClick(){
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }else {
            self.dismiss(animated: true)
        }
    }
    
    @objc func closeAction() {
        if closeAlertEnable{
            view.removeFromSuperview()
        }
    }
}


extension LLAccessibilityAlertController {
    func imageNamed(name: String) -> UIImage? {
        let currentBundle = Bundle(for: LLAccessibilityAlertController.self)
        if let bundlePath = currentBundle.path(forResource: "LLNetworkAccessibility", ofType: "bundle") {
            let image = UIImage(contentsOfFile: bundlePath + "/\(name).png")
            return image
        }
        return nil
    }
}
