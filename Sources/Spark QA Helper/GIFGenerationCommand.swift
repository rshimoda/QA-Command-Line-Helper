//
//  File.swift
//  
//
//  Created by Sergi on 25/03/2020.
//

import Cocoa
import ImageIO
import CoreServices
import ArgumentParser

struct GIFGeneration: ParsableCommand {

    static var configuration = CommandConfiguration(commandName: "generate-gifs", abstract: "Command to generate GIF images from images produced by failed Email Rendering UI Tests and corresponding reference images.", subcommands: [])

    @Option(name: .shortAndLong, help: "Path at which reference images are stored.")
    private var sourcePath: String?

    @Option(name: .shortAndLong, default: "./GIFs", help: "Path at which generated GIFs should be saved.")
    private var destinationPath: String

    @Option(name: .shortAndLong, default: 0.5, help: "Delay in seconds between swithing from reference image to actual result.")
    private var delayTime: Double

    @Flag(name: .short, help: "Open destination directory on finish.")
    private var openDestinationDirectoryOnFinish: Bool

    @Flag(name: .shortAndLong, help: "Print error logs.")
    private var verbose: Bool

    // MARK: -

    func run() throws {
        let currentDirectoryURL = URL(fileURLWithPath: sourcePath ?? FileManager.default.currentDirectoryPath)
        let gifDestinationFolderURL = URL(fileURLWithPath: destinationPath)

        print("Source path: \(currentDirectoryURL.path)")
        print("Destination path: \(gifDestinationFolderURL.path)")

        try? FileManager.default.removeItem(at: gifDestinationFolderURL)

        do {
            try FileManager.default.createDirectory(at: gifDestinationFolderURL, withIntermediateDirectories: false, attributes: nil)
        }
        catch {
            print("Failed to create destination directory: \(error.localizedDescription)")
        }

        let fileNames: [String] = (try? FileManager.default.contentsOfDirectory(atPath: currentDirectoryURL.path)) ?? []
        let failedTestCaseImageNames: [String] = fileNames.filter({ $0.contains("check") })

        for failedTestCaseImageName in failedTestCaseImageNames {
            let referenceImageName = correspondingReferenceImageName(for: failedTestCaseImageName)

            let referenceImageURL = URL(fileURLWithPath: referenceImageName, isDirectory: false, relativeTo: currentDirectoryURL)
            let failedTestCaseImageURL = URL(fileURLWithPath: failedTestCaseImageName, isDirectory: false, relativeTo: currentDirectoryURL)

            guard let referenceImageData = try? Data(contentsOf: referenceImageURL, options: .mappedIfSafe) else {
                print("Failed to create image data. Reference image: (\(referenceImageName))")
                continue
            }
            guard let failedTestCaseImageData = try? Data(contentsOf: failedTestCaseImageURL, options: .mappedIfSafe) else {
                print("Failed to create image data. Failure image: (\(failedTestCaseImageName))")
                continue
            }

            guard let referenceImage = NSImage(data: referenceImageData) else {
                print("Failed to create NSImage. Reference image: (\(referenceImageName))")
                continue
            }
            guard let failedTestCaseImage = NSImage(data: failedTestCaseImageData) else {
                print("Failed to create NSImage. Failure image: (\(failedTestCaseImageName))")
                continue
            }

            let destinationGIFURL = URL(fileURLWithPath: failedTestCaseImageName, isDirectory: false, relativeTo: gifDestinationFolderURL).deletingPathExtension().appendingPathExtension("gif")

            let _ = gif(from: [referenceImage, failedTestCaseImage], safeAtURL: destinationGIFURL)
        }

        if openDestinationDirectoryOnFinish {
            let openDestinationDirectoryTask = Process()
            openDestinationDirectoryTask.launchPath = "/bin/bash"
            openDestinationDirectoryTask.arguments = ["-c", "open \(destinationPath)"]
            openDestinationDirectoryTask.launch()
        }
    }

    // MARK: -

    func gif(from images: [NSImage], safeAtURL url: URL) {
        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): delayTime]] as CFDictionary

        if let url = url as CFURL? {
            if let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties)

                for image in images {
                    var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

                    guard let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
                        print("Failed to create image ref.")
                        continue
                    }

                    CGImageDestinationAddImage(destination, imageRef, frameProperties)
                }

                if !CGImageDestinationFinalize(destination) {
                    print("Failed to finalize image destination.")
                }
            }
        }
    }

    func correspondingReferenceImageName(for actualImageName: String) -> String {
        return actualImageName.replacingOccurrences(of: "-check", with: "")
    }

    func print(_ text: String) {
        guard verbose else {
            return
        }

        Swift.print(text)
    }
}
