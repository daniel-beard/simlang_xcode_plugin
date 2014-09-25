//
//  simlang_xcode_plugin.m
//  simlang_xcode_plugin
//
//  Created by Daniel Beard on 9/24/14.
//    Copyright (c) 2014 DanielBeard. All rights reserved.
//

#import "simlang_xcode_plugin.h"

static simlang_xcode_plugin *sharedPlugin;

@interface simlang_xcode_plugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) NSMutableArray *languageCodes;

@end

@implementation simlang_xcode_plugin

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        self.languageCodes = [NSMutableArray array];
        
        // Create menu items, initialize UI, etc.
        [self setupMenus];
    }
    return self;
}

- (void)setupMenus {
    
    // Create top level menuitem
    NSMenuItem *topMenuItem = [[NSMenuItem alloc] initWithTitle:@"Simulator" action:nil keyEquivalent:@""];
    
    // Create Sub Menu
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"Simulator"];
    
    // Load languages file
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"Languages" ofType:@"plist"];
    NSArray *languages = [NSArray arrayWithContentsOfFile:path];
    
    for (NSInteger i = 0; i< languages.count; i++) {
        NSString *languageTitle = languages[i][@"title"];
        NSString *languageCode = languages[i][@"code"];
        if (languageTitle) {
            [self addMenuWithTitle:languageTitle toMenu:subMenu tag:i action:@selector(menuAction:)];
            [self.languageCodes addObject:languageCode];
        }
    }
    
    // Set the topMenuItem's submenu
    topMenuItem.submenu = subMenu;
    
    // Add topMenuItem to the main menu
    NSInteger index = [NSApp mainMenu].numberOfItems - 2;
    [[NSApp mainMenu] insertItem:topMenuItem atIndex:index];
}

- (void)addMenuWithTitle:(NSString *)title toMenu:(NSMenu *)menu tag:(NSInteger)tag action:(SEL)action {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
    [item setTarget:self];
    item.tag = tag;
    [menu addItem:item];
}

- (void)menuAction:(NSMenuItem *)sender {
    if (sender.tag < self.languageCodes.count) {
        NSString *languageCode = self.languageCodes[sender.tag];
        [self changeLanguageWithCode:languageCode];
    }
}

- (void)changeLanguageWithCode:(NSString *)languageCode {
    NSTask *task = [[NSTask alloc] init];
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simlang" ofType:@"swift"];
    task.launchPath = path;
    task.arguments = @[languageCode];
    [task launch];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
