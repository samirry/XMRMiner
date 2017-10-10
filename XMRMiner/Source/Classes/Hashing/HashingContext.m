//
//  HashingContext.m
//  XMRMiner
//
//  Created by Nick Lee on 10/10/17.
//

#import "HashingContext.h"

#import <mach/vm_statistics.h>
#import <sys/mman.h>
#import <errno.h>
#import <string.h>
#import <arm_neon.h>

#import "../../../Vendor/crypto/c_groestl.h"
#import "../../../Vendor/crypto/c_blake256.h"
#import "../../../Vendor/crypto/c_jh.h"
#import "../../../Vendor/crypto/c_skein.h"
#import "../../../Vendor/crypto/c_keccak.h"

static __inline void *_mm_malloc (size_t size, size_t alignment)
{
    void *ptr;
    if (alignment == 1)
        return malloc(size);
    if (alignment == 2 || (sizeof(void *) == 8 && alignment == 4))
        alignment = sizeof(void *);
    if (posix_memalign(&ptr, alignment, size) == 0)
        return ptr;
    else
        return NULL;
}

static __inline void _mm_free (void * ptr)
{
    free (ptr);
}

#define MEMORY  2097152
#define ITER           (1 << 20)
#define AES_BLOCK_SIZE  16
#define AES_KEY_SIZE    32
#define INIT_SIZE_BLK   8
#define INIT_SIZE_BYTE (INIT_SIZE_BLK * AES_BLOCK_SIZE)

#define STATIC static
#define INLINE inline
#if !defined(RDATA_ALIGN16)
#define RDATA_ALIGN16 __attribute__ ((aligned(16)))
#endif

#define TOTALBLOCKS (MEMORY / AES_BLOCK_SIZE)

#define U64(x) ((uint64_t *) (x))

#define state_index(x) (((*((uint64_t *)x) >> 4) & (TOTALBLOCKS - 1)) << 4)
#define __mul() __asm__("mul %0, %2, %3\n\t" "umulh %1, %2, %3\n\t" : "+r"(lo), "=r"(hi) : "r"(c[0]), "r"(b[0]) );

#define pre_aes() \
j = state_index(a); \
_c = vld1q_u8(&hp_state[j]); \
_a = vld1q_u8((const uint8_t *)a); \

#define post_aes() \
vst1q_u8((uint8_t *)c, _c); \
_b = veorq_u8(_b, _c); \
vst1q_u8(&hp_state[j], _b); \
j = state_index(c); \
p = U64(&hp_state[j]); \
b[0] = p[0]; b[1] = p[1]; \
__mul(); \
a[0] += hi; a[1] += lo; \
p = U64(&hp_state[j]); \
p[0] = a[0];  p[1] = a[1]; \
a[0] ^= b[0]; a[1] ^= b[1]; \
_b = _c; \

@interface HashingContext() {
    uint8_t hs[224];
    uint8_t* _ls;
    uint8_t ci[24];
}

@end

@implementation HashingContext

@dynamic usingMappedMemory;
@dynamic usingLockedMemory;

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init]) {
        static BOOL fastmem = YES;
        static BOOL useMLock = YES;
        if (!fastmem) {
            _ls = (uint8_t *)_mm_malloc(MEMORY, 2*1024*1024);
            ci[0] = 0;
            ci[1] = 0;
        }
        else {
            _ls = (uint8_t *)mmap(0, MEMORY, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, VM_FLAGS_SUPERPAGE_SIZE_2MB, 0);
            ci[0] = 1;
            madvise(_ls, MEMORY, MADV_RANDOM | MADV_WILLNEED);
            ci[1] = 0;
            if (useMLock && mlock(_ls, MEMORY)) {
                ci[1] = 1;
            }
        }
    }
    return self;
}

- (void)dealloc
{
    if (self.usingMappedMemory) {
        if (self.usingLockedMemory) {
            munlock(_ls, MEMORY);
        }
        munmap(_ls, MEMORY);
    }
    else {
        _mm_free(_ls);
    }
    _ls = NULL;
}

#pragma mark - Properties

- (BOOL)usingMappedMemory
{
    return ci[0] > 0;
}

- (BOOL)usingLockedMemory
{
    return ci[1] > 0;
}

#pragma mark - Hashing Functions

+ (void)performBlakeHashWithInputData:(const void *)input inputLength:(size_t)length outputBuffer:(char *)output
{
    blake256_hash((uint8_t*)output, (const uint8_t*)input, length);
}

+ (void)performGroestlHashWithInputData:(const void *)input inputLength:(size_t)length outputBuffer:(char *)output
{
    groestl((const uint8_t*)input, length * 8, (uint8_t*)output);
}

+ (void)performJHHashWithInputData:(const void *)input inputLength:(size_t)length outputBuffer:(char *)output
{
    jh_hash(32 * 8, (const uint8_t*)input, 8 * length, (uint8_t*)output);
}

+ (void)performSkeinHashWithInputData:(const void *)input inputLength:(size_t)length outputBuffer:(char *)output
{
    skein_hash(8 * 32, (const uint8_t*)input, 8 * length, (uint8_t*)output);
}

@end
