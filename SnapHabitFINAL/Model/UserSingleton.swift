//
//  UserSingleton.swift
//  SnapHabitFINAL
//
//  Created by Kent Bara on 2020/01/14.
//  Copyright © 2020 Kent Bara. All rights reserved.
//

import Foundation
class UserSingleton{
    static let sharedUserInfo = UserSingleton()
    
    var email = ""
    var username = ""
    private init(){
        
    }
}
