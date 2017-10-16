//
//  HashContext.m
//  XMRMiner
//
//  Created by Nick Lee on 10/12/17.
//

#import "HashContext.h"
#import "../../../Vendor/crypto/hash.h"

using namespace crypto;

@implementation HashContext

- (NSData * _Nonnull)hashData:(NSData * _Nonnull)data
{
    hash output = hash();
    cn_slow_hash([data bytes], [data length], output);
    return [NSData dataWithBytes:output.data length:32];
}

@end
