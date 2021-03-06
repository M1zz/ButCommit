//
//  CommitSequenceViewController.swift
//  ButCommit
//
//  Created by μ΄ννΈ on 2021/03/27.
//

import UIKit
import SwiftSoup

class CommitSequenceViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var screenshotButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    let commitStatusCellIdentifier = "commitStatusCell"
    
    private var myContributes: [ContributeData] = []
    private var serialCommitCount: Int = 0
    private var mystreaks: ContributeData = ContributeData(count: 0, weekend: "", date: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        screenshotButton.layer.cornerRadius = 10
        shareButton.layer.cornerRadius = 10
    }
    
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
            title = "π’ μμ§ μλλ₯Ό μ¬μ§ λͺ»νμ΄μ."
        } else if serialCommitCount == 1 {
            title = "π± μ€λ μ²μμΌλ‘ μλλ₯Ό μ¬μμ΄μ."
        } else if serialCommitCount < 30 {
            title = "πΏ μλμ μΉμ΄ νΌ μ§ \(serialCommitCount)μΌμ΄ λμμ΄μ."
        } else if serialCommitCount < 100 {
            title = "π³ μλκ° λ¬΄λ­λ¬΄λ­ μλμ§ \(serialCommitCount)μΌμ΄ λμμ΄μ."
        }
        // π₯π±πΏπ³
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
        
        URLSession.shared.dataTask(with: targetURL) { [weak self] data, response, error in
            guard let self = self else { return }

            if error != nil {
                //self.showError()
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
                //self.showError()
                return
            }

            guard let mimeType = httpResponse.mimeType,
                  mimeType == "text/html",
                  let data = data,
                  let html = String(data: data, encoding: .utf8)
            else {
                //self.showError()
                return
            }
            self.mystreaks = self.parseHtmltoDataForCount(html: html)
            self.myContributes = self.parseHtmltoData(html: html)
            
            DispatchQueue.main.async {
//                if self.mystreaks[0].count == 0 {
//                    self.title = "π’ μμ§ μλλ₯Ό μ¬μ§ λͺ»νμ΄μ."
//                } else {
//
//                }
                self.configureTitle()
                self.tableView.reloadData()
            }
//            if isFriend {
//                self.friendContributes = contributeDataList
//            } else{
//                self.myContributes = contributeDataList
//                self.mystreaks = self.parseHtmltoDataForCount(html: html)
//            }
//
//            if group != nil {
//                group?.leave()
//            }
            
        }
        .resume()
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
