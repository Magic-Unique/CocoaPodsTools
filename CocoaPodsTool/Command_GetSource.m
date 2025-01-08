//
//  Command_GetSource.m
//  CocoaPodsTool
//
//  Created by 吴双 on 2023/4/21.
//

#import "Command_GetSource.h"
#import <PodfileLock/PodfileLock.h>
#import <MUFoundation/MUPath.h>

@implementation Command_GetSource

command_configuration(command) {
    command.name = @"get-source";
    command.note = @"Get pod source.";
}

command_option(BOOL, url, note=@"Get pod url.");
command_option(BOOL, repo, note=@"Get pod repo name.");
command_option(BOOL, pull, note=@"Pull repo to newest.");
command_option(BOOL, openInFinder, note=@"Open the repo in Finder.");

command_argument(CLString, pod)

command_main() {
    if (![self url] && ![self repo]) {
        CLError(@"You must special one of --url or --repo to make output format.");
        return EXIT_FAILURE;
    }
    
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
    
    if (target.source.type == PLTargetSourceTypeLocalPath) {
        CLInfo(target.source.location);
    }
    else if (target.source.type == PLTargetSourceTypeSpecialGit) {
        CLInfo(target.source.location);
    }
    else if (target.source.type == PLTargetSourceTypeRepo) {
        
        if ([self url]) {
            CLInfo(target.source.location);
        }
        else if ([self repo]) {
            MUPath *repoPath = [self findRepoPathByGitURL:target.source.location];
            if (repoPath) {
                CLInfo(@"%@", repoPath.lastPathComponent);
                if ([self pull]) {
                    CLLaunch(repoPath.string, @"/usr/bin/git", @"pull", nil);
                }
                if ([self openInFinder]) {
                    MUPath *specRoot = [repoPath subpathWithComponent:target.name];
                    CLLaunch(specRoot.string, @"/usr/bin/open", @"-R", @".", nil);
                }
            } else {
                CLError(@"No matched repo.");
                return EXIT_FAILURE;
            }
        }
    }
    
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
