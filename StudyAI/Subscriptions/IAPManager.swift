//
//  File.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/12/23.
//
import Purchases
import Foundation
import StoreKit

final class IAPManager {
    
    static let shared = IAPManager()
    private init() {}
    
    func isPremium() -> Bool {
        return UserDefaults.standard.bool(forKey: "premium")
        
    }
    
    public func getSubscriptionStatus(completion: ((Bool) -> Void)?) {
        Purchases.shared.purchaserInfo { info, error in
            guard let entitlements = info?.entitlements, error == nil else {
                return
            }
            if entitlements.all["Premium"]?.isActive == true {
                print("Got updated status of subscribed")
                UserDefaults.standard.set(true, forKey: "premium")
                completion?(true)
            }
            else {
                print("Got updated status of NOT subscribed")
                UserDefaults.standard.set(false, forKey: "premium")
                completion?(false)
            }
        }
    }
    
    public func fetchPackages(completion: @escaping (Purchases.Package?) -> Void) {

        Purchases.shared.offerings { offerings, error in
            guard let package = offerings?.offering(identifier: "tokens")?.availablePackages.first, error == nil else {
                return
            }
            completion(package)
        }
    }
    
    func buyTokens(package: Purchases.Package, completion: @escaping (Bool) -> Void) {
                        
        Purchases.shared.purchasePackage(package) { transaction, info, error, userCancelled in
            guard let transaction = transaction, let entitlements = info?.entitlements, error == nil,
                  userCancelled == false else {
                print("did i fail here??")
                print(transaction)
                print(info?.entitlements)
                print(error)
                return
            }
                                    
            switch transaction.transactionState {
            case .purchasing:
                print("purchasing")
            case .purchased:
                print("did i enter transaction state")
                    completion(true)
            case .failed:
                print("failed")
            case .restored:
                print("restored")
            case .deferred:
                print("deferred")
            @unknown default:
                print("in default")
            }
            
        }
    }
    
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restoreTransactions { info, error in
            guard let entitlements = info?.entitlements, error == nil else {
                return
            }
            
            if entitlements.all["Premium"]?.isActive == true {
                UserDefaults.standard.set(true, forKey: "premium")
                print("Restored Success")
                completion(true)
            }
            else {
                print("Restore Failed")
                completion(false)
            }
            
            print("Restore: \(entitlements)")
        }
        
    }
}
