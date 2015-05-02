// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Address.h instead.

#import <CoreData/CoreData.h>

extern const struct AddressAttributes {
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *street;
	__unsafe_unretained NSString *zip;
} AddressAttributes;

extern const struct AddressRelationships {
	__unsafe_unretained NSString *address_person;
} AddressRelationships;

@class Person;

@interface AddressID : NSManagedObjectID {}
@end

@interface _Address : NSManagedObject {}
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) AddressID* objectID;

@property (nonatomic, strong) NSString* city;

//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* street;

//- (BOOL)validateStreet:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* zip;

//- (BOOL)validateZip:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Person *address_person;

//- (BOOL)validateAddress_person:(id*)value_ error:(NSError**)error_;

@end

@interface _Address (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;

- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;

- (NSString*)primitiveStreet;
- (void)setPrimitiveStreet:(NSString*)value;

- (NSString*)primitiveZip;
- (void)setPrimitiveZip:(NSString*)value;

- (Person*)primitiveAddress_person;
- (void)setPrimitiveAddress_person:(Person*)value;

@end
