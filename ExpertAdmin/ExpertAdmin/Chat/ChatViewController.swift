import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

// Структура для сообщений
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind

    init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
}

// Структура для отправителя
struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

// Кастомная ячейка для сообщений
class TextMessageCell: MessageCollectionViewCell {
    let messageContainerView = UIView()
    let messageLabel = UILabel()
    let senderLabel = UILabel() // Добавляем метку для имени отправителя

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        messageContainerView.layer.cornerRadius = 12
        messageContainerView.clipsToBounds = true

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .black

        senderLabel.font = UIFont.systemFont(ofSize: 12)
        senderLabel.textColor = .lightGray

        contentView.addSubview(senderLabel) // Добавляем метку в контент
        contentView.addSubview(messageContainerView)
        messageContainerView.addSubview(messageLabel)

        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        senderLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            senderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            senderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            senderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            messageContainerView.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 5),
            messageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            messageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            messageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -10),
        ])
    }
}

// Контроллер чата
class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {

    var messages: [Message] = []
    var userID: String? // ID текущего пользователя
    var userName: String? // Имя текущего пользователя
    var chatID: String? // ID чата
    var recipientName: String? // Имя собеседника

    var currentSender: MessageKit.SenderType {
        return Sender(senderId: userID ?? "UnknownID", displayName: userName ?? "Unknown")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMessages()
    }

    // Настройка интерфейса
    func setupUI() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

        messagesCollectionView.backgroundColor = UIColor.darkGray

        messageInputBar.inputTextView.backgroundColor = UIColor.black
        messageInputBar.inputTextView.textColor = UIColor.white
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.inputTextView.clipsToBounds = true
        messageInputBar.sendButton.setTitleColor(UIColor.red, for: .normal)
        messageInputBar.backgroundView.backgroundColor = UIColor.darkGray
    }

    // MARK: - MessagesDataSource

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    // MARK: - MessagesDisplayDelegate

    func configureMessageCell(cell: MessageCollectionViewCell, message: MessageType, at indexPath: IndexPath) {
        guard let messageCell = cell as? TextMessageCell else { return }

        // Установка имени отправителя
        messageCell.senderLabel.text = message.sender.displayName

        if message.sender.senderId == userID {
            messageCell.messageContainerView.backgroundColor = UIColor.systemRed
            messageCell.messageLabel.textColor = UIColor.white
        } else {
            messageCell.messageContainerView.backgroundColor = UIColor.darkGray
            messageCell.messageLabel.textColor = UIColor.lightGray
        }
        
        messageCell.messageContainerView.layer.cornerRadius = 15
        messageCell.messageLabel.font = UIFont.systemFont(ofSize: 16)
    }

    // MARK: - InputBarAccessoryViewDelegate

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let chatID = chatID, let userID = userID, let userName = userName, !text.isEmpty else { return }

        let messageData: [String: Any] = [
            "senderID": userID,
            "senderName": userName,
            "text": text,
            "createdAt": Timestamp(date: Date())
        ]
        
        let collectionPath = ChatType.shared.status == 1 ? "chats" : "HelpChats"
        
        Firestore.firestore().collection(collectionPath).document(chatID).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Ошибка отправки сообщения: \(error.localizedDescription)")
            } else {
                inputBar.inputTextView.text = "" // Очищаем текстовое поле после отправки
            }
        }
    }

    // Загрузка сообщений из Firestore
    func loadMessages() {
        let collectionPath = ChatType.shared.status == 1 ? "chats" : "HelpChats"
        guard let chatID = chatID else { return }

        Firestore.firestore().collection(collectionPath).document(chatID).collection("messages").order(by: "createdAt", descending: false).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Ошибка загрузки сообщений: \(error?.localizedDescription ?? "Неизвестная ошибка")")
                return
            }

            self.messages = snapshot.documents.compactMap { doc -> Message? in
                let data = doc.data()
                guard
                    let senderID = data["senderID"] as? String,
                    let senderName = data["senderName"] as? String,
                    let text = data["text"] as? String,
                    let timestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }

                let sender = Sender(senderId: senderID, displayName: senderName)
                let message = Message(sender: sender, messageId: doc.documentID, sentDate: timestamp.dateValue(), kind: .text(text))
                return message
            }
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
}

// Расширение UIColor для добавления кастомных цветов
extension UIColor {
    static var darkGray: UIColor {
        return UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1)
    }
}
