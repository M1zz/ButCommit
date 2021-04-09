//
//  NetworkManager.swift
//  ButCommit
//
//  Created by 이현호 on 2021/03/27.
//

import Foundation
import NotificationCenter

protocol MyURLSessionDataDelegate: class {
    func myUrlSession(_ session: URLSession, didReceive data: Data)
    
    func myUrlSession(_ session: URLSession, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    
    func myUrlSession(_ session: URLSession, didCompleteWithError error: Error?)
}

class MyNetworkManager {
    weak var delegate: MyURLSessionDataDelegate!
    private var isSuccuess: Bool = false
    
//    init(delegate: MyURLSessionDataDelegate) {
//        self.delegate = delegate
//    }
    
    func dataTask(with url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            //print("completed data : \(String(data: data!, encoding: .utf8))")
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode),
                  let mimeType = response.mimeType,
                  mimeType == "text/html" else {
                NotificationCenter.default.post(name: Notification.Name("Receive"),
                                                object: nil,
                                                userInfo: ["reseponseResult":self.isSuccuess])
                return
            }
            
            self.isSuccuess = true
            NotificationCenter.default.post(name: Notification.Name("Receive"), object: data, userInfo: ["reseponseResult":self.isSuccuess])
            
            
            
            
            
//            while(myData.count > chunkSize) {
//                let startIndex = myData.index(myData.startIndex, offsetBy: 0)
//                let lastIndex = myData.index(myData.startIndex, offsetBy: 4096)
//                let endIndex = myData.index(myData.endIndex, offsetBy: 0)
//                let sendData = myData[startIndex...lastIndex]
//                //let sendData = myData[0...lastIndex]
//                //self.delegate.myUrlSession(session, didReceive: sendData)
//                NotificationCenter.default.post(name: Notification.Name("ReceiveData"), object: nil, userInfo: nil)
//                var temp = myData.subdata(in: lastIndex-1 ..< endIndex)
//                //myData = myData[4096..<myData.endIndex]
//
//                if myData.count < 4096 {
//                    NotificationCenter.default.post(name: Notification.Name("ReceiveData"), object: nil, userInfo: nil)
//                    //self.delegate.myUrlSession(session, didReceive: myData)
//                }
//
//                print(myData.startIndex, myData.endIndex)
//            }
            
            
//            self.delegate.myUrlSession(session, didReceive: response!) { (reseponseDiposition) in
//                
//                switch reseponseDiposition {
//                case .allow:
//                print("allow")
//                    self.delegate.myUrlSession(session, didCompleteWithError: error)
//                case .becomeDownload:
//                print("becomeDownload")
//                case .becomeStream:
//                print("becomeStream")
//                case .cancel:
//                print("cancel")
//                }
//            }
        }.resume()
        
//        delegate.myUrlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, didCompleteWithError: <#T##Error?#>)
//        delegate.myUrlSession(<#T##session: URLSession##URLSession#>, dataTask: <#T##URLSessionDataTask#>, didReceive: <#T##URLResponse#>, completionHandler: <#T##(URLSession.ResponseDisposition) -> Void#>)
    }
}
