//
//  SqliteBackingstore.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation
import CoreData

class SqliteBackingstore: BackingstoreProtocol {
    
    private var modelName = ""
    private var fileName = ""
    private var configurationName = ""
    private var errorArray = [NSError]()
    
    // MARK: - Initializer


    required init(modelName: String, fileName: String?, configurationName: String?){
        
        self.modelName = modelName
        self.fileName = (fileName == nil ? "\(modelName).sqlite" : "\(fileName!).sqlite")
        self.configurationName = (configurationName == nil ? "Default" : configurationName)!
        self.createManagedObjectContext()
        
    }
    
    convenience init(modelName: String, fileName: String){
        self.init(modelName: modelName, fileName: fileName, configurationName:nil)
    }
    
    convenience init(modelName: String){
        self.init(modelName: modelName, fileName:nil, configurationName:nil)
    }
    
    // MARK: - Backingstore Protocol
    
    var delegate: BackingstoreDelegate? = nil
    
    var managedObjectContext:NSManagedObjectContext?
        
    lazy var backingstoreDescription: String = {
        return "Model: \(self.modelName)\nFile: \(self.fileName)\nConfiguration: \(self.configurationName)\nLocated:\(self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.fileName))"
    }()
    
    // MARK: - Core Data stack
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.videohoohaa.coredatatest" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    private func managedObjectModel() -> NSManagedObjectModel?{
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        var momdURL: NSURL?
        
        let bundle = NSBundle(forClass: SqliteBackingstore.self)
        for modelpath in bundle.pathsForResourcesOfType("momd", inDirectory: nil){
            
            if let pathArray = NSURL.fileURLWithPath(modelpath as! String)?.pathComponents?.filter({ (name) -> Bool in
                return name as! String == "\(self.modelName).momd"
            }){
                
                momdURL = NSURL.fileURLWithPath(modelpath as! String)
                
            }
        }
        return NSManagedObjectModel(contentsOfURL: momdURL!)!
    }
    
    private func persistentStoreCoordinator() -> NSPersistentStoreCoordinator?{
    
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel()!)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.fileName)
        let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: self.configurationName, URL: url, options: options, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "com.vhh.coredata", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }
    
    private func createManagedObjectContext(){
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        
        if let coordinator = self.managedObjectContext {
            return
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator()
        self.managedObjectContext = managedObjectContext
    }
    
    
    // MARK: - Core Data support methods
    private func deleteDatastoreFiles(error:NSErrorPointer){
        //var error: NSError? = nil

        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.fileName)
        if NSFileManager.defaultManager().fileExistsAtPath("\(storeURL.path!)"){
            
            NSFileManager.defaultManager().removeItemAtPath("\(storeURL.path!)-wal", error: error)
            NSFileManager.defaultManager().removeItemAtPath("\(storeURL.path!)-shm", error: error)
            NSFileManager.defaultManager().removeItemAtPath(storeURL.path!, error: error)
        
        }
    }
    
    func resetPersistentStoreCoordiator(deleteStore: Bool) -> Bool{
    
        var error: NSError? = nil
        
        if let coordinator = self.managedObjectContext?.persistentStoreCoordinator{
            for store in coordinator.persistentStores{
                coordinator.removePersistentStore(store as! NSPersistentStore, error: &error)
            }
        }

        if deleteStore{
            self.deleteDatastoreFiles(&error)
        }
        
        if error != nil{
            self.errorArray.append(error!)
            self.delegate?.backingstoreErrorEmitted(error!)
            return false
        }
        
        return true
    }
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

    
}