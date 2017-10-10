//
//  HashWrapperA.m
//  XMRMiner
//
//  Created by Nick Lee on 10/10/17.
//

#import "HashWrapperA.h"
#import "HashWrapperB.h"

extern NSData * _Nonnull td_cc_slow(NSData * _Nonnull input) {
    return _td_cc_slow(input);
}
