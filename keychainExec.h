//
//  keychainExec.h
//  Machina
//
//  Created by Carlos Landaverde on 7/12/15.
//  Copyright (c) 2015 Carlos Landaverde. All rights reserved.
//

#ifndef Machina_keychainExec_h
#define Machina_keychainExec_h

#import <Foundation/Foundation.h>
#import <Security/Security.h>

typedef enum {
    // No error
    keychainExecErrorNo = noErr,
    
    // Bad arguments
    keychainExecErrorBadArgs = -1001
    
} keychainExecErrorCode;

extern NSString *const keychainErrorDom;

static int keyCapacity = 3;
    
@interface keychainExec : NSObject

// Saving
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)service account:(NSString *)account error:(NSError **)error;

// Getting
+ (NSString *)passwordForService: (NSString *)service account:(NSString *)account error:(NSError **)error;

// Deleting
+ (BOOL)deletePasswordForService: (NSString *)service account:(NSString *)account error:(NSError **)error;

@end

#endif
