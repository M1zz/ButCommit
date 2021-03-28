//
//  NetworkManager.swift
//  ButCommit
//
//  Created by 이현호 on 2021/03/27.
//

import Foundation


//class NetworkManager {
//    static let shared = NetworkManager()
//    private var myContributes: [ContributeData] = []
//    private var mystreaks: ContributeData = ContributeData(count: 0, weekend: "", date: "")
//    
//    private init() {}
//    
//    func getContributionsByUserame(by username: String) {
//        guard let targetURL = URL(string: "https://github.com/users/\(username)/contributions") else { return }
//        
//        URLSession.shared.dataTask(with: targetURL) { [weak self] data, response, error in
//            guard let self = self else { return }
//
//            if error != nil {
//                //self.showError()
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
//                //self.showError()
//                return
//            }
//
//            guard let mimeType = httpResponse.mimeType,
//                  mimeType == "text/html",
//                  let data = data,
//                  let html = String(data: data, encoding: .utf8)
//            else {
//                //self.showError()
//                return
//            }
//            //print("data : \(html)")
//            
//            let contributeDataList = self.parseHtmltoData(html: html)
//            self.myContributes = contributeDataList
//            self.mystreaks = self.parseHtmltoDataForCount(html: html)
////            if isFriend {
////                self.friendContributes = contributeDataList
////            } else{
////                self.myContributes = contributeDataList
////                self.mystreaks = self.parseHtmltoDataForCount(html: html)
////            }
////https://github.com/scinfu/SwiftSoup.git
////            if group != nil {
////                group?.leave()
////            }
//            
//        }
//        .resume()
//    }
//    
//    private func parseHtmltoDataForCount(html: String) -> ContributeData {
//        do {
//            let doc: Document = try SwiftSoup.parse(html)
//            let rects: Elements = try doc.getElementsByTag(ParseKeys.rect)
//            let days: [Element] = rects.array().filter { $0.hasAttr(ParseKeys.date) }
//            let count = days.suffix(Consts.fetchStreak)
//            var contributeLastDate = count.map(mapFunction)
//            
//            contributeLastDate.sort{ $0.date > $1.date }
//            for index in 0 ..< contributeLastDate.count {
//                if contributeLastDate[index].count == .zero {
//                    return contributeLastDate[index]
//                }
//                if index == (contributeLastDate.count - 1) {
//                    return ContributeData(
//                        count: 1000,
//                        weekend: contributeLastDate[index].weekend,
//                        date: contributeLastDate[index].date
//                    )
//                }
//            }
//            return ContributeData(count: 0, weekend: "", date: "")
//        } catch {
//            return ContributeData(count: 0, weekend: "", date: "")
//        }
//    }
//    
//    private func parseHtmltoData(html: String) -> [ContributeData] {
//        do {
//            let doc: Document = try SwiftSoup.parse(html)
//            let rects: Elements = try doc.getElementsByTag(ParseKeys.rect)
//            let days: [Element] = rects.array().filter { $0.hasAttr(ParseKeys.date) }
//            let weekend = days.suffix(Consts.fetchCount)
//            let contributeDataList = weekend.map(mapFunction)
//            return contributeDataList
//            
//        } catch {
//            return []
//        }
//    }
//    
//    private func mapFunction(ele : Element) -> ContributeData {
//        guard let attr = ele.getAttributes() else { return ContributeData(count: 0, weekend: "", date: "") }
//        let date: String = attr.get(key: ParseKeys.date)
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        dateFormatter.locale = Locale.current
//        dateFormatter.timeZone = TimeZone.current
//
//        let dateForWeekend = dateFormatter.date(from: date)
//        
//        guard let weekend = dateForWeekend?.dayOfWeek() else { return ContributeData(count: 0, weekend: "", date: "")}
//        guard let count = Int(attr.get(key: ParseKeys.contributionCount)) else { return ContributeData(count: 0, weekend: "", date: "")}
//
//        return ContributeData(count: count, weekend: weekend, date: date)
//    }
//}
