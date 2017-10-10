//
//  HashWrapperB.m
//  XMRMiner
//
//  Created by Nick Lee on 10/10/17.
//

#import "../../../Vendor/crypto/hash.h"

using namespace crypto;

extern "C"
{
    NSData * _Nonnull _td_cc_slow(NSData * _Nonnull input);
}

NSData * _Nonnull _td_cc_slow(NSData * _Nonnull input) {
    hash output = hash();
    cn_slow_hash([input bytes], [input length], output);
    NSLog(@"hey");
    return [NSData data];
}
