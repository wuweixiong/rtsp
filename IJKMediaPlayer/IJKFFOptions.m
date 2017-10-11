/*
 * IJKFFOptions.m
 *
 * Copyright (c) 2013-2015 Zhang Rui <bbcallen@gmail.com>
 *
 * This file is part of ijkPlayer.
 *
 * ijkPlayer is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * ijkPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with ijkPlayer; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#import "IJKFFOptions.h"
#include "ijkplayer/ios/ijkplayer_ios.h"

@implementation IJKFFOptions {
    NSMutableDictionary *_optionCategories;

    NSMutableDictionary *_playerOptions;
    NSMutableDictionary *_formatOptions;
    NSMutableDictionary *_codecOptions;
    NSMutableDictionary *_swsOptions;
    NSMutableDictionary *_swrOptions;
}

+ (IJKFFOptions *)optionsByDefault
{
    IJKFFOptions *options = [[IJKFFOptions alloc] init];

    [options setPlayerOptionIntValue:0     forKey:@"max-fps"];
    [options setPlayerOptionIntValue:60      forKey:@"framedrop"];
    [options setPlayerOptionIntValue:3      forKey:@"video-pictq-size"];
    [options setPlayerOptionIntValue:0      forKey:@"videotoolbox"];
    [options setPlayerOptionIntValue:960    forKey:@"videotoolbox-max-frame-width"];
    
    [options setFormatOptionIntValue:0                  forKey:@"auto_convert"];
    [options setFormatOptionIntValue:1                  forKey:@"reconnect"];
    [options setFormatOptionIntValue:30 * 1000 * 1000   forKey:@"timeout"];
    [options setFormatOptionValue:@"ijkplayer"          forKey:@"user-agent"];
    
    [options setPlayerOptionIntValue:30  forKey:@"max-fps"];
    [options setPlayerOptionIntValue:1  forKey:@"framedrop"];
    [options setPlayerOptionIntValue:0  forKey:@"start-on-prepared"];
    [options setPlayerOptionIntValue:0  forKey:@"http-detect-range-support"];
    [options setPlayerOptionIntValue:0  forKey:@"skip_loop_filter"];
    [options setPlayerOptionIntValue:0  forKey:@"packet-buffering"];
    [options setPlayerOptionIntValue:2000000 forKey:@"analyzeduration"];
    [options setPlayerOptionIntValue:3  forKey:@"min-frames"];
    [options setPlayerOptionIntValue:1  forKey:@"start-on-prepared"];
    //
    [options setCodecOptionIntValue:8 forKey:@"skip_frame"];
    //
    [options setFormatOptionValue:@"nobuffer" forKey:@"fflags"];
    [options setFormatOptionValue:@"8192" forKey:@"probsize"];
    [options setFormatOptionIntValue:0 forKey:@"auto_convert"];
    [options setFormatOptionIntValue:1 forKey:@"reconnect"];
    //
    [options setPlayerOptionIntValue:3000 forKey:@"max_cached_duration"];   // 最大缓存大小是3秒，可以依据自己的需求修改
    [options setPlayerOptionIntValue:1 forKey:@"infbuf"];  // 无限读
    
    options.showHudView   = NO;

    return options;
}

- (id)init
{
    self = [super init];
    if (self) {
        _playerOptions      = [[NSMutableDictionary alloc] init];
        _formatOptions      = [[NSMutableDictionary alloc] init];
        _codecOptions       = [[NSMutableDictionary alloc] init];
        _swsOptions         = [[NSMutableDictionary alloc] init];
        _swrOptions         = [[NSMutableDictionary alloc] init];

        _optionCategories   = [[NSMutableDictionary alloc] init];
        _optionCategories[@(IJKMP_OPT_CATEGORY_PLAYER)] = _playerOptions;
        _optionCategories[@(IJKMP_OPT_CATEGORY_FORMAT)] = _formatOptions;
        _optionCategories[@(IJKMP_OPT_CATEGORY_CODEC)]  = _codecOptions;
        _optionCategories[@(IJKMP_OPT_CATEGORY_SWS)]    = _swsOptions;
        _optionCategories[@(IJKMP_OPT_CATEGORY_SWR)]    = _swrOptions;
    }
    return self;
}

- (void)applyTo:(IjkMediaPlayer *)mediaPlayer
{
    [_optionCategories enumerateKeysAndObjectsUsingBlock:^(id categoryKey, id categoryDict, BOOL *stopOuter) {
        [categoryDict enumerateKeysAndObjectsUsingBlock:^(id optKey, id optValue, BOOL *stop) {
            if ([optValue isKindOfClass:[NSNumber class]]) {
                ijkmp_set_option_int(mediaPlayer,
                                     (int)[categoryKey integerValue],
                                     [optKey UTF8String],
                                     [optValue longLongValue]);
            } else if ([optValue isKindOfClass:[NSString class]]) {
                ijkmp_set_option(mediaPlayer,
                                 (int)[categoryKey integerValue],
                                 [optKey UTF8String],
                                 [optValue UTF8String]);
            }
        }];
    }];
}

- (void)setOptionValue:(NSString *)value
                forKey:(NSString *)key
            ofCategory:(IJKFFOptionCategory)category
{
    if (!key)
        return;

    NSMutableDictionary *options = [_optionCategories objectForKey:@(category)];
    if (options) {
        if (value) {
            [options setObject:value forKey:key];
        } else {
            [options removeObjectForKey:key];
        }
    }
}

- (void)setOptionIntValue:(int64_t)value
                   forKey:(NSString *)key
               ofCategory:(IJKFFOptionCategory)category
{
    if (!key)
        return;

    NSMutableDictionary *options = [_optionCategories objectForKey:@(category)];
    if (options) {
        [options setObject:@(value) forKey:key];
    }
}


#pragma mark Common Helper

-(void)setFormatOptionValue:(NSString *)value forKey:(NSString *)key
{
    [self setOptionValue:value forKey:key ofCategory:kIJKFFOptionCategoryFormat];
}

-(void)setCodecOptionValue:(NSString *)value forKey:(NSString *)key
{
    [self setOptionValue:value forKey:key ofCategory:kIJKFFOptionCategoryCodec];
}

-(void)setSwsOptionValue:(NSString *)value forKey:(NSString *)key
{
    [self setOptionValue:value forKey:key ofCategory:kIJKFFOptionCategorySws];
}

-(void)setPlayerOptionValue:(NSString *)value forKey:(NSString *)key
{
    [self setOptionValue:value forKey:key ofCategory:kIJKFFOptionCategoryPlayer];
}

-(void)setFormatOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self setOptionIntValue:value forKey:key ofCategory:kIJKFFOptionCategoryFormat];
}

-(void)setCodecOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self setOptionIntValue:value forKey:key ofCategory:kIJKFFOptionCategoryCodec];
}

-(void)setSwsOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self setOptionIntValue:value forKey:key ofCategory:kIJKFFOptionCategorySws];
}

-(void)setPlayerOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self setOptionIntValue:value forKey:key ofCategory:kIJKFFOptionCategoryPlayer];
}

@end
