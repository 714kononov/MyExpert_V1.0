import UIKit
import Firebase
import FirebaseFirestore

struct User {
    let uid: String
    let name: String
}

class UsersChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var users: [(id: String, name: String)] = [] // Объявляем массив пользователей
    private let tableView = UITableView() // Создаем tableView

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        setupUI()
    }
    
    private func fetchUsers() {
        Firestore.firestore().collection("users").getDocuments { (userSnapshot, error) in
            if let error = error {
                print("Ошибка запроса выбора списка пользователей: \(error.localizedDescription)")
                return
            }
            
            guard let userDocuments = userSnapshot?.documents else { return }
            // Заполняем массив users
            self.users = userDocuments.compactMap { doc -> (id: String, name: String)? in
                let data = doc.data()
                guard let name = data["name"] as? String else { return nil }
                return (id: doc.documentID, name: name)
            }
            self.tableView.reloadData() // Перезагрузка таблицы с новыми данными
        }
    }
    
    func fetchHelpChat(with userID: String) {
        Firestore.firestore().collection("HelpChats").whereField("userID", isEqualTo: userID).getDocuments { (chatSnapshot, error) in
            if let error = error {
                print("Ошибка выборки чата помощи админа: \(error.localizedDescription)")
                return
            }
            
            guard let chatDocuments = chatSnapshot?.documents, !chatDocuments.isEmpty else {
                print("Чат не найден для пользователя с ID: \(userID)")
                return
            }
            
            // Получаем только первый документ, так как чат будет один
            let chatID = chatDocuments.first!.documentID
            Chat.shared.chatID = chatID
            
            // Переход к ChatViewController после получения chatID
            let storyboard = UIStoryboard(name: "ChatViewController", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatVC.userName = Expert.shared.name
            chatVC.userID = Expert.shared.id
            chatVC.chatID = Chat.shared.chatID
            
            // Здесь вызываем present, так как находимся в замыкании
            self.present(chatVC, animated: true, completion: nil)
        }
    }
    
    private func setupUI() {
        // Настройка tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Констрейты для tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        let user = users[indexPath.row]
        cell.configure(with: user)
        cell.chatButtonAction = {
            self.fetchHelpChat(with: user.id)
            print("User ID: \(user.id)")
        }
        return cell
    }
}



// Класс ячейки таблицы
class UserTableViewCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let chatButton = UIButton(type: .system)
    var chatButtonAction: (() -> Void)? // Блок для обработки нажатия кнопки
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        chatButton.setTitle("Чат", for: .normal)
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(chatButton)
        
        // Констрейты для nameLabel и chatButton
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            chatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chatButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with user: (id: String, name: String)) {
        nameLabel.text = user.name
    }
    
    @objc private func chatButtonTapped() {
        chatButtonAction?() // Вызов действия при нажатии кнопки
    }
}
