//
//  simlang_xcode_plugin.h
//  simlang_xcode_plugin
//
//  Created by Daniel Beard on 9/24/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface simlang_xcode_plugin : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end