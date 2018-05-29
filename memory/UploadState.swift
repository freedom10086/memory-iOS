//
//  UploadState.swift
//  memory
//
//  Created by yang on 2018/5/29.
//  Copyright © 2018年 tencent. All rights reserved.
//

import Foundation

public enum UploadState {
    case uploading(progress: Int)
    case success
    case failed
}
