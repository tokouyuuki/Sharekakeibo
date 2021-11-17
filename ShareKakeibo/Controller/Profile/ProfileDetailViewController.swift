//
//  ProfileDetailViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import SDWebImage
import CropViewController
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ProfileDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate,SendOKDelegate,EditOKDelegate{

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = ["名前","メールアドレス","パスワード"]
    var dataNameArray = ["userName","email","password"]
    var userInfoArray = [String]()
    var sendString = String()
    var sendData = String()
    var userID = String()
    
    var alertModel = AlertModel()
    var sendDBModel = SendDBModel()
    var editDBModel = EditDBModel()
    var db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.layer.cornerRadius = 120
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() //空白のセルの線を消してるよ
        
        editDBModel.editOKDelegate = self
        
        userID = UserDefaults.standard.object(forKey: "userID") as! String

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfoArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let loadLabel = cell.contentView.viewWithTag(2) as! UILabel
        let imageView = cell.contentView.viewWithTag(3) as! UIImageView
        
        nameLabel.text = nameArray[indexPath.row]
        loadLabel.text = userInfoArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendString = nameArray[indexPath.row]
        sendData = dataNameArray[indexPath.row]
        alertModel.passWordAlert(viewController: self, passWord: userInfoArray[2])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let ProfileConfigurationVC = segue.destination as! ProfileConfigurationViewController
        ProfileConfigurationVC.receiveTitle = sendString
        ProfileConfigurationVC.receiveDataName = sendData
        ProfileConfigurationVC.userID = userID
    }

    @IBAction func profileImageView(_ sender: UITapGestureRecognizer) {
        alertModel.satsueiAlert(viewController: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[.originalImage] as? UIImage != nil{
            let pickerImage = info[.originalImage] as! UIImage
            let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
        
            cropController.delegate = self
            cropController.customAspectRatio = profileImageView.frame.size
            //cropBoxのサイズを固定する。
            cropController.cropView.cropBoxResizeEnabled = false
            //pickerを閉じたら、cropControllerを表示する。
            picker.dismiss(animated: true) {
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        //トリミング編集が終えたら、呼び出される。
        self.profileImageView.image = image
        let data = image.jpegData(compressionQuality: 1.0)
        sendDBModel.sendProfileImage(data: data!)
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    //変更
    func sendImage_OK(url: String) {
        db.collection("userManagement").document(userID).updateData(["profileImage" : url])
    }
    
    func editProfileImageChange_OK() {
        
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}