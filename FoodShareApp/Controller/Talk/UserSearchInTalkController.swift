//
//  UserSearchInTalkController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/20.
//

import UIKit

private let reuseIdentifier = "userCell"

protocol UserSearchInTalkControllerDelegate: AnyObject {
    func controller(_ controller: UserSearchInTalkController, wantsToStartChatWith user: User)
}

class UserSearchInTalkController:UIViewController{
    //MARK: -プロパティー
    weak var delegate: UserSearchInTalkControllerDelegate?

    private let tableView = UITableView()
    
    private var users = [User]()

    
    private var filterUsers = [User]()
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    private var inSearchMode:Bool{
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    

    //MARK: -ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configureUI()
        fetchUsers()
    }
    
    //MARK: -API
    
    func fetchUsers(){
        UserService.fetchUsers { users in
            self.users = users
            self.tableView.reloadData()
        }
    }

    //MARK: -ヘルパー
    
    func configureUI(){
        view.backgroundColor = .mainBackgroundColor
        tableView.backgroundColor = .mainBackgroundColor
        navigationItem.title = "探す！"
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 64
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        tableView.isHidden = true
        
    }
    
    func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "友達を探す！"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}


//MARK: -UITableViewDataSource
extension UserSearchInTalkController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filterUsers.count : users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,for: indexPath) as! UserCell
        cell.backgroundColor = .mainBackgroundColor
        let user = inSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        cell.viewModel = UserCellViewModel(user:user)
        return cell
    }
}
//MARK: -UITableViewDelegate
extension UserSearchInTalkController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.controller(self, wantsToStartChatWith: users[indexPath.row])
    }
}

//MARK: -UISearchBarDelegate
extension UserSearchInTalkController:UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true

        tableView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        
        tableView.isHidden = true
        
    }
}
//MARK: -UISearchResultsUpdating
extension UserSearchInTalkController:UISearchResultsUpdating{
    //リストの更新処理
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {return}
        
        filterUsers = users.filter({$0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)})
        self.tableView.reloadData()
    }
}





