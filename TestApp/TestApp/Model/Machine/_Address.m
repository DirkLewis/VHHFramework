// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Address.m instead.

#import "_Address.h"

const struct AddressAttributes AddressAttributes = {
	.city = @"city",
	.state = @"state",
	.street = @"street",
	.zip = @"zip",
};

const struct AddressRelationships AddressRelationships = {
	.address_person = @"address_person",
};

@implementation AddressID
@end

@implementation _Address

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Address";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Address" inManagedObjectContext:moc_];
}

- (AddressID*)objectID {
	return (AddressID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic city;

@dynamic state;

@dynamic street;

@dynamic zip;

@dynamic address_person;

@end

