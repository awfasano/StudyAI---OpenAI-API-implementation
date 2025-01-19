

import Foundation
import UIKit

public class Indicator {

    public static let sharedInstance = Indicator()
    let blurEffect = UIBlurEffect(style: .dark)
    var indicator = UIActivityIndicatorView()
    var viewLoading = UIView()
    //var alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    var label = UILabel()
    var alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
    var blurEffectView = UIVisualEffectView(effect: .none)

    var indicatorImage = UIImageView()

    init()
    {
        alert.title = "Loading..."
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        //alert.title = "Loading..."
        label.font = label.font.withSize(17)
        indicatorImage.loadGif(name: "loadingCir")
        viewLoading.layer.cornerRadius = 10
        //indicator.center = alert.view.center
        //UIImageView(frame: CGRectMake(, 10, 100, 100))
        //indicatorImage.center = blurImg.center
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 250)
        alert.view.addConstraint(height)
        indicatorImage.frame =  CGRect(x: alert.view.left + 45, y: alert.view.top+60, width: 175, height: 175)
    }

    func showIndicator(){
        DispatchQueue.main.async( execute: {
            
            if let keyWindow = UIWindow.key  {
                
                
                /*
                var topViewController = keyWindow.rootViewController
                
                 
                if let presented = topViewController?.presentedViewController {
                    topViewController = presented
                    
                } else if let navController = topViewController as? UINavigationController {
                    topViewController = navController.topViewController
                } else if let tabBarController = topViewController as? UITabBarController {
                    topViewController = tabBarController.selectedViewController
                }
                */
                keyWindow.rootViewController?.present(self.alert, animated: true)
                
                self.alert.view.addSubview(self.indicatorImage)
                
                self.indicator.center = self.alert.view.center
                //self.viewLoading.center = topViewController?.view.center ?? CGPoint(x: 0.0, y: 0.0)
                
               // self.viewLoading.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 98/100, alpha: 1.0)

                //self.indicatorImage.center = viewController.view.center

                //self.label.frame = CGRect(x: self.viewLoading.center.x/2, y: 10, width: self.viewLoading.width-10, height: 40)
                
                //self.label.numberOfLines = 0
                self.blurEffectView = UIVisualEffectView(effect: self.blurEffect)
                //viewController.present(self.alert, animated: true)
                //viewController.view.addSubview(self.blurEffectView)
                //viewController.view.addSubview(self.viewLoading)
                //viewController.view.addSubview(self.indicatorImage)
                //viewController.view.addSubview(self.label)
                
                print("in show indicator")
            }
        })
    }
    func hideIndicator(completion: (() -> Void)?){

        DispatchQueue.main.async( execute:
                                    {
            print("hide indicator")
            self.alert.dismiss(animated: true) {
                self.blurEffectView.removeFromSuperview()
                completion?()
            }
            
            //self.indicatorImage.stopAnimating()
            //self.indicator.removeFromSuperview()
            //self.viewLoading.removeFromSuperview()

        })
    }
}

