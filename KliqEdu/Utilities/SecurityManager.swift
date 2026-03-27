//
//  SecurityManager.swift
//  herald-exchange
//
//  Created by codegama on 18/02/26.
//

import Foundation
import UIKit
import Darwin

final class SecurityManager {

    static let shared = SecurityManager()

    private init() {}

    // MARK: - Public Check
    func isDeviceCompromised() -> Bool {
        return isJailbroken() || isDebuggerAttached()
    }

    // MARK: - Jailbreak Check
    private func isJailbroken() -> Bool {

        #if targetEnvironment(simulator)
        return false
        #else

        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]

        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        return false
        #endif
    }

    // MARK: - Debugger Check
    private func isDebuggerAttached() -> Bool {
        
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        
        var name = [Int32(CTL_KERN),
                    Int32(KERN_PROC),
                    Int32(KERN_PROC_PID),
                    Int32(getpid())]
        
        let result = sysctl(&name, u_int(name.count), &info, &size, nil, 0)
        
        if result == 0 {
            return (info.kp_proc.p_flag & P_TRACED) != 0
        }
        
        return false
    }
}
