//
//  ViewController.swift
//  QJColorChooser
//
//  Created by Mike Manzo on 11/24/19.
//  Copyright © 2019 Mike Manzo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, QJColorButtonDelegate {
    
    @IBOutlet weak var colorPicker1: QJColorChooser!
    @IBOutlet weak var colorPicker2: QJColorChooser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Row x Column array representing the colors the user can select from our color popover in the QJColorChooser.
        colorPicker2.colors = [
            [ NSColor.white, NSColor.black, NSColor.red, NSColor.darkGray ],
            [ NSColor.green, NSColor.purple, NSColor.orange, NSColor.lightGray ]
        ]
        
        colorPicker1.boxWidth = 30
        colorPicker1.borderRadius = 1
        colorPicker1.boxBorderColor = NSColor.black
        colorPicker1.selectedBoxColor = NSColor.white
        colorPicker1.darkMode = true
        colorPicker1.selectedMenuItemColor = NSColor.white
        colorPicker1.selectedMenuItemTextColor = NSColor.black
        
        colorPicker2.color = NSColor.red
        colorPicker2.image = NSImage(named: NSImage.colorPanelName)
        // Set this to true if you're using a template image.
        //colorPicker2.imageIsTemplate = true
        
        // Set the delegates
        colorPicker1.delegate = self
        colorPicker2.delegate = self
    }
    
    /// Sent from our JXColorButtons
    func colorSelected(_ sender: QJColorChooser, color: NSColor) {
        if sender === colorPicker1 {
            Swift.print("Color from picker 1: " + String(describing: color))
        } else if sender === colorPicker2 {
            Swift.print("Color from picker 2: " + String(describing: color))
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

