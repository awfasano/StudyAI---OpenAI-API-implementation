import Purchases
import Foundation
import StoreKit

final class IAPManager {

    static let shared = IAPManager()
    private init() {}

    func isPremium() -> Bool {
        return KeychainHelper.shared.getBool(forKey: "premium")
    }

    public func getSubscriptionStatus(completion: ((Bool) -> Void)?) {
        Purchases.shared.purchaserInfo { info, error in
            guard let entitlements = info?.entitlements, error == nil else {
                return
            }
            if entitlements.all["Premium"]?.isActive == true {
                KeychainHelper.shared.save(true, forKey: "premium")
                completion?(true)
            } else {
                KeychainHelper.shared.save(false, forKey: "premium")
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
            guard let transaction = transaction,
                  let _ = info?.entitlements,
                  error == nil,
                  userCancelled == false else {
                return
            }

            switch transaction.transactionState {
            case .purchased:
                completion(true)
            case .purchasing, .failed, .restored, .deferred:
                break
            @unknown default:
                break
            }
        }
    }

    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restoreTransactions { info, error in
            guard let entitlements = info?.entitlements, error == nil else {
                return
            }

            if entitlements.all["Premium"]?.isActive == true {
                KeychainHelper.shared.save(true, forKey: "premium")
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
