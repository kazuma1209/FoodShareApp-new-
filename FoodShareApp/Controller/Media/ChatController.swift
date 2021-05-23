//
//  ChatController.swift
//  FoodShareApp
//
//  Created by 坂田一真 on 2021/05/24.
//
import UIKit

private let reuseIdentifier = "MessageCell"

class ChatController: UICollectionViewController {
    
    // MARK: -プロパティ
    
    private let user: User
    private var messages = [Message]()
    var fromCurrentUser = false
    
    private lazy var customInputView: CommentInputAccesoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let iv = CommentInputAccesoryView(frame: frame)
        iv.delegate = self
        return iv
    }()
    
    // MARK: -ライフサイクル
     
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages()
    }

    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - API
    
    func fetchMessages() {
        MessageService.fetchMessages(forUser: user) { messages in
            self.messages = messages
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.messages.count - 1],
                                             at: .bottom, animated: true)
        }
    }

    // MARK: -ヘルパー
    
    func configureUI() {
        collectionView.backgroundColor = .mainBackgroundColor
        navigationItem.title = user.username
        
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
}

extension ChatController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        cell.viewModel = MessageViewModel(message: messages[indexPath.row])
        return cell
    }
}

extension ChatController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let estimatedSizeCell = ChatCell(frame: frame)
        estimatedSizeCell.viewModel = MessageViewModel(message: messages[indexPath.row])
        estimatedSizeCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
}

extension ChatController:CommentInputAccesoryViewDelegate{
    func inputView(_ inputView: CommentInputAccesoryView, wantsToUploadComment comment: String) {
        MessageService.uploadMessage(comment, to: user) { error in
            if let error = error {
                print("DEBUG: Failed to upload message with error \(error.localizedDescription)")
                return
            }

            inputView.clearCommentTextView()
        }
    }
    
    
}
