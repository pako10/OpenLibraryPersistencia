//
//  ViewController.swift
//  OpenLibraryPersistencia
//
//  Created by Francisco Humberto Andrade Gonzalez on 7/2/16.
//  Copyright © 2016 Francisco Humberto Andrade Gonzalez. All rights reserved.
//

import UIKit

class CellViewController: UIViewController {
    
    
    @IBOutlet weak var Label_Autores: UILabel!
    @IBOutlet weak var Label_Titulo: UILabel!
    
    var titulo : String!  = String()
    var autores : String! = String()
    
    override func viewWillAppear(animated: Bool) {
        Label_Titulo.text = titulo
        Label_Autores.text = autores
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func GoBack(sender: AnyObject) {
        performSegueWithIdentifier("GoBack", sender: sender )
    }
}