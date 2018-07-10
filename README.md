# 印迹-iOS

[![Build Status](https://travis-ci.org/freedom10086/memory-iOS.svg?branch=master)](https://travis-ci.org/freedom10086/memory-iOS)

——“记录你的印迹”

Github : [印迹-iOS](https://github.com/freedom10086/memory-iOS/tree/master)

一款共享类型的相册产品，包括“印迹”、“最新”、“我的”三个Scene

* 使用StoryBoard+AutoLayout进行UI搭建；

* Swift进行业务逻辑描述。

## 项目设计要点

### 一、网络异步通信：

1. URLSession发起GET、POST请求；
2. 开源库Alamofire进行图片上传；
3. 异步发起网络请求，主线程刷新UI显示。


``` swift
//网络请求封装
class HttpUtil {
    
    public static var enableStatusProgress = true
    
    private static var workingSize = 0 {
        didSet {
            if (workingSize == 0 || workingSize == 1) && enableStatusProgress {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = workingSize > 0
                }
            }
        }
    }

    public static func REQUEST<T>(_ type: T.Type, url: String,
                                  method:String = "GET", params: [String: Any]?,
                                  callback: @escaping (T? , String) -> Void) where T : Codable {
        
        var url = getUrl(url: url)
        
        var ps  = params
        if let token = Settings.token {
            if ps != nil {
                ps!["token"] = token
            } else {
                ps = ["token": token]
            }
        }
        
        let p = encodeParameters(ps)
        if let q = p, (method == "GET" || method == "DELETE" || method == "PUT") {
            if url.contains("?") {
                url = url + "&" + q
            } else {
                url = url + "?" + q
            }
        }
        
        let u: URL?
        if method == "GET" {
            u = URL(string: url)
        } else {
            u = URLComponents(string: url)?.url
        }
        
        if u == nil {
            callback(nil, "请求链接不合法:\(url)")
            return
        }
        
        var request = URLRequest(url: u!)
        request.httpMethod = method
        request.timeoutInterval = 8
        
        if let q = p, method != "GET" {
            request.httpBody = q.data(using: .utf8)
        }
        
        print("start http \(method) url:\(url)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            HttpUtil.workingSize -= 1
            handleResponse(type, data: data, response: response, error: error, callback: callback)
        }
        
        HttpUtil.workingSize += 1
        task.resume()
    }
}

```

```swift
//异步发起网络请求
DispatchQueue.global(qos: .userInitiated).async {
            let pickedImageData = ((info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage)?
                .scaleToSizeAndWidth(width: 2160, maxSize: 3072) //3072 3M
            
            DispatchQueue.main.async {
                if let imageData = pickedImageData {
                    //print("will upload image size \((imageData as NSData).length)")
                    self.images[self.images.count - 1].data = imageData
                    
                    self.imagesCollectionView.reloadItems(at: [indexPath])
                    self.upload(position: indexPath.row, imageData: imageData)
                } else {
                    let alert = UIAlertController(title: "无法解析的图片,请换一张试试", message: "请选择适合的图片", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
  }
        
```

### 二、图片压缩：
本地图片压缩+服务器图片压缩：

1. 本地图片压缩控制上传图片尺寸：限制图片width和maxSize；
2. 服务器进行再次压缩，客户端可选择请求缩略图或原图。

```swift

   extension UIImage {
    func scaleToWidth(width: CGFloat) -> UIImage {
        if self.size.width <= width {
            return self
        }
        
        let alpha = false
        let height = self.size.height / (self.size.width / width)
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, alpha, 0.0)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.draw(in: rect)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //调整大小
    func scaleToSizeAndWidth(width: CGFloat, maxSize: Int) -> Data? {
        let image = self.scaleToWidth(width: width) //原始缩放过后的image
        print("after scale image width to \(width) size is \(image.size)")
        guard var imageData = UIImageJPEGRepresentation(image, 1.0) else {
            return nil
        }
        
        var sizeKb = (imageData as NSData).length / 1024

        var resizeRate: CGFloat = 0.9
        if (sizeKb / maxSize) > 2 {
            resizeRate = 0.8
        }
        
        while sizeKb > maxSize && resizeRate > 0.1 {
            print("bigger than maxsize scale image resize \(resizeRate)")
            imageData = UIImageJPEGRepresentation(image, resizeRate)!
            sizeKb = (imageData as NSData).length / 1024
            print("after scale size is \(sizeKb)")
            resizeRate -= 0.1
        }
        
        return imageData
    }
}

```

### 三、图片缓存：
使用Kingfisher开源库，三级缓存思想，匿名共享内存使用


### 四、鉴权方式：
1. 使用QQ的SDK，从QQ服务器登录并获取openid,access_token,expires三个参数穿过服务器；
2. 使用token进行安全的身份鉴定。

