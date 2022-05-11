//
//  ViewController.swift
//  AWS Project
//
//  Created by Emin Emini on 03.05.2022..
//

import UIKit
import AWSCognito
import AWSS3

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupAWSConfiguration()
    }
    
    
}

// MARK: - Configure AWS
extension ViewController {
    func setupAWSConfiguration() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUCentral1,
           identityPoolId:"eu-central-1:279bc153-1080-46a8-9bd1-eff2807579ee")

        let configuration = AWSServiceConfiguration(region:.EUCentral1, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}

// MARK: - Upload To AWS
extension ViewController {
    func uploadFile(with resource: String, type: String) {
        let key = "\(resource).\(type)"
    }
}
