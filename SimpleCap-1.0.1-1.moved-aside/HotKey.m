//
//  HotKey.m
//  SimpleCap
//
//  Created by 湖 on 09/06/17.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "HotKey.h"
#import <Carbon/Carbon.h>

@implementation HotKey

+ (UInt32)defaultKey
{
	return (cmdKey|optionKey)<<16 | 29;
}

@end
