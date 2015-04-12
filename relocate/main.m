//
//  main.m
//  relocate
//
//  Created by mtjddnr on 2015. 4. 12..
//  Copyright (c) 2015년 smoon.kr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunesConnection.h"

#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) return 0;
        
        NSString *from = [NSString stringWithUTF8String:argv[1]];
        NSString *to = [NSString stringWithUTF8String:argv[2]];
        NSLog(@"Change all path under %@ to %@", from, to);
        
        iTunesConnection *iTunes = [[iTunesConnection alloc] init];
        printf("%s\n", [[NSString stringWithFormat:@"%@", @""] UTF8String]);
        NSLog(@"load from iTunes");
        [iTunes loadiTunesTracks];
        NSLog(@"\t%li tracks found", (long)[iTunes iTunesTrackCount]);
        
        NSLog(@"load from iTunes Music Library.xml");
        [iTunes loadLibraryFile];
        NSLog(@"\t%li tracks found", (long)[iTunes libTrackCount]);
        
        [iTunes.iTunesTracks enumerateObjectsUsingBlock:^(iTunesFileTrack *track, NSUInteger idx, BOOL *stop) {
            NSString *path = [track.location absoluteString];
            if (path == nil) {
                NSDictionary *item = iTunes.libTracksById[track.persistentID];
                if (item != nil) {
                    path = item[@"Location"];
                }
            }
            if (path == nil) return;
            
            NSURL *f = [NSURL URLWithString:path];
            NSString *p = [f path];
            NSRange range = [p rangeOfString:from];
            if (range.location == 0) {
                NSString *newPath = [to stringByAppendingPathComponent:[p substringFromIndex:range.length]];
                NSLog(@"%@", p);
                NSLog(@"→ %@", newPath);
             
                track.location = [NSURL fileURLWithPath:newPath];
                
            }
        }];
        
        NSLog(@"Done");
    }
    return 0;
}
