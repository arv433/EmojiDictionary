//
//  File.swift
//  EmojiDictionary
//
//  Created by Arvin Zojaji on 2018-11-18.
//  Copyright © 2018 Arvin Zojaji. All rights reserved.
//

import UIKit

class Emoji: Codable {
    var symbol: String
    var name: String
    var description: String
    var usage: String
    
    init(symbol: String, name: String, description: String, usage: String) {
        self.symbol = symbol
        self.name = name
        self.description = description
        self.usage = usage
    }
    
    static func saveToFile(emojis: [[Emoji]]) {
        let pListEncoder = PropertyListEncoder()
        if let encodedEmojis = try? pListEncoder.encode(emojis) {
            if let _ = try? encodedEmojis.write(to: self.ArchiveURL, options: .noFileProtection) {
                print("emojis saved")
            }
        }
    }
    
    static func loadFromFile() -> [[Emoji]]? {
        let pListDecoder = PropertyListDecoder()
        if let retrievedEmojiData = try? Data(contentsOf: self.ArchiveURL) {
            if let decodedEmojis = try? pListDecoder.decode(Array<Array<Emoji>>.self, from: retrievedEmojiData) {
                print("emojis loaded from memory")
                return decodedEmojis
            }
        }
        return nil
    }
    
    static let ArchiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("emojis").appendingPathExtension("plist")
    
    static func loadSampleEmojis() -> [[Emoji]] {
        let emojis: [[Emoji]] = [
            [
                Emoji(symbol: "😀", name: "Grinning Face", description: "A typical smiley face.", usage: "happiness"),
                Emoji(symbol: "😕", name: "Confused Face", description: "A confused, puzzled face.", usage: "unsure what to think; displeasure"),
                Emoji(symbol: "😍", name: "Heart Eyes", description: "A smiley face with hearts for eyes.", usage: "love of something; attractive"),
                Emoji(symbol: "👮", name: "Police Officer", description: "A police officer wearing a gold badge.", usage: "person of authority"),
                Emoji(symbol: "🤠", name: "Cowboy", description: "A smiley face wearing a cowboy hat.", usage: "Western"),
                Emoji(symbol: "🥴", name: "Woozy Face", description: "An aswoon look on a face.", usage: "drunkenness, dizziness"),
                Emoji(symbol: "🎃", name: "Jack-O-Lantern", description: "A pumpkin carved with a spooky face.", usage: "spookiness, fright; Halloween")
            ], [
                Emoji(symbol: "🐢", name: "Turtle", description: "A cute turtle.", usage: "Something slow"),
                Emoji(symbol: "🐘", name: "Elephant", description: "A gray elephant.", usage: "good memory")
            ], [
                Emoji(symbol: "🍝", name: "Spaghetti", description: "A plate of spaghetti.", usage: "spaghetti")
            ], [
                Emoji(symbol: "🎲", name: "Die", description: "A single die.", usage: "taking a risk, chance; game")
            ], [
                Emoji(symbol: "⛺️", name: "Tent", description: "A small tent.", usage: "camping")
            ], [
                Emoji(symbol: "📚", name: "Stack of Books", description: "Three colored books stacked on each other.", usage: "homework, studying")
            ], [
                Emoji(symbol: "💔", name: "Broken Heart", description: "A red, broken heart", usage: "Extreme sadness"),
                Emoji(symbol: "💤", name: "Snore", description: "Three blue \'Z\'s", usage: "tired, sleepiness")
            ], [
                Emoji(symbol: "🏁", name: "Checkered Flag", description: "A black-and-white checkered flag.", usage: "completion")
            ]
        ]
        print("loading sample emojis")
        return emojis
    }
}

extension UnicodeScalar {
    
    var isEmoji: Bool {
        
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF,   // Misc symbols
        0x2700...0x27BF,   // Dingbats
        0xFE00...0xFE0F,   // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
        127000...127600, // Various asian characters
        65024...65039, // Variation selector
        9100...9300, // Misc items
        8400...8447: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        
        return value == 8205
    }
}

extension String {
    
    var glyphCount: Int {
        
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        return CTLineGetGlyphCount(line)
    }
    
    var isSingleEmoji: Bool {
        
        return glyphCount == 1 && containsEmoji
    }
    
    var containsEmoji: Bool {
        
        return unicodeScalars.contains { $0.isEmoji }
    }
    
    var containsOnlyEmoji: Bool {
        
        return !isEmpty
            && !unicodeScalars.contains(where: {
                !$0.isEmoji
                    && !$0.isZeroWidthJoiner
            })
    }
    
    // The next tricks are mostly to demonstrate how tricky it can be to determine emoji's
    // If anyone has suggestions how to improve this, please let me know
    var emojiString: String {
        
        return emojiScalars.map { String($0) }.reduce("", +)
    }
    
    var emojis: [String] {
        
        var scalars: [[UnicodeScalar]] = []
        var currentScalarSet: [UnicodeScalar] = []
        var previousScalar: UnicodeScalar?
        
        for scalar in emojiScalars {
            
            if let prev = previousScalar, !prev.isZeroWidthJoiner && !scalar.isZeroWidthJoiner {
                
                scalars.append(currentScalarSet)
                currentScalarSet = []
            }
            currentScalarSet.append(scalar)
            
            previousScalar = scalar
        }
        
        scalars.append(currentScalarSet)
        
        return scalars.map { $0.map{ String($0) } .reduce("", +) }
    }
    
    fileprivate var emojiScalars: [UnicodeScalar] {
        
        var chars: [UnicodeScalar] = []
        var previous: UnicodeScalar?
        for cur in unicodeScalars {
            
            if let previous = previous, previous.isZeroWidthJoiner && cur.isEmoji {
                chars.append(previous)
                chars.append(cur)
                
            } else if cur.isEmoji {
                chars.append(cur)
            }
            
            previous = cur
        }
        
        return chars
    }
}
