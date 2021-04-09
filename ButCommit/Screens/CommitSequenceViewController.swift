//
//  CommitSequenceViewController.swift
//  ButCommit
//
//  Created by 이현호 on 2021/03/27.
//

import UIKit
import SwiftSoup
import NotificationCenter

class CommitSequenceViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var screenshotButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    let commitStatusCellIdentifier = "commitStatusCell"
//    private lazy var session: URLSession = {
//        let configuration = URLSessionConfiguration.default
//        configuration.waitsForConnectivity = true
//        return URLSession(configuration: configuration,
//                          delegate: self, delegateQueue: nil)
//    }()
    
    private var myContributes: [ContributeData] = []
    private var serialCommitCount: Int = 0
    private var mystreaks: ContributeData = ContributeData(count: 0, weekend: "", date: "")

    var receiveData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        screenshotButton.layer.cornerRadius = 10
        shareButton.layer.cornerRadius = 10
        NotificationCenter.default.addObserver(self, selector: #selector(myUrlSessionDidReceive(_:)), name: Notification.Name("Receive"), object: nil)
      
    }
    
    @objc private func myUrlSessionDidReceive(_ notification: Notification) {

        guard let userInfo = notification.userInfo as? [String: Any] else {return}
        guard let key = userInfo.keys.first else { return }

        switch key {
        case "isData" :
            if notification.userInfo?[key] as! Bool {
                let data = notification.object as! Data

                self.receiveData?.append(data)
                print("Receive data! \(data.count)")
            }
        case "reseponseResult":
            if notification.userInfo?[key] as! Bool {
                guard let data = notification.object as? Data else { return }
                let myData = data
                let dataLength = myData.count
                let chunkSize = ((1024 * 1) * 4)
                let fullChunks = Int(dataLength / chunkSize)
                let totalChunks = fullChunks + (dataLength % 1024 != 0 ? 1 : 0)

                var chunks:[Data] = [Data]()
                for chunkCounter in 0..<totalChunks {
                    var chunk:Data
                    let chunkBase = chunkCounter * chunkSize
                    var diff = chunkSize
                    if(chunkCounter == totalChunks - 1) {
                        diff = dataLength - chunkBase
                    }

                    let range:Range<Data.Index> = chunkBase..<(chunkBase + diff)
                    chunk = data.subdata(in: range)
                    print("The size if \(chunk.count)")
                    NotificationCenter.default.post(name: Notification.Name("Receive"), object: chunk, userInfo: ["isData": true])
                }
                NotificationCenter.default.post(name: Notification.Name("Receive"), object: self.receiveData, userInfo: ["result":"success"])
            }
        //print(myData.count, myData.count/4096)
        case "result":
            if notification.userInfo?[key] as? String == "success" {
                guard let data = receiveData,
                      let html = String(data: data, encoding: .utf8)
                else { return }
                print("mydata : \(String(data: data, encoding: .utf8))")
                print(data.count, receiveData?.count)
                self.mystreaks = parseHtmltoDataForCount(html: html)
                self.myContributes = parseHtmltoData(html: html)

                DispatchQueue.main.async {
                    self.configureTitle()
                    self.tableView.reloadData()
                }

            } else {
                print("error")
            }

        default:
            print("implement need")
        }

    }
    
    //    @objc private func myUrlSessionDidCompleteWithError(_ notification: Notification) {
    //        let isSuccess = notification.object as! Bool
    //        if isSuccess {
//            guard let data = receiveData,
//                  let html = String(data: data, encoding: .utf8)
//            else { return }
//            print("mydata : \(String(data: data, encoding: .utf8))")
//            print(data.count, receiveData?.count)
//            self.mystreaks = self.parseHtmltoDataForCount(html: html)
//            self.myContributes = self.parseHtmltoData(html: html)
//
//            DispatchQueue.main.async {
//                self.configureTitle()
//                self.tableView.reloadData()
//            }
//        }
//    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        showGetIDView()
    }
    
    private func showGetIDView() {
        let userId = UserDefaults.standard.value(forKey: "GithubKey")
        
        if userId != nil {
            fetchContributionsByUserame(by: userId as! String)
        } else {
            let pushVC = self.storyboard?.instantiateViewController(identifier: "GetIDViewController")
            self.navigationController?.pushViewController(pushVC!, animated: true)
        }
    }
    
    private func configureTitle() {

        if serialCommitCount == 0 {
            title = "😢 아직 잔디를 심지 못했어요."
        } else if serialCommitCount == 1 {
            title = "🌱 오늘 처음으로 잔디를 심었어요."
        } else if serialCommitCount < 30 {
            title = "🌿 잔디에 싹이 튼 지 \(serialCommitCount)일이 되었어요."
        } else if serialCommitCount < 100 {
            title = "🌳 잔디가 무럭무럭 자란지 \(serialCommitCount)일이 되었어요."
        }
        // 🔥🌱🌿🌳
    }
    
    // MARK: - Actions
    @objc func imageWasSaved(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print("Image was saved in the photo gallery")
        UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }
    
    func takeScreenshot(of view: UIView) {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: view.bounds.width, height: view.bounds.height),
            false,
            2
        )
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(screenshot, self, #selector(imageWasSaved), nil)
    }
    
    @IBAction func didTapCaptureButtonClicked(_ sender: Any) {
        takeScreenshot(of: containerView)
    }
    
    @IBAction func didTapShareButtonClicked(_ sender: Any) {
        UIGraphicsBeginImageContext(self.view.bounds.size)
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var imagesToShare = [UIImage]()
        imagesToShare.append(image!)

        let activityViewController = UIActivityViewController(activityItems: imagesToShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    func fetchContributionsByUserame(by username: String) {
        guard let targetURL = URL(string: "https://github.com/users/\(username)/contributions") else { return }
        receiveData = Data()
        let myNetworkManager = MyNetworkManager()
        myNetworkManager.dataTask(with: targetURL)
//        URLSession.shared.dataTask(with: targetURL, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)
//        let task = session.dataTask(with: targetURL)
//        task.resume()
    }
    
    private func parseHtmltoDataForCount(html: String) -> ContributeData {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let rects: Elements = try doc.getElementsByTag(ParseKeys.rect)
            let days: [Element] = rects.array().filter { $0.hasAttr(ParseKeys.date) }
            let count = days.suffix(Consts.fetchStreak)
            var contributeLastDate = count.map(mapFunction)
            
            contributeLastDate.sort{ $0.date > $1.date }
            for index in 0 ..< contributeLastDate.count {
                print(index, contributeLastDate[index].date, contributeLastDate[index].count, contributeLastDate[index].weekend)
                if contributeLastDate[index].count == .zero, index != 0 {
                    self.serialCommitCount = index
                    return contributeLastDate[index]
                }
                if index == (contributeLastDate.count - 1) {
                    return ContributeData(
                        count: 1000,
                        weekend: contributeLastDate[index].weekend,
                        date: contributeLastDate[index].date
                    )
                }
            }
            return ContributeData(count: 0, weekend: "", date: "")
        } catch {
            return ContributeData(count: 0, weekend: "", date: "")
        }
    }
    
    private func parseHtmltoData(html: String) -> [ContributeData] {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let rects: Elements = try doc.getElementsByTag(ParseKeys.rect)
            let days: [Element] = rects.array().filter { $0.hasAttr(ParseKeys.date) }

            let weekend = serialCommitCount == 0 ? days.suffix(Consts.fetchCount) : days.suffix(serialCommitCount)
            
            var contributeDataList = weekend.map(mapFunction)
            contributeDataList.sort{ $0.date > $1.date }
            return contributeDataList
            
        } catch {
            return []
        }
    }
    
    private func mapFunction(ele : Element) -> ContributeData {
        guard let attr = ele.getAttributes() else { return ContributeData(count: 0, weekend: "", date: "") }
        let date: String = attr.get(key: ParseKeys.date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current

        let dateForWeekend = dateFormatter.date(from: date)
        
        guard let weekend = dateForWeekend?.dayOfWeek() else { return ContributeData(count: 0, weekend: "", date: "")}
        guard let count = Int(attr.get(key: ParseKeys.contributionCount)) else { return ContributeData(count: 0, weekend: "", date: "")}

        return ContributeData(count: count, weekend: weekend, date: date)
    }
}

extension CommitSequenceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serialCommitCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commitStatusCellIdentifier, for: indexPath)
        let date = self.myContributes[indexPath.row].date
        let weekend = self.myContributes[indexPath.row].weekend
        let count = self.myContributes[indexPath.row].count
        let emoji = count.getEmoji()
        cell.textLabel?.text = "\(date) (\(weekend)) - \(emoji) \(count)"
        if count > 0 {
            cell.textLabel?.textColor = .systemGreen
        } else {
            cell.textLabel?.textColor = .systemRed
        }
        return cell
    }
    
}

extension CommitSequenceViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.receiveData?.append(data)
        print(data)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode),
                let mimeType = response.mimeType,
                mimeType == "text/html" else {
                completionHandler(.cancel)
                return
            }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let data = String(data: receiveData!, encoding: .utf8)
        print(data)
    }
}

//extension CommitSequenceViewController: MyURLSessionDataDelegate {
//    func myUrlSession(_ session: URLSession, didReceive data: Data) {
//        self.receiveData?.append(data)
//        print("received data : \(String(data: data, encoding: .utf8))")
//    }
//
//    func myUrlSession(_ session: URLSession, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//        guard let response = response as? HTTPURLResponse,
//              (200...299).contains(response.statusCode),
//              let mimeType = response.mimeType,
//              mimeType == "text/html" else {
//            completionHandler(.cancel)
//            return
//        }
//        completionHandler(.allow)
//    }
//
//    func myUrlSession(_ session: URLSession, didCompleteWithError error: Error?) {
//        guard let data = receiveData,
//              let html = String(data: data, encoding: .utf8)
//        else { return }
//        print("mydata : \(String(data: data, encoding: .utf8))")
//        print(data.count, receiveData?.count)
//        self.mystreaks = self.parseHtmltoDataForCount(html: html)
//        self.myContributes = self.parseHtmltoData(html: html)
//
//        DispatchQueue.main.async {
//            self.configureTitle()
//            self.tableView.reloadData()
//        }
//    }
//}
