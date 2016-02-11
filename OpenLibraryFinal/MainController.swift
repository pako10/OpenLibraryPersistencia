//
//  MainController.swift
//  OpenLibraryPersistencia
//
//  Created by LFrancisco Humberto Andrade Gonzalez on 7/2/16.
//  Copyright © 2016 Francisco Humberto Andrade Gonzalez. All rights reserved.
//

import UIKit
import CoreData

struct Library {
    var Titulo : String
    var Autores : String
    
    init(titulo:String,autores : String){
        self.Titulo = titulo
        self.Autores = autores
    
    }
}


var ColeccionLibros : [Library] = []


class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var MainTable: UITableView!
    
    var CellIndex : Int?
    let blogSegueIdentifier = "ShowCellSegue"
    var contexto : NSManagedObjectContext? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            self.MainTable.delegate = self
            self.MainTable.dataSource = self
            self.MainTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            self.LoadFromSQLite()
        
        
    }
    @IBAction func AddBook(sender: AnyObject) {
        self.ShowInputISBN()
    }
    
    
    func LoadFromSQLite(){
        if ColeccionLibros.count == 0{
            let Request = NSFetchRequest(entityName: "Libro")
            do{
                let results = try self.contexto!.executeFetchRequest(Request)

                var aux_titulo : String = ""
                var aux_autores : String = ""
                for aux in results{
                    aux_titulo = String(aux.valueForKey("titulo")!)
                    aux_autores = String(aux.valueForKey("autores")!)
                    ColeccionLibros.append(Library(titulo: aux_titulo, autores: aux_autores))
                }
                
            }catch{
            
            }
        }
    }
    func ShowInputISBN(){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "OpenLibrary", message: "Insertar ISBN", preferredStyle: .Alert)
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.GetISBNFromOpenLibrary(textField.text!)
        }))
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func GetISBNFromOpenLibrary(ISBN : String)->(){
        do {
            var urlText = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
            urlText += ISBN
            let url = NSURL(string: urlText)
            let datos = try NSData(contentsOfURL: url!)
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
            
            if ( datos!.length < 3 ){
                
                self.ShowErrorInISBNSearch()
                
                
            }else{
                
                
                var Head = "ISBN:"
                Head += ISBN
                
                let Title : String = json[Head]!["title"] as! String
                
                
                let keys = json[Head]! as! NSDictionary
                let Todosautores = keys["authors"] as! NSArray
                var names : String = " "
                for value in Todosautores{
                    let Autor = value as! NSDictionary
                    let Name = Autor["name"] as! String
                    names += Name
                    names += ","
                    
                }
                
                let Book : Library = Library(titulo: Title, autores: names)
                self.addBookToSystem(Book)
                
            }
            
        }  catch {
            print("json error: \(error)")
        }
        
     

    }
    
    func ShowErrorInISBNSearch(){
        
        let alerta = UIAlertController(title: "Error",
            message: "ISBN no encontrado",
            preferredStyle: UIAlertControllerStyle.Alert)
        let accion = UIAlertAction(title: "Cerrar",
            style: UIAlertActionStyle.Default) { _ in
                alerta.dismissViewControllerAnimated(true, completion: nil)
                
        }
        alerta.addAction(accion)
        self.presentViewController(alerta, animated: true, completion: nil)
        
        
    }
    
    func addBookToSystem(Book:Library){
        print("ADDTOSYSTEM")
        var AlreadyExists : Bool = false
        for Libro in ColeccionLibros{
            if Libro.Titulo == Book.Titulo{
                AlreadyExists = true
            }
        }
        
        if AlreadyExists {
            
        }else{
            print("TRYTOADDTOSQL")
            //ADD TO DATABASE
            let AddLibro = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
            AddLibro.setValue(Book.Titulo, forKey: "titulo")
            AddLibro.setValue(Book.Autores, forKey: "autores")
            do{
                try self.contexto?.save()
            }catch{
                abort()
            }
            //ADD TO SYSTEM
            ColeccionLibros.append(Book)
        }

        self.MainTable.reloadData()
    }
    
//FUNCTIONS OF TABLEVIEW
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ColeccionLibros.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.MainTable.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        cell.textLabel?.text = ColeccionLibros[indexPath.row].Titulo
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        CellIndex = indexPath.row
        performSegueWithIdentifier(blogSegueIdentifier, sender: CellIndex)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == blogSegueIdentifier
        {
            if let destination = segue.destinationViewController as? CellViewController
            {
                let CellIndex = self.MainTable.indexPathForSelectedRow
                destination.titulo = ColeccionLibros[CellIndex!.row].Titulo
                destination.autores = ColeccionLibros[CellIndex!.row].Autores
            }
        }
    }

}


