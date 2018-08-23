//
//  ViewController.swift
//  dicecj-ios-client
//
//  Created on 12.08.18.
//  Copyright © 2018 CJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var commandButtonView: UIView!
    @IBOutlet weak var outputResult: UITextView!
    @IBOutlet weak var outputDice: UITextView!
    @IBOutlet weak var userInput: UITextField!
    let mainURL = "http://localhost:8080/dicecj/resources/"
    var gameID : Int = -1
    let HTTPPOST = "POST"
    let HTTPGET = "GET"
    
    @IBAction func sendCommand(sender: UIButton) {
        let trigger = sender.currentTitle!
        guard let inputData = userInput.text else {
            print("sendCommand: invalid user input")
            return
        }
        let url = URL(string: mainURL + "command")
        let requestData : String = "{\"gameId\": \(gameID),\"userInput\": \"\(trigger):\(inputData)\"}"
        requestResource(resource: url!, requestMethod: HTTPPOST, requestData: requestData) { response in
            self.processDiceCJResponse(response)
        }
    }
    
    func requestResource(resource: URL, requestMethod: String, requestData: String?, callback: @escaping (Data) -> Void) {
        var request = URLRequest(url: resource)
        request.httpMethod = requestMethod
        
        if let requestData = requestData {
            request.httpBody = requestData.data(using: String.Encoding.utf8)
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, URLResponse, error in
            guard let data = data else {
                print("requestResource: no data received")
                return
            }
            callback(data)
            }.resume()
    }
    
    func processDiceCJResponse(_ response: (Data)) {
        DispatchQueue.main.async {
            let jsonObject = try? JSONSerialization.jsonObject(with: response, options: [])
            let jsonResponse = jsonObject as? [String: Any]
            self.gameID = jsonResponse!["gameId"] as! Int
            self.outputResult.text = jsonResponse!["scoreboard"] as! String
            self.outputDice.text = jsonResponse!["result"] as! String
            self.userInput.text = ""
        }
    }
    
    fileprivate func addCommandButtons(commands: [String: Any]?) -> String {
        guard let commands = commands else {
            return "no commands received"
        }
        var x = 10
        var commandOutput = ""
        for (command, trigger) in commands {
            commandOutput += command + "\n"
            self.addButton(label:trigger as! String, x: x, y: 20)
            x += 70
        }
        return commandOutput
    }

    fileprivate func addButton(label: String, x: Int, y: Int) {
        let button = UIButton()
        button.setTitle(label, for: UIControlState.normal)
        button.frame = CGRect(x: x, y: y, width: 60, height: 40);
        button.addTarget(self, action: #selector(sendCommand), for: .touchDown)
        button.backgroundColor = UIColor.black
        commandButtonView.addSubview(button)
    }
    
    fileprivate func initFields(_ initialResponse: Data) {
        let jsonObject = try? JSONSerialization.jsonObject(with: initialResponse, options: [])
        let jsonResponse = jsonObject as? [String: Any]
        let availableCommands = jsonResponse!["availableCommands"] as? [String: Any]
        self.outputResult.text = self.addCommandButtons(commands: availableCommands)
        self.outputDice.text = jsonResponse!["hello"] as! String
        self.userInput.text = "enter data and press button..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let resourceURL = URL(string: mainURL + "command/overview")
        requestResource(resource: resourceURL!, requestMethod: HTTPGET, requestData: nil) { response in
            DispatchQueue.main.async() {
                self.initFields(response)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

