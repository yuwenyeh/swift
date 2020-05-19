//
//  NoteViewController.swift
//  NoteAPP_practice
//
//  Created by 郭子毅 on 2020/5/12.
//  Copyright © 2020 郭子毅. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol NoteViewControllerDelegate: class {
    func didFinishUpdate(note: Note)
}

class NoteViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADInterstitialDelegate {
    
    var adView : GADInterstitial!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var currentNote : Note!
    weak var delegate : NoteViewControllerDelegate?
    var isNewImage : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.text = self.currentNote.text
        self.imageView.image = self.currentNote.image()
        
        self.adView = GADInterstitial(adUnitID: "ca-app-pub-1521801495507235/5342720898")
        self.adView.delegate = self
        self.adView.load(GADRequest())
        
        
        self.imageView.layer.borderWidth = 10
        self.imageView.layer.borderColor = UIColor.cyan.cgColor
        self.imageView.layer.cornerRadius = 10
        
        self.imageView.layer.shadowColor = UIColor.darkGray.cgColor
        self.imageView.layer.opacity = 0.9
        self.imageView.layer.shadowOffset = CGSize(width: 12, height: 12)
        self.delegate?.didFinishUpdate(note: self.currentNote)
        
    }
    //MARK: GADInterstitialDelegate
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        //使用者按下x
        self.navigationController?.popViewController(animated: true)
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        //使用者點選連結離開應用程式,前往app store 下載遊戲
        self.dismiss(animated: false){
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    
    
    @IBAction func camere(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func done(_ sender: Any) {
        
        self.currentNote.text = self.textView.text
        //self.currentNote.image = self.imageView.image
        
        if self.isNewImage {
            let homeUrl = URL(fileURLWithPath: NSHomeDirectory())
            let docUrl = homeUrl.appendingPathComponent("Documents")
            let fileName = "\(self.currentNote.noteID).jpg"
            let fileUrl = docUrl.appendingPathComponent(fileName)
            print("home \(NSHomeDirectory())")
            
            if let imageData = self.imageView.image?.jpegData(compressionQuality: 0.8) {
                do {
                    try imageData.write(to: fileUrl, options: [.atomicWrite])
                    self.currentNote.imageName = fileName
                } catch {
                    print("error saving photo \(error)")
                }
            }
            
        }
        self.delegate?.didFinishUpdate(note: self.currentNote)
        //回到前一頁
        if self.adView.isReady{
            //顯示廣告
            self.adView.present(fromRootViewController: self)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        self.imageView.image = image
        isNewImage = true
        self.dismiss(animated: true, completion: nil)
    }
    

}
