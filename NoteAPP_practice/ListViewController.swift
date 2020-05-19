//
//  ListViewController.swift
//  NoteAPP_practice
//
//  Created by 郭子毅 on 2020/5/12.
//  Copyright © 2020 郭子毅. All rights reserved.
//

import UIKit
import CoreData
import StoreKit
import MessageUI
import FirebaseAnalytics
import GoogleMobileAds

class ListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, NoteViewControllerDelegate,MFMailComposeViewControllerDelegate,GADBannerViewDelegate {
    
    var bannerView : GADBannerView!
    
    var data : [Note] = []
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.queryFromCoreData()
//        for index in 1...10 {
//
//            let note = Note()
//            note.text = "new note \(index)"
//            data.append(note)
//        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.title = NSLocalizedString("list", comment: "")
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner) //設定banner大小
        self.bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerView.adUnitID = "ca-app-pub-2224470612063698/5441480167"//橫幅廣告id
        //"ca-app-pub-2224470612063698/5441480167"
        self.bannerView.delegate = self
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
    }
    
    //廣告近來時會呼叫,GADBannerViewDelegate
    //tableHeaderViewd卡在畫面上 訂在上面
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
       // self.tableView.tableHeaderView = self.bannerView
        
        if self.bannerView.superview == nil {
            self.topConstraint.isActive = false
            self.view.addSubview(self.bannerView)
            
            //autolayout
    self.bannerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
    self.bannerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant:0).isActive = true
    self.bannerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            self.bannerView.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0).isActive = true
 
        }
        

    }

    //新增使用者使用評分直接在APP裡面評分,一年以內最多只會跳3次
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //SKStoreReviewController.requestReview()跳幾棵星
        support()  //MFMailConpostViewControllerDelegate測試
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
        
    }
    
    @IBAction func askForRating(){
           
           let askController = UIAlertController(title: "Hello App User",
        message: "If you like this app,please rate in App Store. Thanks.",preferredStyle: .alert)
           let laterAction = UIAlertAction(title: "稍候再評",style: .default, handler: nil)
           askController.addAction(laterAction)
           let okAction = UIAlertAction(title: "我要評分", style: .default)
           { (action) -> Void in
               let appID = "12345"
               let appURL = URL(string: "https://itunes.apple.com/us/app/itunes-u/id\(appID)?action=write-review")!
               UIApplication.shared.open(appURL, options: [:],completionHandler: { (success) in
               })
           }
           askController.addAction(okAction)
           self.present(askController, animated: true, completion: nil)
           
       }
    @IBAction func addNote(_ sender: Any) {
        
        Analytics.logEvent("addNote", parameters: nil)//數據統計會跳到google-Firebase
        Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: [AnalyticsParameterPrice:2,
           AnalyticsParameterCurrency:"USD",
           AnalyticsParameterValue: 2,
        AnalyticsParameterQuantity:1]) //紀錄使用者購買
        
        
        //let note = Note()
        let moc = CoreDataHelper.shared.managedObjectContext()
        let note = Note(context: moc)
        note.text = NSLocalizedString("new.note", comment: "")
        
        self.data.insert(note, at: 0)
        self.saveToCoreData()
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: - UITableViewDelegate
    
    func didFinishUpdate(note: Note) {
    
        if let index = self.data.firstIndex(of: note) {
            
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        self.saveToCoreData()
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        let note = self.data[indexPath.row]
        cell.showsReorderControl = true
        
        cell.textLabel?.text = note.text
        cell.imageView?.image = note.image()
        
        //設定時間日期方式
        let now = Date()
        
      let datefromatter = DateFormatter()
       // let calendar = Calendar(identifier: .republicOfChina)
        let calendar = Calendar(identifier: .chinese)//農名歷
        
        datefromatter.calendar = calendar
        datefromatter.timeStyle = .short
        datefromatter.timeStyle = .long
        cell.detailTextLabel?.text = datefromatter.string(from: now)
        
        cell.detailTextLabel?.text = NumberFormatter.localizedString(from: 1234.56, number: .currencyPlural)
        
        
        
       // cell.detailTextLabel?.text = DateFormatter.localizedString(from: now, dateStyle: .full, timeStyle: .short)
        
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.data.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let data = self.data.remove(at: indexPath.row)
            let moc = CoreDataHelper.shared.managedObjectContext()
            moc.performAndWait {
                moc.delete(data)
            }
            self.saveToCoreData()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noteSegue" {
            let noteVC = segue.destination as! NoteViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                 
                let note = self.data[indexPath.row]
                noteVC.currentNote = note
                noteVC.delegate = self
            }
        }
    }
    
    //MARK: - Core Data
    
    func queryFromCoreData() {
        
        let moc = CoreDataHelper.shared.managedObjectContext()
        let request = NSFetchRequest<Note>.init(entityName: "Note")
        
        let sort = NSSortDescriptor(key: "text", ascending: true)
        request.sortDescriptors = [sort]
        
        moc.performAndWait {
            do {
                let result : [Note] = try moc.fetch(request)
                self.data = result
            } catch {
                print(error)
                self.data = []
            }
        }
    }
    
    func saveToCoreData() {
        CoreDataHelper.shared.saveContext()
    }
    
     
     @IBAction func support(){

            if ( MFMailComposeViewController.canSendMail()){
                let alert = UIAlertController(title: "", message: "We want to hear from you, Please send us your feedback by email in English", preferredStyle: .alert)
                let email = UIAlertAction(title: "email", style: .default, handler: { (action) -> Void in
                    let mailController =  MFMailComposeViewController()
                    mailController.mailComposeDelegate = self
                    mailController.title = "I have question"
                    mailController.setSubject("I have question")
                    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                    let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
                    let messageBody = "<br/><br/><br/>Product:\(product!)(\(version!))"
                    mailController.setMessageBody(messageBody, isHTML: true)
                    mailController.setToRecipients(["support@yoursupportemail.com"])
                    self.present(mailController, animated: true, completion: nil)
                })
                alert.addAction(email)
                self.present(alert, animated: true, completion: nil)
            }else{
                //alert user can't send email
            }
        }
     
     //MARK: MFMailComposeViewControllerDelegate
     func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
         switch (result){
         case MFMailComposeResult.cancelled:
             print("user cancelled")
         case MFMailComposeResult.failed:
             print("user failed")
         case MFMailComposeResult.saved:
             print("user saved email")
         case MFMailComposeResult.sent:
             print("email sent")
         }
         self.dismiss(animated: true, completion: nil)
     }
     
}



