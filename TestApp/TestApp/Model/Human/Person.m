#import "Person.h"

@interface Person ()

// Private interface goes here.

@end

@implementation Person

// Custom logic goes here.
- (NSString *)personDescription{

    return [NSString stringWithFormat:@"%@ %@, %@",self.fName, self.lName, self.age];
}
@end
