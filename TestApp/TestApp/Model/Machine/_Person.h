// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.h instead.

#import <CoreData/CoreData.h>

extern const struct PersonAttributes {
	__unsafe_unretained NSString *age;
	__unsafe_unretained NSString *fName;
	__unsafe_unretained NSString *lName;
} PersonAttributes;

@interface PersonID : NSManagedObjectID {}
@end

@interface _Person : NSManagedObject {}
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PersonID* objectID;

@property (nonatomic, strong) NSNumber* age;

@property (atomic) int16_t ageValue;
- (int16_t)ageValue;
- (void)setAgeValue:(int16_t)value_;

//- (BOOL)validateAge:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fName;

//- (BOOL)validateFName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* lName;

//- (BOOL)validateLName:(id*)value_ error:(NSError**)error_;

@end

@interface _Person (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveAge;
- (void)setPrimitiveAge:(NSNumber*)value;

- (int16_t)primitiveAgeValue;
- (void)setPrimitiveAgeValue:(int16_t)value_;

- (NSString*)primitiveFName;
- (void)setPrimitiveFName:(NSString*)value;

- (NSString*)primitiveLName;
- (void)setPrimitiveLName:(NSString*)value;

@end
