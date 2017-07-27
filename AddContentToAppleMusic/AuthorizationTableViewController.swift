//
//  AuthorizationTableViewController.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/27.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import UIKit
import StoreKit
import MediaPlayer

@objc
class AuthorizationTableViewController: UITableViewController {
    
    var authorizationManager: AuthorizationManager!
    
    var authorizationDataSource: AuthorizationDataSource!
    
    var didPresentCloudServiceSetup = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorizationDataSource = AuthorizationDataSource(authorizationManager: authorizationManager)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerDidUpdateNotification),
                                       name: AuthorizationManager.cloudServiceDidUpdateNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerDidUpdateNotification),
                                       name: AuthorizationManager.authorizationDidUpdateNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerDidUpdateNotification),
                                       name: .UIApplicationWillEnterForeground,
                                       object: nil)
        
        setAuthorizationRequestButtonState()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setAuthorizationRequestButtonState()
    }
    
    deinit {
        // Remove all notification observers.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self,
                                          name: AuthorizationManager.cloudServiceDidUpdateNotification,
                                          object: nil)
        notificationCenter.removeObserver(self,
                                          name: AuthorizationManager.authorizationDidUpdateNotification,
                                          object: nil)
        notificationCenter.removeObserver(self,
                                          name: .UIApplicationWillEnterForeground,
                                          object: nil)
    }

    func setAuthorizationRequestButtonState() {
        if SKCloudServiceController.authorizationStatus() == .notDetermined || MPMediaLibrary.authorizationStatus() == .notDetermined {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @IBAction func requestAuthorization(_ sender: UIBarButtonItem) {
        
        authorizationManager.requestCloudServiceAuthorization()
        
        authorizationManager.requestMediaLibraryAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return authorizationDataSource.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return authorizationDataSource.numberOfItems(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorizationCellIdentifier", for: indexPath)
        
        cell.textLabel?.text = authorizationDataSource.stringForItem(at: indexPath)
        
        return cell
    }
    
    func presentCloudServiceSetup() {
        
        guard didPresentCloudServiceSetup == false else {
            return
        }
        
        let cloudServiceSetupViewController = SKCloudServiceSetupViewController()
        cloudServiceSetupViewController.delegate = self
        
        cloudServiceSetupViewController.load(options: [.action: SKCloudServiceSetupAction.subscribe]) { [weak self] (result, error) in
            guard error == nil else {
                fatalError("An Error occurred: \(error!.localizedDescription)")
            }
            
            if result {
                self?.present(cloudServiceSetupViewController, animated: true, completion: nil)
                self?.didPresentCloudServiceSetup = true
            }
        }
    }
    
    func handleAuthorizationManagerDidUpdateNotification() {
        DispatchQueue.main.async {
            if SKCloudServiceController.authorizationStatus() == .notDetermined || MPMediaLibrary.authorizationStatus() == .notDetermined {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                
                if self.authorizationManager.cloudServiceCapabilities.contains(.musicCatalogSubscriptionEligible) &&
                    !self.authorizationManager.cloudServiceCapabilities.contains(.musicCatalogPlayback) {
                    self.presentCloudServiceSetup()
                }
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AuthorizationTableViewController: SKCloudServiceSetupViewControllerDelegate {
    func cloudServiceSetupViewControllerDidDismiss(_ cloudServiceSetupViewController: SKCloudServiceSetupViewController) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
