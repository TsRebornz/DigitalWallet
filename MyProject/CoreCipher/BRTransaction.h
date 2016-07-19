//
//  BRTransaction.h
//  BreadWallet
//
//  Created by Aaron Voisine on 5/16/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

#define TX_FEE_PER_KB        5000ULL     // standard tx fee per kb of tx size, rounded up to nearest kb
#define TX_OUTPUT_SIZE       34          // estimated size for a typical transaction output
#define TX_INPUT_SIZE        148         // estimated size for a typical compact pubkey transaction input
#define TX_MIN_OUTPUT_AMOUNT (TX_FEE_PER_KB*3*(TX_OUTPUT_SIZE + TX_INPUT_SIZE)/1000) //no txout can be below this amount
#define TX_MAX_SIZE          100000      // no tx can be larger than this size in bytes
#define TX_FREE_MAX_SIZE     1000        // tx must not be larger than this size in bytes without a fee
#define TX_FREE_MIN_PRIORITY 57600000ULL // tx must not have a priority below this value without a fee
#define TX_UNCONFIRMED       INT32_MAX   // block height indicating transaction is unconfirmed
#define TX_MAX_LOCK_HEIGHT   500000000u  // a lockTime below this value is a block height, otherwise a timestamp

typedef union _UInt256 UInt256;

@interface BRTransaction : NSObject


@property (nonatomic, readonly) NSArray<NSString *> *inputAddresses;
//Хеши входных транзакция
@property (nonatomic, readonly) NSArray<NSValue *> *inputHashes;
// Индексы транзакций 1 к 1
@property (nonatomic, readonly) NSArray<NSNumber *> *inputIndexes;
//Получаются из inputAddresses
@property (nonatomic, readonly) NSArray<NSData *> *inputScripts;
@property (nonatomic, readonly) NSArray<NSData *> *inputSignatures;
@property (nonatomic, readonly) NSArray<NSNumber *> *inputSequences;
@property (nonatomic, readonly) NSArray<NSNumber *> *outputAmounts;
@property (nonatomic, readonly) NSArray<NSString *> *outputAddresses;
@property (nonatomic, readonly) NSArray<NSData *> *outputScripts;

@property (nonatomic, assign) UInt256 txHash;
@property (nonatomic, assign) NSString* txHashStr;
@property (nonatomic, assign) uint32_t version;
@property (nonatomic, assign) uint32_t lockTime;
@property (nonatomic, assign) uint32_t blockHeight;
@property (nonatomic, assign) NSTimeInterval timestamp; // time interval since refrence date, 00:00:00 01/01/01 GMT
@property (nonatomic, readonly) size_t size; // size in bytes if signed, or estimated size assuming compact pubkey sigs
@property (nonatomic, readonly) uint64_t standardFee;
@property (nonatomic, readonly) BOOL isSigned; // checks if all signatures exist, but does not verify them
@property (nonatomic, readonly, getter = toData) NSData *data;

@property (nonatomic, readonly) NSString *longDescription;
@property (nonatomic, assign) BOOL isTestnet;

+ (instancetype)transactionWithMessage:(NSData *)message testnet:(BOOL)isTestnet;

- (instancetype)initWithMessage:(NSData *)message testnet:(BOOL)isTestnet;
- (instancetype)initWithInputHashes:(NSArray *)hashes inputIndexes:(NSArray *)indexes inputScripts:(NSArray *)scripts
outputAddresses:(NSArray *)addresses outputAmounts:(NSArray *)amounts;

- (void)addInputHash:(UInt256)hash index:(NSUInteger)index script:(NSData *)script;
- (void)addInputHash:(UInt256)hash index:(NSUInteger)index script:(NSData *)script signature:(NSData *)signature
sequence:(uint32_t)sequence;
- (void)addInputHashStr:(NSString*)hash index:(NSUInteger)index script:(NSData *)script;
- (void)addInputHashStr:(NSString*)hash index:(NSUInteger)index script:(NSData *)script signature:(NSData *)signature
sequence:(uint32_t)sequence;
- (void)addOutputAddress:(NSString *)address amount:(uint64_t)amount;
- (void)addOutputScript:(NSData *)script amount:(uint64_t)amount;
- (void)setInputAddress:(NSString *)address atIndex:(NSUInteger)index;
- (void)shuffleOutputOrder;
- (BOOL)signWithPrivateKeys:(NSArray<NSString *> *)privateKeys;

// priority = sum(input_amount_in_satoshis*input_age_in_blocks)/tx_size_in_bytes
- (uint64_t)priorityForAmounts:(NSArray<NSNumber *> *)amounts withAges:(NSArray<NSNumber *> *)ages;

// the block height after which the transaction can be confirmed without a fee, or TX_UNCONFIRMED for never
- (uint32_t)blockHeightUntilFreeForAmounts:(NSArray<NSNumber *> *)amounts withBlockHeights:(NSArray<NSNumber *> *)heights;

@end