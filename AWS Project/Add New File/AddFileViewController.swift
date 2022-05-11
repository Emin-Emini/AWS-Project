//
//  AddFileViewController.swift
//  AWS Project
//
//  Created by Emin Emini on 03.05.2022..
//

import UIKit
import AVKit
import AVFoundation
import AWSCognito
import AWSS3

class AddFileViewController: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    var contentUrl: URL!
    var s3Url: URL!
    
    var file: String!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupAWSConfiguration()
    }
    
    // MARK: - Actions
    @IBAction func uploadSingle(_ sender: Any) {
        uploadFile(with: "Stanford-University-Logo", type: "png")
    }
    
    @IBAction func uploadFromLibrary(_ sender: Any) {
        showAlbum()
    }
    
    @IBAction func showContent(_ sender: Any) {
        showContent()
    }
    
    @IBAction func deleteContent(_ sender: Any) {
        let fileArr = file.components(separatedBy: ".")
        deleteFile(with: fileArr[0], type: fileArr[1])
    }
}

// MARK: - Select Photo from Library
extension AddFileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showAlbum() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true

        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //print("\(info)")
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
            
            guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempImage.png") else {
                return
            }

            let pngData = image.pngData()
            do {
                try pngData?.write(to: imageURL)
                print(imageURL)
            } catch { }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Configure AWS
extension AddFileViewController {
    func setupAWSConfiguration() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUCentral1,
           identityPoolId:"eu-central-1:279bc153-1080-46a8-9bd1-eff2807579ee")

        let configuration = AWSServiceConfiguration(region:.EUCentral1, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        s3Url = AWSS3.default().configuration.endpoint.url
    }
}

// MARK: - Upload To AWS
extension AddFileViewController {
    func uploadFile(with resource: String, type: String) {
        let key = "\(resource).\(type)"
        file = key
        let localImagePath = Bundle.main.path(forResource: resource, ofType: type)!
        let localImageUrl = URL(fileURLWithPath: localImagePath)
        
        let request = AWSS3TransferManagerUploadRequest()!
        request.bucket = bucketName
        request.key = key
        request.body = localImageUrl
        request.acl = .publicReadWrite
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let error = task.error {
                print(error)
            }
            if task.result != nil {
                print("Uploaded \(key)")
                let contentUrl = self.s3Url.appendingPathComponent(bucketName).appendingPathComponent(key)
                self.contentUrl = contentUrl
            }
            return nil
        }
    }
}

// MARK: - Delete To AWS
extension AddFileViewController {
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
extension AddFileViewController {
    func showContent() {
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
