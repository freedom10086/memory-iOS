//
// Created by yang on 2018/5/29.
// Copyright (c) 2018 tencent. All rights reserved.
//

import Foundation

public struct UploadResult: Codable {
    var url: String
    var etag: String
    var data: Data?
    var state: UploadState = .uploading(progress: 0)
    
    public init(url: String, etag: String, data: Data? = nil) {
        self.url = url
        self.etag = etag
        self.data = data
    }
    
    private enum CodingKeys: String, CodingKey {
        case url
        case etag
    }
}
