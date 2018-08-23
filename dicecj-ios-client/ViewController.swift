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
    var gameID : Int?
    let HTTPPOST = "POST"
    let HTTPGET = "GET"
    
    @IBAction func sendCommand(_ sender: Any) {
        guard let inputData = userInput.text else {
            print("invalid user input")
            return
        }
        let url = URL(string: mainURL + "command")
        let requestData : String = "{\"gameId\": \(gameID!),\"userInput\": \"\(inputData)\"}"
        requestResource(resource: url!, requestMethod: HTTPPOST, requestData: requestData) { response in
            self.processDiceCJResponse(response)
        }
    }
    
    @IBAction func startGame(_ sender: Any) {
        guard let inputData = userInput.text else {
            print("invalid user input")
            return
        }
        let url = URL(string: mainURL + "command/newgame")
        requestResource(resource: url!, requestMethod: HTTPPOST, requestData: inputData) { response in
            self.processDiceCJResponse(response)
        }
    }
    
    @IBAction func sayHello(_ sender: Any) {
        guard let inputData = userInput.text else {
            print("invalid user input")
            return
        }
        let url = URL(string: mainURL + "hello")
        requestResource(resource: url!, requestMethod: HTTPPOST, requestData: inputData) { response in
            DispatchQueue.main.async() {
            let responseString = NSString(data: response, encoding: String.Encoding.utf8.rawValue)
            self.outputResult.text = responseString!.substring(from: 0)
            }
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
                print("no data received")
                return
            }
            callback(data)
            }.resume()
    }
    
    func processDiceCJResponse(_ response: (Data)) {
        DispatchQueue.main.async {
            let jsonObject = try? JSONSerialization.jsonObject(with: response, options: [])
            let jsonResponse = jsonObject as? [String: Any]
            print(jsonResponse as Any)
            self.gameID = jsonResponse!["gameId"] as? Int
            self.outputResult.text = jsonResponse!["scoreboard"] as! String
            self.outputDice.text = jsonResponse!["result"] as! String
            self.userInput.text = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let resourceURL = URL(string: mainURL + "command/overview")
        requestResource(resource: resourceURL!, requestMethod: HTTPGET, requestData: nil) { response in
            DispatchQueue.main.async() {
                let responseString = NSString(data: response, encoding: String.Encoding.utf8.rawValue)
                self.outputResult.text = responseString!.substring(from: 0)
            }
        }

        let button = UIButton()
        button.setTitle("TEST", for: UIControlState.normal)
        button.frame = CGRect(x: 60, y: 60, width: 50, height: 30);
        commandButtonView.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

