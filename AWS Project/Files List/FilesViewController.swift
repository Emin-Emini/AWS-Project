//
//  FilesViewController.swift
//  AWS Project
//
//  Created by Emin Emini on 11.05.2022..
//

import UIKit
import AVFoundation
import AWSCognito
import AWSS3

class FilesViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var awsObjectsTableView: UITableView!
    
    // MARK: - Properties
    //var contentUrl: URL!
    var s3Url: URL!
    var s3: AWSS3!
    var listOfObjects: [String] = []
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpRefreshAction()
        setupAWSConfiguration()
        loadAWSBucketObjects()
    }

}

// MARK: - Configure AWS
extension FilesViewController {
    func setupAWSConfiguration() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUCentral1,
           identityPoolId:"eu-central-1:279bc153-1080-46a8-9bd1-eff2807579ee")

        let configuration = AWSServiceConfiguration(region:.EUCentral1, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        s3Url = AWSS3.default().configuration.endpoint.url
        s3 = AWSS3.default()
    }
}

// MARK: - Load AWS Bucket Objects
extension FilesViewController {
    func loadAWSBucketObjects() {
        if let listObjectsRequest = AWSS3ListObjectsRequest(){
            listObjectsRequest.bucket = bucketName
            //listObjectsRequest.prefix = "example/folder/"
            
            s3.listObjects(listObjectsRequest).continueWith { (task) -> AnyObject? in
                
                if ((task.result?.contents?.isEmpty) != nil) {
                    self.listOfObjects.removeAll()
                    for object in (task.result?.contents) ?? [] {
                        print("Object key = \(object.key!)")
                        self.listOfObjects.append(object.key!)
                    }
                    DispatchQueue.main.async {
                        self.awsObjectsTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    print("There is nothing in the bucket")
                }
                
                
                return nil
            }
        }
    }
}

// MARK: - Refresh Functions
extension FilesViewController {
    func setUpRefreshAction() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        awsObjectsTableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        loadAWSBucketObjects()
    }
}

//MARK: - Table View
extension FilesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! FileTableViewCell
        
        let fileName = listOfObjects[indexPath.row]
        
        cell.fileName.text = fileName
        
        let contentUrl = self.s3Url.appendingPathComponent(bucketName).appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: contentUrl)
            cell.fileImage.image = UIImage(data: data)
        } catch {}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let fileName = listOfObjects[indexPath.row]
//
//        let feedPost = apiController.feedList[indexPath.row]
        let fileVC: FileDetailsViewController =
            self.storyboard!.instantiateViewController(withIdentifier: "FileDetailsViewController") as! FileDetailsViewController
        fileVC.file = fileName

        self.present(fileVC, animated: true, completion: nil)
    }
}
