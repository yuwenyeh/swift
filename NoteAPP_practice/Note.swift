//
//  Note.swift
//  NoteAPP_practice
//
//  Created by 郭子毅 on 2020/5/12.
//  Copyright © 2020 郭子毅. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Note: NSManagedObject {
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.noteID == rhs.noteID
    }
    
    
    @NSManaged var text : String?
    //var image : UIImage?
    @NSManaged var imageName : String?
    @NSManaged var noteID : String
    
    override func awakeFromInsert() {
        self.noteID = UUID().uuidString
    }
    
    //    init() {
    //        self.noteID = UUID().uuidString

    
    //MARK: - HelperMethod
    
    func image() -> UIImage? {
        
        if let fileName = self.imageName {
            let homeUrl = URL(fileURLWithPath: NSHomeDirectory())
            let docUrl = homeUrl.appendingPathComponent("Documents")
            let fileUrl = docUrl.appendingPathComponent(fileName)
            return UIImage(contentsOfFile: fileUrl.path)
        }
        return nil
        
    }
}
