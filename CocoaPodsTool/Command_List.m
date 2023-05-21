//
//  Command_List.m
//  CocoaPodsTool
//
//  Created by 吴双 on 2023/5/8.
//

#import "Command_List.h"
#import <PodfileLock/PodfileLock.h>
#import <MUFoundation/MUPath.h>

@implementation Command_List

command_configuration(command) {
    command.name = @"list";
    command.note = @"List all pods.";
}

command_option(BOOL, showVersion, name=@"show-version", shortName='V', note=@"Contains pod version if specialed.")

command_main() {
    MUPath *lockPath = [MUPath pathWithString:@"Podfile.lock"];
    if (!lockPath.isFile) {
        CLError(@"The Podfile.lock file is not exist.");
        return EXIT_FAILURE;
    }
    
    PLLockFile *lockFile = [PLLockFile lockFileWithContentsOfFile:lockPath.string];
    
    NSArray<PLSpecName> *unsortedList = lockFile.targets.allKeys;
    NSArray<PLSpecName> *sortedList = [unsortedList sortedArrayUsingSelector:@selector(compare:)];
    
    for (PLSpecName item in sortedList) {
        PLTarget *target = lockFile.targets[item];
        NSMutableString *line = [NSMutableString stringWithString:item];
        if ([self showVersion] && target.source.specialVersion) {
            [line appendFormat:@" (%@)", target.source.specialVersion];
        }
        CLInfo(@"%@", line);
    }
    
    return EXIT_SUCCESS;
}

@end
