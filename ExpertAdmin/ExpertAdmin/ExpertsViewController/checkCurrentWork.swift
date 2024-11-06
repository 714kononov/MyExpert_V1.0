import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAppCheck

class checkCurrentWork: UIViewController {
    
    var orders: [(id: String, userName: String, userID: String, expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photos: [String], userAudio: String?)] = []
    var listeners: [ListenerRegistration] = []
    
    var types: [String] = ["ДТП", "Окон", "Заливов", "Обуви", "Одежды", "Строительная", "Бытовая техника", "Шуб", "Телефонов", "Мебель", "Переоценка кадастровой стоимости" ]
    var selectedStatus: Int = 0 // по умолчанию статус "На рассмотрении"
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтр", for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let ordersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        setupUI()
        fetchUserUIDs()
    }
    
    func setupUI() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(filterButton)
        contentView.addSubview(ordersStackView)
        
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            filterButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            filterButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            filterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            
            ordersStackView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 20),
            ordersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ordersStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ordersStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func filterTapped() {
        let alert = UIAlertController(title: "Выберите статус", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "На рассмотрении", style: .default, handler: { _ in
            self.selectedStatus = 0
            self.fetchUserUIDs()
            self.orders.removeAll()
        }))
        
        alert.addAction(UIAlertAction(title: "В разработке", style: .default, handler: { _ in
            self.selectedStatus = 1
            self.fetchUserUIDs()
            self.orders.removeAll()
        }))
        
        alert.addAction(UIAlertAction(title: "Готов", style: .default, handler: { _ in
            self.selectedStatus = 2
            self.fetchUserUIDs()
            self.orders.removeAll()
        }))
        
        alert.addAction(UIAlertAction(title: "Отменен", style: .default, handler: { _ in
            self.selectedStatus = 3
            self.fetchUserUIDs()
            self.orders.removeAll()
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func fetchUserUIDs() {
        let db = Firestore.firestore()
        
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            
            for document in snapshot!.documents {
                let userId = document.documentID
                self.addOrdersListener(for: userId)
            }
        }
    }
    
    func addOrdersListener(for userId: String) {
        let db = Firestore.firestore()
        
        // Создаем listener и добавляем его в массив сразу после объявления
        let listener = db.collection("users").document(userId).collection("orders")
            .whereField("status", isEqualTo: selectedStatus)
            .whereField("expertID", isEqualTo: Expert.shared.id)
            .addSnapshotListener { [weak self] (orderSnapshot, orderError) in
                guard let self = self else { return }
                
                if let orderError = orderError {
                    print("Error fetching orders: \(orderError)")
                } else {
                    guard let orderSnapshot = orderSnapshot else { return }
                    for diff in orderSnapshot.documentChanges {
                        switch diff.type {
                        case .added, .modified:
                            let data = diff.document.data()
                            
                            guard let userName = data["userName"] as? String,
                                  let date = data["date"] as? String,
                                  let typeExpertiz = data["typeExpertiza"] as? Int,
                                  let pay = data["pay"] as? Int,
                                  let status = data["status"] as? Int,
                                  let price = data["price"] as? Int,
                                  let expertName = data["expertName"] as? String,
                                  let imageUrls = data["imageUrls"] as? [String] else {
                                print("Ошибка при извлечении обязательных полей")
                                continue
                            }
                            
                            let userAudio = data["userAudio"] as? String
                            let userText = data["userText"] as? String
                            let photos = imageUrls.filter { !$0.isEmpty }
                            
                            let order = (id: diff.document.documentID,
                                         userName: userName,
                                         userID: userId,
                                         expertName: expertName,
                                         date: date,
                                         typeExpertiz: typeExpertiz,
                                         pay: pay,
                                         status: status,
                                         userText: userText,
                                         price: price,
                                         photos: photos,
                                         userAudio: userAudio
                            )
                            
                            if diff.type == .added {
                                self.orders.append(order)
                            } else if diff.type == .modified {
                                if let index = self.orders.firstIndex(where: { $0.id == order.id }) {
                                    self.orders[index] = order
                                }
                            }
                            
                        case .removed:
                            if let index = self.orders.firstIndex(where: { $0.id == diff.document.documentID }) {
                                self.orders.remove(at: index)
                            }
                        }
                    }
                    
                    self.updateOrderStackView()
                }
            }
        
        // Теперь добавляем listener в массив
        self.listeners.append(listener)
    }

    
    func updateOrderStackView() {
        ordersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for order in orders {
            createOrderBox(with: order)
        }
    }
    
    func createOrderBox(with order: (id: String, userName: String, userID: String, expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photos: [String],userAudio: String?)) {
        let orderView = UIView()
        orderView.backgroundColor = UIColor.black
        orderView.layer.cornerRadius = 10
        
        let orderLabel = UILabel()
        let expertizType = types[order.typeExpertiz - 1]
        
        orderLabel.text = "Имя: \(order.userName)\nТип: \(expertizType)\nДата заказа: \(order.date)"
        orderLabel.numberOfLines = 0
        orderLabel.textColor = .white
        orderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let detailsButton = UIButton()
        detailsButton.setTitle("Подробнее", for: .normal)
        detailsButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        detailsButton.layer.cornerRadius = 5
        detailsButton.translatesAutoresizingMaskIntoConstraints = false
        detailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)
        detailsButton.accessibilityIdentifier = "\(order.id):\(order.userID)"
        
        orderView.addSubview(orderLabel)
        orderView.addSubview(detailsButton)
        
        ordersStackView.addArrangedSubview(orderView)
        
        NSLayoutConstraint.activate([
            orderLabel.topAnchor.constraint(equalTo: orderView.topAnchor, constant: 10),
            orderLabel.leadingAnchor.constraint(equalTo: orderView.leadingAnchor, constant: 10),
            orderLabel.trailingAnchor.constraint(equalTo: orderView.trailingAnchor, constant: -10),
            
            detailsButton.topAnchor.constraint(equalTo: orderLabel.bottomAnchor, constant: 10),
            detailsButton.leadingAnchor.constraint(equalTo: orderView.leadingAnchor, constant: 10),
            detailsButton.trailingAnchor.constraint(equalTo: orderView.trailingAnchor, constant: -10),
            detailsButton.bottomAnchor.constraint(equalTo: orderView.bottomAnchor, constant: -10),
            detailsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func detailsTapped(sender: UIButton) {
        if let identifier = sender.accessibilityIdentifier {
            // Разделяем строку по двоеточию
            let components = identifier.split(separator: ":")
            if components.count == 2 {
                let orderId = String(components[0])
                let userId = String(components[1])
                
                // Сохраняем Order ID и userID
                MoreDetailID.share.id = orderId
                MoreDetailID.share.userID = userId
                
                print("ID заказа: \(orderId)")
                print("ID пользователя: \(userId)")
                
                // Получаем текущий заказ и передаем его в DetailsOrderViewController
                getCurrentOrder(orderId: orderId, userId: userId)
                
            } else {
                print("Неверный формат идентификатора, ожидается: 'orderId:userId'")
            }
        } else {
            print("ID заказа не найден")
        }
    }
    
    private func getCurrentOrder(orderId: String, userId: String) {
        Firestore.firestore().collection("users").document(userId).collection("orders").document(orderId).getDocument { [weak self] (orderSnapshot, error) in
            guard let self = self else { return } // Избегаем утечек памяти
            if let error = error {
                print("Ошибка выборки заказа: \(error)")
                return
            }
            
            guard let data = orderSnapshot?.data() else {
                print("Данные заказа не найдены")
                return
            }
            
            // Извлечение обязательных полей
            guard let userName = data["userName"] as? String,
                  let date = data["date"] as? String,
                  let typeExpertiz = data["typeExpertiza"] as? Int,
                  let pay = data["pay"] as? Int,
                  let status = data["status"] as? Int,
                  let price = data["price"] as? Int,
                  let expertName = data["expertName"] as? String,
                  let imageUrls = data["imageUrls"] as? [String] else {
                print("Ошибка при извлечении обязательных полей")
                return
            }
            
            // Дополнительное поле, если оно присутствует
            let userText = data["userText"] as? String
            let photos = imageUrls.filter { !$0.isEmpty }
            let userAudio = data["userAudio"] as? String
            
            // Создание объекта заказа
            let order = (id: orderId,
                         userName: userName,
                         userID: userId,
                         expertName: expertName,
                         date: date,
                         typeExpertiz: typeExpertiz,
                         pay: pay,
                         status: status,
                         userText: userText,
                         price: price,
                         photos: photos,
                         userAudio: userAudio)
            MoreDetailID.share.id = orderId
            
            // Переход на экран с детальной информацией
            let storyboard = UIStoryboard(name: "DetailsOrderViewController", bundle: nil)
            let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsOrderViewController") as! DetailsOrderViewController
            
            // Передача конкретного заказа
            detailsVC.order = order // Передаем массив заказов
            
            self.present(detailsVC, animated: true)
        }
    }
}
