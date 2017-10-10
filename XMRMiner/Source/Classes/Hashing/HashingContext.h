//
//  HashingContext.h
//  XMRMiner
//
//  Created by Nick Lee on 10/10/17.
//

#import <Foundation/Foundation.h>

@interface HashingContext : NSObject

@property (nonatomic, readonly) BOOL usingMappedMemory;
@property (nonatomic, readonly) BOOL usingLockedMemory;

+ (void)performBlakeHashWithInputData:(const void *)input inputLength:(size_t)length outputBuffer:(char *)output;
+ (void)performGroestlHashWithInputData:(const void *)input inputLength:(size_t)length outputBuffer:(char *)output;
+ (void)performJHHashWithInputData:(const void *)input inputLength:(size_t)length outputBuffer:(char *)output;
+ (void)performSkeinHashWithInputData:(const void *)input inputLength:(size_t)length outputBuffer:(char *)output;

@end
