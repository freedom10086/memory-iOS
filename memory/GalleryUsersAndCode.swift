//
//  GalleryUsersAndCode.swift
//  memory
//
//  Created by yang on 2018/5/31.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation


public struct GalleryUsersAndCode: Codable{
    public var inviteCode: String?
    public var users: [User]
}
