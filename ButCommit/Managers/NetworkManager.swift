//
//  NetworkManager.swift
//  ButCommit
//
//  Created by 이현호 on 2021/03/27.
//

import Foundation

protocol MyURLSessionDataDelegate: class {
    func myUrlSession(_ session: URLSession, didReceive data: Data)
    
    func myUrlSession(_ session: URLSession, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    
    func myUrlSession(_ session: URLSession, didCompleteWithError error: Error?)
}

class MyNetworkManager {
    weak var delegate: MyURLSessionDataDelegate!
    
    init(delegate: MyURLSessionDataDelegate) {
        self.delegate = delegate
    }
    
    func dataTask(with url: URL, session: URLSession) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            //print("completed data : \(String(data: data!, encoding: .utf8))")
            guard let data = data else { return }
            var myData = data
            let dataLength = myData.count
            let chunkSize = ((1024 * 1) * 4)
            let fullChunks = Int(dataLength / chunkSize)
            let totalChunks = fullChunks + (dataLength % 1024 != 0 ? 1 : 0)
            
            var chunks:[Data] = [Data]()
//            for chunkCounter in 0..<totalChunks {
//                var chunk:Data
//                let chunkBase = chunkCounter * chunkSize
//                var diff = chunkSize
//                if(chunkCounter == totalChunks - 1) {
//                    diff = dataLength - chunkBase
//                }
//
//                let range:Range<Data.Index> = Range(chunkBase..<(chunkBase + diff))
//                chunk = data.subdata(in: range)
//                print("The size if \(chunk.count)")
//            }
            print(myData.count, myData.count/4096)
            
            while(myData.count > chunkSize) {
                let startIndex = myData.index(myData.startIndex, offsetBy: 0)
                let lastIndex = myData.index(myData.startIndex, offsetBy: 4096)
                let endIndex = myData.index(myData.endIndex, offsetBy: 0)
                let sendData = myData[startIndex...lastIndex]
                //let sendData = myData[0...lastIndex]
                self.delegate.myUrlSession(session, didReceive: sendData)
                var temp = myData.subdata(in: lastIndex-1 ..< endIndex)
                //myData = myData[4096..<myData.endIndex]
                
                if myData.count < 4096 {
                    self.delegate.myUrlSession(session, didReceive: myData)
                }

                print(myData.startIndex, myData.endIndex)
            }
            
            
            self.delegate.myUrlSession(session, didReceive: response!) { (reseponseDiposition) in
                
                switch reseponseDiposition {
                case .allow:
                print("allow")
                    self.delegate.myUrlSession(session, didCompleteWithError: error)
                case .becomeDownload:
                print("becomeDownload")
                case .becomeStream:
                print("becomeStream")
                case .cancel:
                print("cancel")
                }
            }
        }.resume()
        
//        delegate.myUrlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, didCompleteWithError: <#T##Error?#>)
//        delegate.myUrlSession(<#T##session: URLSession##URLSession#>, dataTask: <#T##URLSessionDataTask#>, didReceive: <#T##URLResponse#>, completionHandler: <#T##(URLSession.ResponseDisposition) -> Void#>)
    }
}
