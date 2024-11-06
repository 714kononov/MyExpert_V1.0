import UIKit
import SQLite3


class ReadyViewController: UIViewController {
    
    var db: OpaquePointer?
    var orders: [(id: Int, date: String, typeExpertiz: String, userText: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        
        // Подключение к базе данных
        connectToDatabase()
        
        // Выполнение запроса к базе данных
        fetchOrders()
        
        // Настройка интерфейса
        setupOrderViews()
    }
    
    // Подключение к базе данных
    func connectToDatabase() {
        let fileManager = FileManager.default
        let dbPath = "/Users/admin/Desktop/expert.sqlite"
        
        if !fileManager.fileExists(atPath: dbPath) {
            print("База данных не найдена по пути: \(dbPath)")
            return
        }

        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при открытии базы данных: \(errmsg)")
        } else {
            print("База данных успешно открыта.")
        }
    }
    
    // Получение заказов из базы данных
    func fetchOrders() {
        guard let typeIndex = TypeIndex.shared.Index else {
            print("Тип экспертизы не выбран.")
            return
        }

        let query = "SELECT id, date, typeExpertiz, UserText FROM orders WHERE typeExpertiz = ? AND result = 2"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(statement, 1, Int32(typeIndex)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметра: \(errmsg)")
            return
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let date = String(cString: sqlite3_column_text(statement, 1))
            let typeExpertiz = String(cString: sqlite3_column_text(statement, 2))
            let userText = String(cString: sqlite3_column_text(statement, 3))
            
            orders.append((id: id, date: date, typeExpertiz: typeExpertiz, userText: userText))
        }
        
        sqlite3_finalize(statement)
    }
    
    // Настройка интерфейса
    func setupOrderViews() {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        for order in orders {
            let orderView = createOrderView(id: order.id, date: order.date, typeExpertiz: order.typeExpertiz, userText: order.userText)
            mainStackView.addArrangedSubview(orderView)
        }
        
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Метод для создания представления заказа
    func createOrderView(id: Int, date: String, typeExpertiz: String, userText: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.text = "Экспертиза от \(date)"
        dateLabel.textColor = .white
        dateLabel.font = UIFont.boldSystemFont(ofSize: 18)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let typeLabel = UILabel()
        typeLabel.text = "Тип экспертизы: \(typeExpertiz)"
        typeLabel.textColor = .lightGray
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let userTextLabel = UILabel()
        userTextLabel.text = userText
        userTextLabel.textColor = .white
        userTextLabel.numberOfLines = 0
        userTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let moreButton = UIButton()
        moreButton.setTitle("Подробнее", for: .normal)
        moreButton.backgroundColor = .darkGray
        moreButton.layer.cornerRadius = 5
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем действие на кнопку с передачей ID
        moreButton.addTarget(self, action: #selector(MoreDetailsTapped(_:)), for: .touchUpInside)
        moreButton.tag = id // Устанавливаем ID заказа в tag кнопки
        
        containerView.addSubview(dateLabel)
        containerView.addSubview(typeLabel)
        containerView.addSubview(userTextLabel)
        containerView.addSubview(moreButton)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            typeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            typeLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            userTextLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 10),
            userTextLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor),
            userTextLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            moreButton.topAnchor.constraint(equalTo: userTextLabel.bottomAnchor, constant: 10),
            moreButton.leadingAnchor.constraint(equalTo: userTextLabel.leadingAnchor),
            moreButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        return containerView
    }
    
    // Метод для обработки нажатия на кнопку "Подробнее"
    @objc func MoreDetailsTapped(_ sender: UIButton) {
        let selectedID = sender.tag
        MoreDetailID.share.id = selectedID // Сохраняем ID выбранного заказа
        
        if let id = MoreDetailID.share.id {
            print("ID Выбранной активной экспертизы : \(id)")
        } else {
            print("ID активной экспертизы не найден.")
        }
        
        let storyboard = UIStoryboard(name: "MoreDetailsViewController", bundle: nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: "MoreDetailsViewController") as! MoreDetailsViewController
        present(detailsVC, animated: true)
    }

}

