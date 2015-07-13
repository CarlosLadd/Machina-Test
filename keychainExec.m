//
//  keychainExec.m
//  Machina
//
//  Created by Carlos Landaverde on 7/12/15.
//  Copyright (c) 2015 Raven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "keychainExec.h"

NSString *const keychainErrorDom = @"com.machina.keychainexec";

@implementation keychainExec

#pragma mark - Get key app

+ (NSString *)passwordForService: (NSString *)service account:(NSString *)account error:(NSError **)error {
    NSData *data = [self passwordDataForService: service account: account error: error];
    
    if (data.length > 0) {
        return [[NSString alloc] initWithData:(NSData *)data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (NSData *)passwordDataForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    OSStatus status = keychainExecErrorBadArgs;
    
    if (!service || !account) {
        if (error) {
            *error = [NSError errorWithDomain: keychainErrorDom code:status userInfo: nil];
        }
        return nil;
    }
    
    CFTypeRef result = NULL;
    NSMutableDictionary *query = [self _queryForService:service account:account];
    
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    if (status != noErr && error != NULL) {
        *error = [NSError errorWithDomain: keychainErrorDom code:status userInfo: nil];
        return nil;
    }
    
    return (__bridge_transfer NSData *)result;
}

#pragma mark - Saving key app

+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    return [self setPasswordData:data forService:service account:account error:error];
}

+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    OSStatus status = keychainExecErrorBadArgs;
    
    if (password && service && account) {
        [self deletePasswordForService: service account: account error: nil];
        NSMutableDictionary *query = [self _queryForService: service account: account];
        [query setObject: password forKey: (__bridge id)kSecValueData];
        
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        
    }
    if (status != noErr && error != NULL) {
        *error = [NSError errorWithDomain: keychainErrorDom code:status userInfo: nil];
    }
    return (status == noErr);
}

+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    OSStatus status = keychainExecErrorBadArgs;
    
    if (service && account) {
        NSMutableDictionary *query = [self _queryForService:service account:account];
        status = SecItemDelete((__bridge CFDictionaryRef)query);
    }
    
    if (status != noErr && error != NULL) {
        *error = [NSError errorWithDomain: keychainErrorDom code: status userInfo:nil];
    }
    
    return (status == noErr);
}

#pragma mark - Private query

+ (NSMutableDictionary *)_queryForService:(NSString *)service account:(NSString *)account {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity: keyCapacity];
    [dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    if (service) {
        [dictionary setObject: service forKey:(__bridge id)kSecAttrService];
    }
    
    if (account) {
        [dictionary setObject: account forKey:(__bridge id)kSecAttrAccount];
    }
    
    return dictionary;
}

@end