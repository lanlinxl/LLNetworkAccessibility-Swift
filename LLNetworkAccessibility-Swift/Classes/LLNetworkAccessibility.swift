//
//  SFNetworkAccessibility.swift
//  test
//
//  Created by lzwk_lanlin on 2022/11/30.
//  Copyright © 2022 Weike. All rights reserved.
//

import Foundation
import CoreTelephony
import SystemConfiguration.CaptiveNetwork
import UIKit

private extension Notification.Name {
    static let LLNetworkStateChangedNotification = Notification.Name("LLNetworkAccessibilityChangedNotification")
}

public class LLNetworkAccessibility: NSObject {
    // 网络类型
    private enum NetworkType: String  {
        case unknown
        case offline
        case wifi
        case cellular
    }
    
    // 授权类型
    public enum AuthState: String {
        // 检测中
        case checking
        // 未知（飞行模式）
        case unknown
        // 授权可用
        case available
        // 未授权
        case restricted
    }
    
    // 弹框类型
    public enum AlertType: String  {
        /// 无弹框（默认）
        case none
        /// 自定义的弹框
        case custom
    }
    
    private static let shared = LLNetworkAccessibility()
    /// 弹框类型
    private var alertType: AlertType = .none
    /// 上次保存的状态
    private var previousState: AuthState = .checking
    private var reachabilityRef: SCNetworkReachability?
    private var cellularData: CTCellularData?
    private var reachabilityCallBack: SCNetworkReachabilityCallBack?
    /// 进入前台是否检查网络授权
    private var checkingWithBecomeActive: Bool = false
    /// 是否自动弹框
    private var isAutomaticallyAlert: Bool = false
    /// 自定义设置弹框
    private lazy var customAlertController = LLAccessibilityAlertController()
    /// 网络类型切换回调
    public static var reachabilityUpdateCallBack: ((_ state: AuthState?) -> Void)?
    
    private override init() {
        super.init()
        addReachabilityCallBack()
    }
}

//MARK: public method
extension LLNetworkAccessibility{
    /// 开启检测
    public static func start(){
        LLNetworkAccessibility.shared.setupNetworkAccessibility()
    }
    /// 停止检测
    public static func stop(){
        LLNetworkAccessibility.shared.stopAndClean()
    }
    
    /// 配置未授权的提示框
    /// - Parameters:
    ///  - type: none 不展示弹框 ， custom  展示自定义弹框
    ///  - closeEnable: 点击背景是否可关闭弹框
    ///  - tintColor: 设置按钮的文字颜色
    public static func configAlertStyle(type: AlertType , closeEnable: Bool = false , tintColor: UIColor = UIColor.red){
        LLNetworkAccessibility.shared.configAlert(type: type,closeEnable: closeEnable,tintColor: tintColor)
    }
    
    /// 当前的授权状态
    public static func getCurrentAuthState() -> AuthState{
        return  LLNetworkAccessibility.shared.previousState
    }
}


//MARK: private method
extension LLNetworkAccessibility{
    // 配置提示弹框
    private func configAlert(type: AlertType , closeEnable: Bool = false , tintColor: UIColor = UIColor.red){
        alertType = type
        switch type {
        case .custom:
            isAutomaticallyAlert = true
            customAlertController.closeAlertEnable = closeEnable
            customAlertController.setButton.setTitleColor(tintColor, for: .normal)
        case .none:
            isAutomaticallyAlert = false
        }
    }

    // 停止检测
    private func stopAndClean(){
        cellularData?.cellularDataRestrictionDidUpdateNotifier = nil
        cellularData = nil
        previousState = .checking
        reachabilityCallBack = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ensureActive), object: nil)
        hiddenAlert()
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        print("NetworkAccessibility 已清除")
    }
    
    // 设置网络授权相关
    private func setupNetworkAccessibility(){
        if (isSimulator()) {
            // 模拟器检测默认通过
            updateAccessibility(with: .available)
        }
        if reachabilityRef != nil || cellularData != nil {
            startCheck()
            return
        }
        guard let reachabilityRef = SCNetworkReachabilityCreateWithName(nil, "223.5.5.5") , let modeString = CFRunLoopMode.defaultMode?.rawValue else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.reachabilityRef = reachabilityRef
        SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(),modeString)
    
        let firstRunFlag = "LLNetworkAccessibilityFirstRunFlag"
        if UserDefaults.standard.value(forKey: firstRunFlag) as? Bool == nil {
            UserDefaults.standard.set(true, forKey: firstRunFlag)
            Delay(4) {
                self.startReachabilityNotifier()
                self.startCellularDataNotifier()
            }
        }else {
            self.startReachabilityNotifier()
            self.startCellularDataNotifier()
        }
    }
    

    
    // 监听用户从 Wi-Fi 切换到 蜂窝数据，或者从蜂窝数据切换到 Wi-Fi，另外当从授权到未授权，或者未授权到授权也会调用该方法
    private func startReachabilityNotifier(){
        guard let reachabilityRef = reachabilityRef , let modeString = CFRunLoopMode.defaultMode?.rawValue else { return }
        let selfPointer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        var context = SCNetworkReachabilityContext(version: 0, info: UnsafeMutableRawPointer(mutating: selfPointer) , retain: nil, release: nil, copyDescription: nil)
        if SCNetworkReachabilitySetCallback(reachabilityRef, reachabilityCallBack, &context){
            SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), modeString);
        }
    }
    
    private func addReachabilityCallBack(){
        // 用户从 Wi-Fi 切换到 蜂窝数据，或者从蜂窝数据切换到 Wi-Fi 的回调
        reachabilityCallBack = { _ , _ ,info  in
          if let pointer = UnsafeRawPointer(info){
              let mySelf = Unmanaged<LLNetworkAccessibility>.fromOpaque(pointer).takeUnretainedValue()
              mySelf.startCheck()
           }
        }
    }

    private func startCellularDataNotifier(){
        let cellularData = CTCellularData()
        self.cellularData = cellularData
        cellularData.cellularDataRestrictionDidUpdateNotifier = {[weak self] _ in
            DispatchQueue.main.async {
                self?.startCheck()
            }
        }
    }
    
    // 开始检测
    private func startCheck(){
        if (currentReachable()){
            print("网络可用")
            return updateAccessibility(with: .available)
        }
        guard let cellularData = cellularData else { return }
        let state = cellularData.restrictedState
        switch state {
            case .restricted:
                /*  若用户是通过蜂窝数据 或 WLAN 上网，走到这里来 说明权限被关闭**/
                if isUseWifiConnect() || isUseWWANConnect(){
                    print("网络没授权")
                    updateAccessibility(with: .restricted)
                }else {
                    print("飞行模式")
                    updateAccessibility(with: .unknown)
                }
            case .notRestricted:
                print("网络可用")
                updateAccessibility(with: .available)
            case .restrictedStateUnknown:
                Delay(0.5) {
                    self.startCheck()
                }
            default:
                break
        }
    }
    
    /* currentReachable 若返回的为 YES 则说明：
     1. 用户选择了 「WALN 与蜂窝移动网」并处于其中一种网络环境下。
     2. 用户选择了 「WALN」并处于 WALN 网络环境下。
     **/
    private func currentReachable() -> Bool{
        guard let reachabilityRef = reachabilityRef else { return false}
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachabilityRef, &flags){
            return flags.contains(.reachable)
        }
        return false
    }
    
    /// 是否在使用wifi连接
    private func isUseWifiConnect() -> Bool{
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 , let firstAddr = ifaddr else {
            return false
        }
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPV4 or IPV6 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    // Convert interface address to a human readable string
                    var addr = interface.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr,socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }
        freeifaddrs(ifaddr)
        if let wifiIP = address , wifiIP.count > 0 {
            return true
        }
        return false
    }
    
    // 是否在使用蜂窝网络连接（3G、4G、5G）
    private func isUseWWANConnect() -> Bool {
        guard let reachabilityRef = reachabilityRef else { return false}
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachabilityRef, &flags){
            print("是否是蜂窝网络：\(flags.contains(.isWWAN))")
            return flags.contains(.isWWAN)
        }
        return false
    }

   // 更新网络状态
   private func updateAccessibility(with state: AuthState){
        if (isAutomaticallyAlert){
            state == .restricted ? showAlert() : hiddenAlert()
        }
        // 状态发生变化
        if state != previousState {
            previousState = state
            LLNetworkAccessibility.reachabilityUpdateCallBack?(state)
            NotificationCenter.default.post(name: .LLNetworkStateChangedNotification, object: nil)
        }
    }
    
    /// 延时调用
    private func Delay(_ time: TimeInterval, queue: DispatchQueue = .main, closure: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + time) { closure() }
    }
    
    /// 是否是模拟器
    private func isSimulator() -> Bool{
        #if TARGET_OS_SIMULATOR
           return true
        #else
           return false
        #endif
    }
}


// MARK: - Active Check
extension LLNetworkAccessibility{
    @objc private func appWillResignActive(){
        hiddenAlert()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ensureActive), object: nil)
        checkingWithBecomeActive = true
    }
    
    @objc private func appDidBecomeActive(){
        if checkingWithBecomeActive {
            checkingWithBecomeActive = false
            perform(#selector(ensureActive), with: nil, afterDelay: 1.5,inModes: [RunLoop.Mode.common])
        }
    }
    
     @objc private func ensureActive(){
         startReachabilityNotifier()
         startCellularDataNotifier()
     }
}

// MARK: - Alert About
extension LLNetworkAccessibility{
    // 展示弹框
    func showAlert(){
        if customAlertController.view.superview == nil{
            UIApplication.shared.keyWindow?.addSubview(customAlertController.view)
            customAlertController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        }
    }
    // 隐藏弹框
    func hiddenAlert(){
        customAlertController.view.removeFromSuperview()
    }
}
