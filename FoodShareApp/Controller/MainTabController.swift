//
//  MainTabController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/01.
//

import UIKit
import Firebase
import YPImagePicker

class MainTabController:UITabBarController{
    //MARK: -プロパティー
    var user:User?{
        didSet{
            guard let user = user else {return}
            configureViewController(withUser: user)
        }
    }

    //MARK: -ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        fetchUser()
    }
    
    //MARK: -API
    
    func fetchUser(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserService.fetchUser(withUid: uid) { user in
            self.user = user
            self.navigationItem.title = user.username
        }
    }
    
    //ログインしていない場合はログイン画面へ
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser == nil{
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self//⑤delegate場所(AuthenticationDelegate:authnticationDidComplete)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: -ヘルパー
    func configureViewController(withUser user:User){
        
        view.backgroundColor = .white
        UITabBar.appearance().barTintColor = .black
        
        self.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        let feed = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "food_unselected"), selectedImage: #imageLiteral(resourceName: "food_selected"), rootViewController: FeedController(collectionViewLayout: layout))
        
        let search = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "探す_unselected"), selectedImage: #imageLiteral(resourceName: "探す_unselected"), rootViewController: SearchController())
        
        let imageSelector = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "plus"), selectedImage: #imageLiteral(resourceName: "plus"), rootViewController: ImageSelectorController())
        
        let notification = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "banana"), selectedImage: #imageLiteral(resourceName: "banana"), rootViewController: NotificationController())
        
        let profileController = ProfileController(user: user)
        let profile = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "人"), selectedImage: #imageLiteral(resourceName: "人"),
                                                   rootViewController: profileController)
        
        viewControllers = [feed,search,imageSelector,notification,profile]
        
        tabBar.tintColor = .orange
        tabBar.barTintColor = .black
    }
    
    func templateNavigationController(unselectedImage:UIImage,selectedImage:UIImage,rootViewController:UIViewController)->UINavigationController{
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .white
        nav.navigationBar.barTintColor = .orange
        return nav
    }
    
    func didFinishPickingMedia(_ picker:YPImagePicker){
        picker.didFinishPicking { items, _ in
            picker.dismiss(animated: false) {
                guard let selectedImage = items.singlePhoto?.image else {return}
                
                let controller = UploadPostController()
                controller.selectedImage = selectedImage
                controller.delegate = self
                controller.currentUser = self.user
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                nav.navigationBar.tintColor = .white
                nav.navigationBar.barTintColor = .orange
                self.present(nav, animated: false, completion: nil)
            }
        }
    }
}
//MARK: -AuthenticationDelegate
extension MainTabController:AuthenticationDelegate{
    //④委任された処理(AuthenticationDelegate:authnticationDidComplete)
    func authnticationDidComplete() {
        fetchUser()
        self.dismiss(animated: true, completion: nil)

    }
}

//MARK: -UITabBarControllerDelegate
extension MainTabController:UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2{
            var config = YPImagePickerConfiguration()
            config.library.mediaType = .photo
            config.shouldSaveNewPicturesToAlbum = false
            config.startOnScreen = .library
            config.screens = [.library]
            config.hidesStatusBar = false
            config.hidesBottomBar = false
            config.library.maxNumberOfItems = 1
            
            
            let picker = YPImagePicker(configuration: config)
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
            
            didFinishPickingMedia(picker)
        }
        
        return true
    }
}
//MARK: -UploadPostControllerDelegate
extension MainTabController:UploadPostControllerDelegate{
    func controllerDidFinishUploadingPost(_ controller: UploadPostController) {
        selectedIndex = 0
        controller.dismiss(animated: true, completion: nil)
        
        guard let feedNav = viewControllers?.first as? UINavigationController else {return}
        guard let feed = feedNav.viewControllers.first as? FeedController else {return}
        feed.handleRefresh()
    }
}
