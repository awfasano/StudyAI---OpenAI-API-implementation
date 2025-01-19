//
//  Utilities.swift
//  Waited
//
//  Created by Anthony Fasano on 12/14/20.
//

import Foundation
import UIKit

class Utilities {
    
    
    static func styleTextField(_ textfield:UITextField, color: UIColor?){
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 1, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 0, green: 71/255, blue: 171/255, alpha: 1).cgColor // #4c4c4c
        
        textfield.borderStyle = .none
        
        if color != nil {
            bottomLine.backgroundColor = color?.cgColor
        }
        
        textfield.layer.addSublayer(bottomLine)
    }
    
    static func styleFillButton(_ button:UIButton) {
        button.backgroundColor = UIColor.init(red: 0, green: 71/255, blue: 171/255, alpha: 1) // #4c4c4c
        button.titleLabel?.textColor = UIColor.init(hue: 0.0333, saturation: 0, brightness: 0.3, alpha: 1.0)
        button.layer.cornerRadius = button.frame.height/2
        button.tintColor = UIColor.white
        
    }
    static func styleFillButton2(_ button:UIButton, color: UIColor) {
        button.backgroundColor = color
        button.titleLabel?.textColor = UIColor.init(hue: 0.0333, saturation: 0, brightness: 0.3, alpha: 1.0)
        button.layer.cornerRadius = button.frame.height/2
        button.tintColor = UIColor.white

        
    }
    
    static func styleHollowButton(_ button: UIButton) {
        button.layer.borderWidth = 2
                
        button.layer.borderColor = UIColor.init(red: 0, green: 71/255, blue: 171/255, alpha: 1).cgColor
        
        
        button.layer.cornerRadius = button.frame.height/2
        button.tintColor = UIColor.init(red: 0, green: 71/255, blue: 171/255, alpha: 1)
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
}


public protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}



open class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}



