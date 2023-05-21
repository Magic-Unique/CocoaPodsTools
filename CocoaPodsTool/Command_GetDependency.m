//
//  Command_GetDependency.m
//  CocoaPodsTool
//
//  Created by 吴双 on 2023/5/4.
//

#import "Command_GetDependency.h"
#import <PodfileLock/PodfileLock.h>
#import <MUFoundation/MUPath.h>

@implementation Command_GetDependency

command_configuration(command) {
    command.name = @"get-dependency";
    command.note = @"Get pod dependency list.";
}

command_argument(CLString, pod)

command_main() {
    
    MUPath *lockPath = [MUPath pathWithString:@"Podfile.lock"];
    if (!lockPath.isFile) {
        CLError(@"The Podfile.lock file is not exist.");
        return EXIT_FAILURE;
    }
    
    PLLockFile *lockFile = [PLLockFile lockFileWithContentsOfFile:lockPath.string];
    
    PLTarget *target = [lockFile targetForName:pod];
    if (!target) {
        CLError(@"Can not found pod named `%@` in this Podfile.lock", pod);
        return EXIT_FAILURE;
    }
    
    NSArray<PLSpecPath> *unsortedList = target.recursiveDependencies.allObjects;
    NSArray<PLSpecPath> *sortedList = [unsortedList sortedArrayUsingSelector:@selector(compare:)];
    [sortedList enumerateObjectsUsingBlock:^(PLSpecPath  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CLInfo(@"%@", obj);
    }];
    
    return EXIT_SUCCESS;
}

- (MUPath *)findRepoPathByGitURL:(NSString *)gitURL {
    MUPath *root = [MUPath pathWithString:@"~/.cocoapods/repos"];
    for (MUPath *repo in root.directories) {
        
        MUPath *_git = [repo subpathWithComponent:@".git"];
        if (!_git.isDirectory) { continue; }
        
        NSString *url = CLLaunch(repo.string, @"/usr/bin/git", @"remote", @"get-url", @"origin", nil);
        url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        CLVerbose(@"%@: %@", repo.lastPathComponent, url);
        if ([gitURL isEqualToString:url]) {
            return repo;
        }
    }
    
    return nil;
}

@end
