#!/usr/bin/env xcrun swift
//
//  main.swift
//  simlang_swift
//
//  Created by Daniel Beard on 9/22/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//
//    The MIT License (MIT)
//
//    Copyright (c) 2014 Daniel Beard
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation

func printUsage() {
    println("simlang_swift v1.0")
    println("Author: Daniel Beard")
    println("Usage:")
    println()
    println("simlang {languageCode}")
    println("simlang es-MX")
    println("simlang ru")
}

func runTask(launchPath: String, arguments: Array<String>, printOutput: Bool) {
    let task = NSTask()
    task.launchPath = launchPath
    task.arguments = arguments
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
    if printOutput {
        println(output)
    }
}

func changeLanguageFor(fileAtPath: String, languageCode: String) {
    
    let plistBuddyPath = "/usr/libexec/PlistBuddy"
    if NSFileManager.defaultManager().fileExistsAtPath(plistBuddyPath) {
        
        // Delete existing AppleLanguages
        runTask(plistBuddyPath, [fileAtPath, "-c", "Delete :AppleLanguages"], false)
        
        // Set new language code
        runTask(plistBuddyPath, [fileAtPath, "-c", "Add :AppleLanguages array", "-c", "Add :AppleLanguages:0 string '\(languageCode)'"], false)

        
    } else {
        println("Plist buddy does not exist at \(plistBuddyPath), aborting")
        exit(1)
    }
}

func enumerateSimulatorFoldersAndChangeLanguage(languageCode:String) {
    var devicesPath = "~/Library/Developer/CoreSimulator/Devices".stringByExpandingTildeInPath
    var isDir: ObjCBool = false
    
    // File exists at the right path
    if NSFileManager.defaultManager().fileExistsAtPath(devicesPath, isDirectory: &isDir) {
        // We are a directory
        if isDir {
            // Enumarate and find all the .GlobalPreferences.plist files
            var directoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(devicesPath)
            while let file: AnyObject = directoryEnumerator?.nextObject() {
                let filePath: String = file as String
                
                if file.lastPathComponent == ".GlobalPreferences.plist" {
                    // Set language code
                    changeLanguageFor(devicesPath.stringByAppendingPathComponent(filePath), languageCode)
                }
            }
            
        } else {
            println("Simulator folder does not exist!")
            exit(1)
        }
    } else {
        println("Simulator folder does not exist!")
        exit(1)
    }
}

//MARK: Script entry point

func main() {

    if Process.arguments.count != 2 {
        printUsage()
        exit(1)
    }

    let languageCode = Process.arguments[1]
    enumerateSimulatorFoldersAndChangeLanguage(languageCode)
}
main()


