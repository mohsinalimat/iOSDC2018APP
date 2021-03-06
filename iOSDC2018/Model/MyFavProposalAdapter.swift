//
//  MyFavProposal.swift
//  iOSDC2018
//
//  Created by 朱　冰一 on 2018/08/15.
//  Copyright © 2018年 zhubingyi. All rights reserved.
//

import Foundation

struct FavProposal {
    var date: Date
    var proposals: [Proposal]
    
    @discardableResult
    mutating func insertProposal(_ proposal: Proposal) -> Bool {
        for p in proposals {
            if p.overlay(proposal: proposal) {
                return false
            }
        }
        proposals.append(proposal)
        // amount is small so, just sort the array
        proposals = proposals.sorted { (l, r) -> Bool in
            return l.timetable.startsAt < r.timetable.startsAt
        }
        return true
    }
}

fileprivate let MyFavProposalKey = "MY_FAV_PROPOSAL"

final class MyFavProposalManager {
    static let shared = MyFavProposalManager()
    var proposals: [Proposal] = []
    private(set) var favIds: [String] = []
    
    var favProposals: [Proposal] {
        get {
            return proposals.filter{ favIds.contains($0.id) }
        }
    }
    
    init() {
        favIds = getFavId()
    }
    
    func add(id: String) {
        guard favIds.contains(id) == false else { return }
        favIds.append(id)
        updateFavId(ids: favIds)
    }
    
    func remove(id: String) {
        favIds = favIds.filter{ return $0 != id }
        updateFavId(ids: favIds)
    }
    
    func contains(id: String) -> Bool {
        return favIds.contains(id)
    }
    
    private func updateFavId(ids: [String]) {
        let ud = UserDefaults.standard
        ud.set(favIds, forKey: MyFavProposalKey)
    }
    

    private func getFavId() -> [String] {
        let ud = UserDefaults.standard
        if let favIds = ud.value(forKey: MyFavProposalKey) as? [String] {
            return favIds
        } else {
            return []
        }
    }
    
    func overlayCurrentFavProposals(_ proposal: Proposal) -> [Proposal] {
        var overlapProposals = [Proposal]()
        for p in favProposals {
            if p.overlay(proposal: proposal) {
                overlapProposals.append(p)
            }
        }
        return overlapProposals
    }
}


final class MyFavProposalAdapter {
    private(set) var favProposalList: [FavProposal] = []
    private(set) var proposals: [Proposal]
    init(allProposals: [Proposal]) {
        self.proposals = allProposals
        updateFavProposals()
    }
    
    func updateFavProposals() {
        var day1 = FavProposal(date: Date.createBy(year: 2018, month: 8, day: 30), proposals: [])
        var day2 = FavProposal(date: Date.createBy(year: 2018, month: 8, day: 31), proposals: [])
        var day3 = FavProposal(date: Date.createBy(year: 2018, month: 9, day: 1), proposals: [])
        var day4 = FavProposal(date: Date.createBy(year: 2018, month: 9, day: 2), proposals: [])

        let favProposals = proposals.filter{ return MyFavProposalManager.shared.contains(id: $0.id) }
        favProposals.forEach {
            switch $0.timetable.startsAt {
            case day1.date.timeIntervalSince1970 ..< day1.date.timeIntervalSince1970 + 3600 * 24:
                day1.insertProposal($0)
            case day2.date.timeIntervalSince1970 ..< day2.date.timeIntervalSince1970 + 3600 * 24:
                day2.insertProposal($0)
            case day3.date.timeIntervalSince1970 ..< day3.date.timeIntervalSince1970 + 3600 * 24:
                day3.insertProposal($0)
            case day4.date.timeIntervalSince1970 ..< day4.date.timeIntervalSince1970 + 3600 * 24:
                day4.insertProposal($0)
            default:
                break
            }
        }
        favProposalList = [day1, day2, day3, day4]
    }
}

