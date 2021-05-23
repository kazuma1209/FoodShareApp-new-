//
//  ConversationController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/24.
//
import UIKit
import Firebase

private let reuseIdentifier = "ConversationCell"

class ConversationController: UIViewController {
    
    // MARK: -プロパティ
    
    private let tableView = UITableView()
    private var conversations = [Message]()
    private var conversationsDictionary = [String: Message]()
    
    // MARK: -ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        configureTableView()
        fetchConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: -セレクター
    
    @objc func showNewMessage() {
        let controller = UserSearchInTalkController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
    
    @objc func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API
    
    func fetchConversations() {
        MessageService.fetchRecentMessages { conversations in
            conversations.forEach { conversation in
                self.conversationsDictionary[conversation.chatPartnerId] = conversation
            }
            
            self.conversations = Array(self.conversationsDictionary.values)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - ヘルパー
    
    func configureTableView() {
        view.backgroundColor = .mainBackgroundColor
        tableView.backgroundColor = .mainBackgroundColor
        tableView.rowHeight = 80
        tableView.register(ConversationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        navigationItem.title = "メッセージ"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain,
                                                           target: self, action: #selector(handleDismissal))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self,
                                                            action: #selector(showNewMessage))
    }
    
    func showChatController(forUser user: User) {
        let controller = ChatController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ConversationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ConversationCell
        cell.viewModel = MessageViewModel(message: conversations[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ConversationController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoader(true)
        
        UserService.fetchUser(withUid: conversations[indexPath.row].chatPartnerId) { user in
            self.showLoader(false)
            self.showChatController(forUser: user)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       
    }
}

// MARK: - UserSearchInTalkControllerDelegate

extension ConversationController: UserSearchInTalkControllerDelegate {
    func controller(_ controller: UserSearchInTalkController, wantsToStartChatWith user: User) {
        dismiss(animated: true, completion: nil)
        showChatController(forUser: user)
    }
}
