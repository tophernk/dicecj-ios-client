//
//  ViewController.swift
//  dicecj-ios-client
//
//  Created on 12.08.18.
//  Copyright © 2018 CJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var outputResult: UITextView!
    @IBOutlet weak var outputDice: UITextView!
    @IBOutlet weak var userInput: UITextField!
    

    @IBAction func sendCommand(_ sender: Any) {
        let url = URL(string: "http://localhost:8080/dicecj/resources/hello")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        guard let requestData = userInput.text else {
            print("invalid user input")
            return
        }
        request.httpBody = requestData.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, URLResponse, error in
            guard let data = data else {
                print("no data received")
                return
            }
            let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            
            DispatchQueue.main.async() {
                self.outputResult.text = response!.substring(from: 0)
            }
        }.resume()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension URLRequest {
    static func allowsAnyHTTPSCertificateForHost(host: String) -> Bool {
        return true
    }
}

