//
//  CountdownView.swift
//  QuoteSaver
//
//  Created by Rrapaj on 12.09.19.
//  Copyright © 2019 Rrapaj. All rights reserved.
//

import Foundation
import ScreenSaver

final class QuoteView: ScreenSaverView {
    
    @IBOutlet var contentView: NSView!
    @IBOutlet var quoteLabel: NSTextFieldCell!
    @IBOutlet var authorLabel: NSTextFieldCell!



    // MARK: - Properties
    
    private struct quote {
        var Quote: String = "";
        var Character: String = "";
        var Source: String = "";
    };
    
    private var quotes: [quote] = [];
    
    private var throwbackQuote: quote = quote(Quote: "The stupid code is not working",
                                       Character: "Arbër",
                                       Source: "Real Life")
    
    private var loaded = false
    

    // MARK: - Initializers
    
    convenience init() {
        self.init(frame: .zero, isPreview: false)
    }
    
    override init!(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - NSView
    
    override func draw(_ rect: NSRect) {
        NSColor.black.setFill()
        NSBezierPath.fill(bounds)
    }
    
    // If the screen saver changes size, update the font
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
    }
    
    
    // MARK: - ScreenSaverView
    
    override func animateOneFrame() {
        let randomQuote: quote = quotes.randomElement() ?? throwbackQuote
        
        quoteLabel.stringValue = randomQuote.Quote
        authorLabel.stringValue = "- " + randomQuote.Character

        if (!loaded) {
            addSubview(contentView)
            addConstraints([
                contentView.widthAnchor.constraint(equalToConstant: 1680),
                contentView.heightAnchor.constraint(equalToConstant: 1050),
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
            loaded = true;
        }
    }
    
    override var hasConfigureSheet: Bool {
        return false
    }
    
    override var configureSheet: NSWindow? {
        return nil
    }
    
    
    // MARK: - Private
    
    /// Shared initializer
    private func initialize() {
        // Set animation time interval
        animationTimeInterval = 60 * 5
        
        // Fetch the file
        let csvFile = FileManager.default.contents(atPath: "/Users/rrapaj/Documents/QuoteSaver/Quotes-List.csv")

        if (csvFile != nil)
        {
            // Feed rows into array
            let dataEncoded = String(data: csvFile!, encoding: .utf8)
            let dataArr = dataEncoded?.components(separatedBy: "\r\n").dropFirst()

            for var line in dataArr!
            {
                var quoteText: String
                var quoteElement: [String]

                let match = line.range(of: "\"(.)+\"", options: .regularExpression)
                if (match != nil) {
                    quoteText = String(line[match!])
                    line = String(line.suffix(from: match!.upperBound))
                    quoteElement = line.components(separatedBy: ",")
                } else {
                    quoteElement = line.components(separatedBy: ",")
                    quoteText = quoteElement[0]
                }

                quotes.append( quote(Quote: quoteText, Character: quoteElement[1], Source: quoteElement[2]))
            }
        } else { throwbackQuote.Quote = "Can't locate the quote-file :(" }

        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String("QuoteView")), bundle: bundle)!
        nib.instantiate(withOwner: self, topLevelObjects: nil)
        
        
        /*
        let randomQuote: quote = quotes.randomElement() ?? throwbackQuote
        
        quoteLabel.stringValue = randomQuote.Quote
        authorLabel.stringValue = "- " + randomQuote.Character
        */
    }
    
    private func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ";")
            result.append(columns)
        }
        return result
    }
}
