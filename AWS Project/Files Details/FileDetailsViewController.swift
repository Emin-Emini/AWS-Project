//
//  FileDetailsViewController.swift
//  AWS Project
//
//  Created by Emin Emini on 11.05.2022..
//

import UIKit
import AVKit
import AVFoundation
import AWSCognito
import AWSS3

class FileDetailsViewController: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    // MARK: - Properties
    var contentUrl: URL!
    var s3Url: URL!
    
    var file: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupAWSConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fileNameLabel.text = file
        showContent()
    }
    
    @IBAction func saveContent(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, nil, nil, nil)
    }
    
    @IBAction func deleteContent(_ sender: Any) {
        let fileArr = file.components(separatedBy: ".")
        deleteFile(with: fileArr[0], type: fileArr[1])
    }

}

// MARK: - Configure AWS
extension FileDetailsViewController {
    func setupAWSConfiguration() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUCentral1,
           identityPoolId:"eu-central-1:279bc153-1080-46a8-9bd1-eff2807579ee")

        let configuration = AWSServiceConfiguration(region:.EUCentral1, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        s3Url = AWSS3.default().configuration.endpoint.url
    }
}

// MARK: - Delete To AWS
extension FileDetailsViewController {
    func deleteFile(with resource: String, type: String) {
        let key = "\(resource).\(type)"
        let localImagePath = Bundle.main.path(forResource: resource, ofType: type)!
        let localImageUrl = URL(fileURLWithPath: localImagePath)
        
        let request = AWSS3DeleteObjectRequest()!
        request.bucket = bucketName
        request.key = key
        
        let s3Service = AWSS3.default()
        let deleteObjectRequest = AWSS3DeleteObjectRequest()!
        deleteObjectRequest.bucket = bucketName
        deleteObjectRequest.key = key
        
        s3Service.deleteObject(deleteObjectRequest).continueWith { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            print("Bucket deleted successfully.")
            return nil
        }

    }
}

// MARK: - Load Content
extension FileDetailsViewController {
    func showContent() {
        let contentUrl = self.s3Url.appendingPathComponent(bucketName).appendingPathComponent(file)
        self.contentUrl = contentUrl
        
        guard contentUrl != nil else {
            print("There is nothing to show.")
            return
        }
        if contentUrl.path.contains("mov") {
            let player = AVPlayer(url: contentUrl)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true, completion: nil)
        } else {
            do {
                let data = try Data(contentsOf: contentUrl)
                imageView.image = UIImage(data: data)
            } catch {}
        }
    }
}
