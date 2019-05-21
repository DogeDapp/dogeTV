//
//  AppTheme.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/28.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation
import SwiftTheme
import PKHUD


enum AppColor {
    static let slideSwitcherColor: ThemeColorPicker = ["#FFF", "#101C26"]
    static let backgroundColor: ThemeColorPicker = ["#FFF", "#18222D"]
    static let secondaryBackgroundColor: ThemeColorPicker = ["#FFF", "#131C25"]
    
    static let textColor: ThemeColorPicker = ["#01040D", "#EEE"]
    static let secondaryTextColor: ThemeColorPicker = ["#656765", "#CCC"]
    
    static let indicatorColor: ThemeColorPicker = ["#17222D", "#CCC"]
    
    static let barTextColors = ["#000","#FFF"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    
    static let separatorColor:ThemeColorPicker = ["#EEE","#0E1720"]
    static let borderColor:ThemeCGColorPicker = ["#656765","#CCC"]
    static let tintColor: ThemeColorPicker = ["#17222D", "#EEE"]
    static let barTintColor: ThemeColorPicker = ["#FFF", "#101C26"]

    static let channelBackgroundColor: ThemeColorPicker = ["#2F3236", "#16263A"]

    static let statusBarStyle: ThemeStatusBarStylePicker = [.default, .lightContent]
    static let keyboardAppearance: ThemeKeyboardAppearancePicker =  [.default, .dark]
}



enum AppTheme: Int {
    
    case light
    case dark
    
    static let key = "APP_THEME"
    static var current: AppTheme { return AppTheme(rawValue: ThemeManager.currentThemeIndex)! }
    static var before = AppTheme.light
    
    
    static func switchTo(_ theme: AppTheme) {
        before = current
        ThemeManager.setTheme(index: theme.rawValue)
        PKHUD.sharedHUD.effect = UIBlurEffect(style: current == .dark ? .dark : .light)
        save()
    }
    
    static func toggle() {
        switchTo(isDark ? .light : .dark)
    }
    
    static var isDark: Bool {
        return current == .dark
    }
    
    static func save() {
        UserDefaults.standard.set(ThemeManager.currentThemeIndex, forKey: AppTheme.key)
    }
    
    static func restore() {
        guard let theme = AppTheme(rawValue: UserDefaults.standard.integer(forKey: AppTheme.key)) else {
            return
        }
        switchTo(theme)
    }
}


