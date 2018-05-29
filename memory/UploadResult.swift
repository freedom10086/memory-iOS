//
// Created by yang on 2018/5/29.
// Copyright (c) 2018 tencent. All rights reserved.
//

import Foundation


public struct UploadResult: Codable {
    var url: String
    var etag: String
    var data: Data?
}
