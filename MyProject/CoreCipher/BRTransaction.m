//
//  BRTransaction.m
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

#import "BRTransaction.h"
#import "BRKey.h"
#import "NSString+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"
#import "NSData+Bitcoin.h"

#define TX_VERSION    0x00000001u
#define TX_LOCKTIME   0x00000000u
#define TXIN_SEQUENCE UINT32_MAX
#define SIGHASH_ALL   0x00000001u

@interface BRTransaction ()

@property (nonatomic, strong) NSMutableArray<NSValue*> *hashes;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *indexes, *sequences, *amounts ;
@property (nonatomic, strong) NSMutableArray<NSMutableData *>  *inScripts, *outScripts, *signatures ;
@property (nonatomic, strong) NSMutableArray<NSString *> *addresses ;

@end

@implementation BRTransaction

+ (instancetype)transactionWithMessage:(NSData *)message testnet:(BOOL)isTestnet
{
    return [[self alloc] initWithMessage:message testnet:isTestnet];
}

- (instancetype)init
{
    if (! (self = [super init])) return nil;
    
    _version = TX_VERSION;
    self.hashes = [NSMutableArray array];
    self.indexes = [NSMutableArray array];
    self.inScripts = [NSMutableArray array];
    self.amounts = [NSMutableArray array];
    self.addresses = [NSMutableArray array];
    self.outScripts = [NSMutableArray array];
    self.signatures = [NSMutableArray array];
    self.sequences = [NSMutableArray array];
    _lockTime = TX_LOCKTIME;
    _blockHeight = TX_UNCONFIRMED;
	//_isTestnet = NO;
    return self;
}

- (instancetype)initWithMessage:(NSData *)message testnet:(BOOL)isTestnet
{
    if (! (self = [self init])) return nil;

	_isTestnet = isTestnet;
    NSString *address = nil;
    NSUInteger l = 0, off = 0, count = 0;
    NSData *d = nil;

    @autoreleasepool {
        _version = [message UInt32AtOffset:off]; // tx version
        off += sizeof(uint32_t);
        count = (NSUInteger)[message varIntAtOffset:off length:&l]; // input count
        if (count == 0) return nil; // at least one input is required
        off += l;

        for (NSUInteger i = 0; i < count; i++) { // inputs
            [self.hashes addObject:uint256_obj([message hashAtOffset:off])];
            off += sizeof(UInt256);
            [self.indexes addObject:@([message UInt32AtOffset:off])]; // input index
            off += sizeof(uint32_t);
            [self.inScripts addObject:[NSNull null]]; // placeholder for input script (comes from input transaction)
            d = [message dataAtOffset:off length:&l];
            [self.signatures addObject:(d.length > 0) ? d : [NSNull null]]; // input signature
            off += l;
            [self.sequences addObject:@([message UInt32AtOffset:off])]; // input sequence number (for replacement tx)
            off += sizeof(uint32_t);
        }

        count = (NSUInteger)[message varIntAtOffset:off length:&l]; // output count
        off += l;

        for (NSUInteger i = 0; i < count; i++) { // outputs
            [self.amounts addObject:@([message UInt64AtOffset:off])]; // output amount
            off += sizeof(uint64_t);
            d = [message dataAtOffset:off length:&l];
            [self.outScripts addObject:(d) ? d : [NSNull null]]; // output script
            off += l;
            address = [NSString addressWithScriptPubKey:d testnet:_isTestnet]; // address from output script if applicable
            [self.addresses addObject:(address) ? address : [NSNull null]];
        }

        _lockTime = [message UInt32AtOffset:off]; // tx locktime
        _txHash = self.data.SHA256_2;
    }
    
    return self;
}

- (NSString *)txHashStr
{
	if(uint256_is_zero(_txHash)) return nil;
	return [NSString hexWithData:[NSData dataWithUInt256:_txHash]];
}

/* This constructor works well
   dont forget to sign you tx after being initialized
*/
- (instancetype)initWithInputHashes:(NSArray<NSString*> *)hashes inputIndexes:(NSArray<NSNumber*> *)indexes inputScripts:(NSArray<NSString*> *)scripts outputAddresses:(NSArray<NSString*> *)addresses outputAmounts:(NSArray<NSNumber*> *)amounts isTesnet:(BOOL)testnet
{
    self.isTestnet = testnet;

    if (hashes.count == 0 || hashes.count != indexes.count) return nil;
    if (scripts.count > 0 && hashes.count != scripts.count) return nil;
    if (addresses.count != amounts.count) return nil;

    if (! (self = [super init])) return nil;

    _version = TX_VERSION;
    
    self.hashes = [NSMutableArray arrayWithCapacity:hashes.count];
    for (NSString* hash in hashes){
        NSData* hashData = [[hash hexToData] reverse] ; 
        UInt256 hashNumber = [hashData asUInt256];
        NSValue* value = uint256_obj(hashNumber);
        [self.hashes addObject:value];
    }
    
    self.indexes = [NSMutableArray arrayWithArray:indexes];
    
    self.inScripts = [ NSMutableArray arrayWithCapacity:scripts.count];
    for (NSString* script in scripts) {
        [self.inScripts addObject: [ script hexToMutableData ] ];
    }
    
    /*
     What this code do?
     scripts.count can not be more or less hashes.count because of if statements at the start of method
    */
    while (self.inScripts.count < hashes.count) {
        [self.inScripts addObject:[NSNull null]];
    }

    self.amounts = [NSMutableArray arrayWithArray:amounts];
    self.addresses = [NSMutableArray arrayWithArray:addresses];
    self.outScripts = [NSMutableArray arrayWithCapacity:addresses.count];

    //Create outPutScripts
    for (int i = 0; i < addresses.count; i++) {
        [self.outScripts addObject:[NSMutableData data]];
        [self.outScripts.lastObject appendScriptPubKeyForAddress:self.addresses[i] testnet:self.isTestnet];
    }

    self.signatures = [NSMutableArray arrayWithCapacity:hashes.count];
    self.sequences = [NSMutableArray arrayWithCapacity:hashes.count];

    for (int i = 0; i < hashes.count; i++) {
        [self.signatures addObject:[NSNull null]];
        [self.sequences addObject:@(TXIN_SEQUENCE)];
    }

    _lockTime = TX_LOCKTIME;
    _blockHeight = TX_UNCONFIRMED;
    return self;
}

- (NSArray<NSValue *> *)inputHashes
{
    return self.hashes;
}

- (NSArray<NSNumber *> *)inputIndexes
{
    return self.indexes;
}

- (NSArray<NSData *> *)inputScripts
{
    return self.inScripts;
}

- (NSArray<NSData *> *)inputSignatures
{
    return self.signatures;
}

- (NSArray<NSNumber *> *)inputSequences
{
    return self.sequences;
}

- (NSArray<NSNumber *> *)outputAmounts
{
    return self.amounts;
}

- (NSArray<NSString *> *)outputAddresses
{
    return self.addresses;
}

- (NSArray<NSData *> *)outputScripts
{
    return self.outScripts;
}

- (NSString *)description
{
    NSString *txid = [NSString hexWithData:[NSData dataWithBytes:self.txHash.u8 length:sizeof(UInt256)].reverse];
    return [NSString stringWithFormat:@"%@(id=%@)", [self class], txid];
}

- (NSString *)longDescription
{
    NSString *txid = [NSString hexWithData:[NSData dataWithBytes:self.txHash.u8 length:sizeof(UInt256)].reverse];
    return [NSString stringWithFormat:
            @"%@(id=%@, inputHashes=%@, inputIndexes=%@, inputScripts=%@, inputSignatures=%@, inputSequences=%@, "
                           "outputAmounts=%@, outputAddresses=%@, outputScripts=%@)",
            [[self class] description], txid,
            self.inputHashes, self.inputIndexes, self.inputScripts, self.inputSignatures, self.inputSequences,
            self.outputAmounts, self.outputAddresses, self.outputScripts];
}

// size in bytes if signed, or estimated size assuming compact pubkey sigs
- (size_t)size
{
    if (! uint256_is_zero(_txHash)) return self.data.length;
    return 8 + [NSMutableData sizeOfVarInt:self.hashes.count] + [NSMutableData sizeOfVarInt:self.addresses.count] +
           TX_INPUT_SIZE*self.hashes.count + TX_OUTPUT_SIZE*self.addresses.count;
}

- (uint64_t)standardFee
{
    return ((self.size + 999)/1000)*TX_FEE_PER_KB;
}

// checks if all signatures exist, but does not verify them
- (BOOL)isSigned
{
    return (self.signatures.count > 0 && self.signatures.count == self.hashes.count &&
            ! [self.signatures containsObject:[NSNull null]]) ? YES : NO;
}

-(NSString *)getRawTxDataStr{    
    return [NSString hexWithData:[self getRawTxData]];
}

//returns the entire signed transaction
-(NSData *)getRawTxData{
    return [self toDataWithSubscriptIndex:NSNotFound];
}

- (NSData *)toData
{
    return [self toDataWithSubscriptIndex:NSNotFound];
}

- (void)addInputHashStr:(NSString*)hash index:(NSUInteger)index script:(NSData *)script
{
	[self addInputHashStr:hash index:index script:script signature:nil sequence:TXIN_SEQUENCE];
}

- (void)addInputHashStr:(NSString*)hash index:(NSUInteger)index script:(NSData *)script signature:(NSData *)signature
			   sequence:(uint32_t)sequence
{
	NSData * hash_data = [[hash hexToData] reverse];        // string tx hash representation is big-endian
	UInt256 hash_digital = [hash_data asUInt256];       // but here we work with little-endian
	if(uint256_is_zero(hash_digital))
	{
		return;
	}

	[self.hashes addObject:uint256_obj(hash_digital)];
	[self.indexes addObject:@(index)];
	[self.inScripts addObject:(script) ? script : [NSNull null]];
	[self.signatures addObject:(signature) ? signature : [NSNull null]];
	[self.sequences addObject:@(sequence)];
}

- (void)addInputHash:(UInt256)hash index:(NSUInteger)index script:(NSData *)script
{
    [self addInputHash:hash index:index script:script signature:nil sequence:TXIN_SEQUENCE];
}

- (void)addInputHash:(UInt256)hash index:(NSUInteger)index script:(NSData *)script signature:(NSData *)signature
sequence:(uint32_t)sequence
{
    [self.hashes addObject:uint256_obj(hash)];
    [self.indexes addObject:@(index)];
    [self.inScripts addObject:(script) ? script : [NSNull null]];
    [self.signatures addObject:(signature) ? signature : [NSNull null]];
    [self.sequences addObject:@(sequence)];
}

- (void)addOutputAddress:(NSString *)address amount:(uint64_t)amount
{
    [self.amounts addObject:@(amount)];
    [self.addresses addObject:address];
    [self.outScripts addObject:[NSMutableData data]];
	[self.outScripts.lastObject appendScriptPubKeyForAddress:address testnet:[address isValidBitcoinAddress:YES]];
}

- (void)addOutputScript:(NSData *)script amount:(uint64_t)amount
{
    NSString *address = [NSString addressWithScriptPubKey:script testnet:_isTestnet];

    [self.amounts addObject:@(amount)];
    [self.outScripts addObject:script];
    [self.addresses addObject:(address) ? address : [NSNull null]];
}

- (void)setInputAddress:(NSString *)address atIndex:(NSUInteger)index;
{
    NSMutableData *d = [NSMutableData data];
	[d appendScriptPubKeyForAddress:address testnet:[address isValidBitcoinAddress:YES]];
	self.inScripts[index] = d;
}

- (NSArray<NSString *>*)inputAddresses
{
    NSMutableArray *addresses = [NSMutableArray arrayWithCapacity:self.inScripts.count];
    NSInteger i = 0;

    for (NSData *script in self.inScripts) {
        NSString *addr = [NSString addressWithScriptPubKey:script testnet:_isTestnet];

		if (! addr) addr = [NSString addressWithScriptSig:self.signatures[i] testnet:_isTestnet];
        [addresses addObject:(addr) ? addr : [NSNull null]];
        i++;
    }

    return addresses;
}

- (void)shuffleOutputOrder
{    
    for (NSUInteger i = 0; i + 1 < self.amounts.count; i++) { // fischer-yates shuffle
        NSUInteger j = i + arc4random_uniform((uint32_t)(self.amounts.count - i));
        
        if (j == i) continue;
        [self.amounts exchangeObjectAtIndex:i withObjectAtIndex:j];
        [self.outScripts exchangeObjectAtIndex:i withObjectAtIndex:j];
        [self.addresses exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
}

// Returns the binary transaction data that needs to be hashed and signed with the private key for the tx input at
// subscriptIndex. A subscriptIndex of NSNotFound will return the entire signed transaction.
- (NSData *)toDataWithSubscriptIndex:(NSUInteger)subscriptIndex
{
    UInt256 hash;
    NSMutableData *d = [NSMutableData dataWithCapacity:10 + TX_INPUT_SIZE*self.hashes.count +
                        TX_OUTPUT_SIZE*self.addresses.count];

    [d appendUInt32:self.version];
    [d appendVarInt:self.hashes.count];

    for (NSUInteger i = 0; i < self.hashes.count; i++) {
        [self.hashes[i] getValue:&hash];
        [d appendBytes:&hash length:sizeof(hash)];
        [d appendUInt32:[self.indexes[i] unsignedIntValue]];

        if (subscriptIndex == NSNotFound && self.signatures[i] != [NSNull null]) {
            [d appendVarInt:[self.signatures[i] length]];
            [d appendData:self.signatures[i]];
        }        
        else if (subscriptIndex == i && self.inScripts[i] != [NSNull null]) {
            //TODO: to fully match the reference implementation, OP_CODESEPARATOR related checksig logic should go here
            [d appendVarInt:[self.inScripts[i] length]];
            [d appendData:self.inScripts[i]];
        }
        else [d appendVarInt:0];
        
        [d appendUInt32:[self.sequences[i] unsignedIntValue]];
    }
    
    [d appendVarInt:self.amounts.count];
    
    //Ouputs formation
    for (NSUInteger i = 0; i < self.amounts.count; i++) {
        [d appendUInt64:[self.amounts[i] unsignedLongLongValue]];
        [d appendVarInt:[self.outScripts[i] length]];
        [d appendData:self.outScripts[i]];
    }
    
    [d appendUInt32:self.lockTime];
    if (subscriptIndex != NSNotFound) [d appendUInt32:SIGHASH_ALL];
    return d;
}

- (BOOL)signWithPrivateKeys:(NSArray<NSString *> *)privateKeys
{
    NSMutableArray *addresses = [NSMutableArray arrayWithCapacity:privateKeys.count],
                   *keys = [NSMutableArray arrayWithCapacity:privateKeys.count];
    
    for (NSString *pk in privateKeys) {
        BRKey *key = [BRKey keyWithPrivateKey:pk testnet:_isTestnet];
        
        if (! key) continue;
        [keys addObject:key];
        [addresses addObject:key.address];
    }
    
    for (NSUInteger i = 0; i < self.hashes.count; i++) {
        NSString *addr = [NSString addressWithScriptPubKey:self.inScripts[i] testnet:_isTestnet];
        NSUInteger keyIdx = (addr) ? [addresses indexOfObject:addr] : NSNotFound;
        
        if (keyIdx == NSNotFound) continue;
        
        NSMutableData *sig = [NSMutableData data];
        //hash - raw [byte] tx which should be signed
        UInt256 hash = [self toDataWithSubscriptIndex:i].SHA256_2;
        NSMutableData *s = [NSMutableData dataWithData:[keys[keyIdx] sign:hash]];
        NSArray *elem = [self.inScripts[i] scriptElements];
        
        [s appendUInt8:SIGHASH_ALL];
        [sig appendScriptPushData:s];
        
        if (elem.count >= 2 && [elem[elem.count - 2] intValue] == OP_EQUALVERIFY) { // pay-to-pubkey-hash scriptSig
            [sig appendScriptPushData:[keys[keyIdx] publicKey]];
        }
        
        self.signatures[i] = sig;
    }
    
    if (! self.isSigned) return NO;
    _txHash = self.data.SHA256_2;
    return YES;
}

// priority = sum(input_amount_in_satoshis*input_age_in_blocks)/size_in_bytes
- (uint64_t)priorityForAmounts:(NSArray<NSNumber *> *)amounts withAges:(NSArray<NSNumber *> *)ages
{
    uint64_t p = 0;
    
    if (amounts.count != self.hashes.count || ages.count != self.hashes.count || [ages containsObject:@(0)]) return 0;
    
    for (NSUInteger i = 0; i < amounts.count; i++) {    
        p += [amounts[i] unsignedLongLongValue]*[ages[i] unsignedLongLongValue];
    }
    
    return p/self.size;
}

// the block height after which the transaction can be confirmed without a fee, or TX_UNCONFIRMRED for never
- (uint32_t)blockHeightUntilFreeForAmounts:(NSArray<NSNumber *> *)amounts withBlockHeights:(NSArray<NSNumber *> *)heights
{
    if (amounts.count != self.hashes.count || heights.count != self.hashes.count ||
        self.size > TX_FREE_MAX_SIZE || [heights containsObject:@(TX_UNCONFIRMED)]) {
        return TX_UNCONFIRMED;
    }

    for (NSNumber *amount in self.amounts) {
        if (amount.unsignedLongLongValue < TX_MIN_OUTPUT_AMOUNT) return TX_UNCONFIRMED;
    }

    uint64_t amountTotal = 0, amountsByHeights = 0;
    
    for (NSUInteger i = 0; i < amounts.count; i++) {
        amountTotal += [amounts[i] unsignedLongLongValue];
        amountsByHeights += [amounts[i] unsignedLongLongValue]*[heights[i] unsignedLongLongValue];
    }
    
    if (amountTotal == 0) return TX_UNCONFIRMED;
    
    // this could possibly overflow a uint64 for very large input amounts and far in the future block heights,
    // however we should be okay up to the largest current bitcoin balance in existence for the next 40 years or so,
    // and the worst case is paying a transaction fee when it's not needed
    return (uint32_t)((TX_FREE_MIN_PRIORITY*(uint64_t)self.size + amountsByHeights + amountTotal - 1ULL)/amountTotal);
}

- (NSUInteger)hash
{
    if (uint256_is_zero(_txHash)) return super.hash;
    return *(const NSUInteger *)&_txHash;
}

- (BOOL)isEqual:(id)object
{
    return self == object || ([object isKindOfClass:[BRTransaction class]] && uint256_eq(_txHash, [object txHash]));
}

@end
