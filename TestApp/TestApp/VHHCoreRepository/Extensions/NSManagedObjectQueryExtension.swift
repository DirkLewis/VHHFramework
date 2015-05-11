//
//  NSManagedObjectQueryExtension.swift
//  TestApp
//
//  Created by Dirk Lewis on 5/11/15.
//  Copyright (c) 2015 VHH. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject: AnyObject{
    
    func fetchRequestForEntityNamed(entityName: String, batchsize:Int) -> fetchRequestReturnType{
        var fetchrequest: NSFetchRequest? = nil
        
        fetchrequest = NSFetchRequest(entityName: entityName)
        fetchrequest!.fetchBatchSize = batchsize
        
        if let request = fetchrequest{
            return fetchRequestReturnType.success(fetchrequest!)
        }
        else{
            return fetchRequestReturnType.failure(NSError(domain: repositoryErrorDomain, code: repositoryFailCode, userInfo: ["message":"FetchRequest failed initialization."]))
        }
        
    }
    
    func fetchRequestForEntityNamed(entityName: String) -> fetchRequestReturnType{
        return self.fetchRequestForEntityNamed(entityName, batchsize: defaultBatchSize)
    }
    
    func resultsForRequest(request:NSFetchRequest) -> repositoryDataReturnType{
        var error: NSError? = nil
        var results = [AnyObject]()
        
        self.managedObjectContext!.performBlockAndWait({ () -> Void in
            results = self.managedObjectContext!.executeFetchRequest(request, error: &error)!
            println("\(results)")
        })
        
        
        if let currenterror = error{
            return repositoryDataReturnType.failure(currenterror)
        }
        return repositoryDataReturnType.success(results)
    }
    
    func resultsForRequestAsync(request:NSFetchRequest, handler:(repositoryDataReturnType) -> ()){
        var error: NSError? = nil
        self.managedObjectContext!.performBlock({ () -> Void in
            if let results = self.managedObjectContext!.executeFetchRequest(request, error: &error){
                if let currenterror = error{
                    handler(repositoryDataReturnType.failure(currenterror))
                }
                else{
                    handler(repositoryDataReturnType.success(results))
                }
            }
        })
    }
    
    func createNewEntity<T:CoreRepositoryObjectProtocol>() -> T{
        return NSEntityDescription.insertNewObjectForEntityForName(T.entityName(), inManagedObjectContext: self.managedObjectContext!) as! T
    }
    
    func fetchEntityForEntityIdentifier<T:CoreRepositoryObjectProtocol>(identifier:String) -> T?{
        
        switch self.fetchRequestForEntityNamed(T.entityName()){
        case let fetchRequestReturnType.success(request):
            switch self.resultsForRequest(request){
            case let repositoryDataReturnType.success(results):
                if let filtered = (results.filter({($0 as! T).entityIdentifier == identifier as String}).first) as? T{
                    return filtered
                }
            case let repositoryDataReturnType.failure(error):
                println("Error: \(error.localizedDescription)")
            }
        case let fetchRequestReturnType.failure(error):
            println("Error: \(error.localizedDescription)")
            
        }
        return nil
    }
    
    func fetchEntityWithFilter<T: CoreRepositoryObjectProtocol>(filter:(includedElement:AnyObject) -> Bool) -> repositoryDataReturnType{
        
        switch self.fetchRequestForEntityNamed(T.entityName()){
        case let fetchRequestReturnType.success(request):
            switch self.resultsForRequest(request){
            case let repositoryDataReturnType.success(results):
                let filtered = results.filter(filter)
                println("Count: \(filtered.count)")
                return repositoryDataReturnType.success(filtered as! [T])
            case let repositoryDataReturnType.failure(error):
                println("Error: \(error.localizedDescription)")
            }
        case let fetchRequestReturnType.failure(error):
            println("Error: \(error.localizedDescription)")
            
        }
        return repositoryDataReturnType.success([T]())
        
    }
}