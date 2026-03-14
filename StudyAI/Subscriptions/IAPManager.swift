import RevenueCat
import Foundation
import StoreKit

final class IAPManager {

    enum PremiumPackageKind {
        case monthly
        case annual
    }

    static let shared = IAPManager()
    private init() {}

    func isPremium() -> Bool {
        return KeychainHelper.shared.getBool(forKey: "premium")
    }

    public func getSubscriptionStatus(completion: ((Bool) -> Void)?) {
        Purchases.shared.getCustomerInfo { info, error in
            guard let entitlements = info?.entitlements, error == nil else {
                completion?(false)
                return
            }
            if Self.hasActivePremium(in: entitlements) {
                KeychainHelper.shared.save(true, forKey: "premium")
                completion?(true)
            } else {
                KeychainHelper.shared.save(false, forKey: "premium")
                completion?(false)
            }
        }
    }

    public func fetchPremiumPackages(completion: @escaping (Package?, Package?) -> Void) {
        Purchases.shared.getOfferings { offerings, error in
            guard error == nil else {
                completion(nil, nil)
                return
            }
            let current = offerings?.current ?? offerings?.offering(identifier: "default")
            let packages = current?.availablePackages ?? []

            let monthly = packages.first {
                $0.identifier == "$rc_monthly"
                || $0.packageType == .monthly
                || $0.storeProduct.productIdentifier == "com.waitedco.StudyAI.premium_monthly"
            }
            let annual = packages.first {
                $0.identifier == "$rc_annual"
                || $0.packageType == .annual
                || $0.storeProduct.productIdentifier == "com.waitedco.StudyAI.premium_annual"
            }
            completion(monthly, annual)
        }
    }

    func buyPremium(package: Package, completion: @escaping (Bool) -> Void) {
        Purchases.shared.purchase(package: package) { transaction, info, error, userCancelled in
            guard let transaction = transaction,
                  let entitlements = info?.entitlements,
                  error == nil,
                  userCancelled == false else {
                completion(false)
                return
            }
            _ = transaction
            let isActive = Self.hasActivePremium(in: entitlements)
            KeychainHelper.shared.save(isActive, forKey: "premium")
            completion(isActive)
        }
    }

    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { info, error in
            guard let entitlements = info?.entitlements, error == nil else {
                completion(false)
                return
            }

            if Self.hasActivePremium(in: entitlements) {
                KeychainHelper.shared.save(true, forKey: "premium")
                completion(true)
            } else {
                KeychainHelper.shared.save(false, forKey: "premium")
                completion(false)
            }
        }
    }

    private static func hasActivePremium(in entitlements: EntitlementInfos) -> Bool {
        ["premium", "Premium", "pro", "Pro"].contains { entitlements[$0]?.isActive == true }
    }
}
