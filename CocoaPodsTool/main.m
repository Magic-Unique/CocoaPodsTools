//
//  main.m
//  CocoaPodsTool
//
//  Created by 吴双 on 2023/4/21.
//

#import <Foundation/Foundation.h>
#import <CommandLine/CommandLine.h>
#import "Command_GetSource.h"
#import "Command_GetDependency.h"
#import "Command_List.h"

CLCommandEntry(command) {
    command.note = @"CocoaPods external tools";
    command.subcommands = @[[Command_List class], [Command_GetSource class], [Command_GetDependency class]];
}
