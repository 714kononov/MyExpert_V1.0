import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class MyOrderViewController: UIViewController {
    var orders: [(id: String, expertName: String?,expertAnswer: String, expertID: String?, userName: String, date: String, typeExpertiz: Int, pay: Int, price: Int, result: Int,status:Int, userText: String?, photo1: String?, photo2: String?, photo3: String?, photo4: String?, userAudio: String?)] = []
    
    let scrollView = UIScrollView()
    let contentView = UIView()

    let noOrdersLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет заказов"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.isHidden = true // Скрыто по умолчанию
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)

        setupScrollView()
        
        if let usrname = UserSession.shared.userName {
            getOrders()
        }
    }

    func setupScrollView() {
        
        contentView.subviews.forEach {
                if $0 != noOrdersLabel { $0.removeFromSuperview() }
            }
        
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Constraints для scrollView и contentView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Это важно для вертикального скролла
        ])
        
        contentView.addSubview(noOrdersLabel)
        noOrdersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noOrdersLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            noOrdersLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 100)
        ])
    }
    
    func getOrders() {
        let uid = UserSession.shared.userID ?? ""

        Firestore.firestore().collection("users").document(uid).collection("orders").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No documents found")
                self.orders = [] // Убедитесь, что массив пустой
                self.updateUI()
                return
            }

            print("Documents: \(documents)")

            // Очищаем массив перед добавлением новых данных
            self.orders.removeAll()

            // Обрабатываем документы и добавляем заказы в массив
            for document in documents {
                let data = document.data()

                guard let id = document.documentID as? String,
                      let expertName = data["expertName"] as? String,
                      let expertID = data["expertID"] as? String,
                      let userName = data["userName"] as? String,
                      let date = data["date"] as? String,
                      let typeExpertiz = data["typeExpertiza"] as? Int,
                      let price = data["price"] as? Int,
                      let answerExpert = data["expertAnswer"] as? String,
                      let pay = data["pay"] as? Int,
                      let result = data["result"] as? Int,
                      let status = data["status"] as? Int,
                      let imageUrls = data["imageUrls"]as? [String]     else {
                    print("Missing required data in document: \(document.documentID)")
                    continue
                }

                let userText = data["userText"] as? String
                let photo1 = imageUrls.indices.contains(0) ? imageUrls[0] : nil
                let photo2 = imageUrls.indices.contains(1) ? imageUrls[1] : nil
                let photo3 = imageUrls.indices.contains(2) ? imageUrls[2] : nil
                let photo4 = imageUrls.indices.contains(3) ? imageUrls[3] : nil
                let userAudio = data["userAudio"] as? String

                self.orders.append((id: document.documentID,expertName:expertName,expertAnswer: answerExpert, expertID: expertID, userName: userName, date: date, typeExpertiz: typeExpertiz, price: price, pay: pay, result: result, status: status, userText: userText, photo1: photo1, photo2: photo2, photo3: photo3, photo4: photo4, userAudio: userAudio))
            }

            self.updateUI()
        }
    }

    func updateUI() {
        if orders.isEmpty {
            noOrdersLabel.isHidden = false
            contentView.subviews.forEach {
                if $0 != noOrdersLabel { $0.removeFromSuperview() }
            }
        } else {
            noOrdersLabel.isHidden = true
            setupOrdersUI()
        }
    }

    func setupOrdersUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        for order in orders {
            let orderView = createOrderView(order: order)
            stackView.addArrangedSubview(orderView)
        }
    }

    func createOrderView(order: (id: String, expertName: String?,expertAnswer: String, expertID: String?, userName: String, date: String, typeExpertiz: Int, pay: Int, price: Int, result: Int,status:Int, userText: String?, photo1: String?, photo2: String?, photo3: String?, photo4: String?, userAudio: String?)) -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)

        let circle = UIView()
        let diameter: CGFloat = 20.0
        circle.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        circle.layer.cornerRadius = diameter / 2

        switch order.status {
        case 0:
            circle.backgroundColor = .orange
        case 1:
            circle.backgroundColor = .orange
        case 2:
            circle.backgroundColor = .green
        default:
            circle.backgroundColor = .red
        }

        circle.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(circle)

        let dateLabel = UILabel()
        dateLabel.text = formatDateString(order.date) ?? order.date
        dateLabel.font = UIFont.systemFont(ofSize: 16)
        dateLabel.textColor = .white

        let titleLabel = UILabel()
        titleLabel.text = "Экспертиза от \(formatDateString(order.date) ?? order.date)"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        let userNameLabel = UILabel()
        userNameLabel.text = "Заказчик: \(order.userName)"
        userNameLabel.font = UIFont.systemFont(ofSize: 16)
        userNameLabel.textColor = .lightGray

        let typeLabel = UILabel()
        switch order.typeExpertiz {
        case 1: typeLabel.text = "Тип экспертизы: ДТП"
        case 2: typeLabel.text = "Тип экспертизы: Окон"
        case 3: typeLabel.text = "Тип экспертизы: Заливов"
        case 4: typeLabel.text = "Тип экспертизы: Обуви"
        case 5: typeLabel.text = "Тип экспертизы: Одежды"
        case 6: typeLabel.text = "Тип экспертизы: Строительная"
        case 7: typeLabel.text = "Тип экспертизы: Бытовая техника"
        case 8: typeLabel.text = "Тип экспертизы: Шуб"
        case 9: typeLabel.text = "Тип экспертизы: Телефонов"
        case 10: typeLabel.text = "Тип экспертизы: Мебель"
        case 11: typeLabel.text = "Тип экспертизы: ПКС"
        case 12: typeLabel.text = "Тип экспертизы: Другое"
        default: typeLabel.text = "Тип экспертизы: Неизвестно"
        }
        typeLabel.font = UIFont.systemFont(ofSize: 16)
        typeLabel.textColor = .lightGray

        let detailButton = UIButton(type: .system)
        detailButton.setTitle("Подробнее", for: .normal)
        detailButton.setTitleColor(.white, for: .normal)
        detailButton.backgroundColor = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0)
        detailButton.layer.cornerRadius = 10
        detailButton.addTarget(self, action: #selector(showOrderDetails(_:)), for: .touchUpInside)

        // Используйте индекс для тега
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            detailButton.tag = index // Сохраняем индекс
        } else {
            detailButton.tag = 0 // По умолчанию, если не найдено
        }

        let stackView = UIStackView(arrangedSubviews: [titleLabel, userNameLabel, typeLabel, detailButton])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(stackView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(circle)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        circle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            circle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            circle.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            circle.widthAnchor.constraint(equalToConstant: diameter),
            circle.heightAnchor.constraint(equalToConstant: diameter),

            dateLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 10),

            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])

        return containerView
    }

    @objc func showOrderDetails(_ sender: UIButton) {
        let index = sender.tag
        guard index >= 0 && index < orders.count else { return }
        
        let selectedOrder = orders[index] // Получаем весь объект заказа

        let storyboard = UIStoryboard(name: "OrderDetailsViewController", bundle: nil) // Убедитесь, что имя storyboard правильное
        guard let orderDetailsVC = storyboard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as? OrderDetailsViewController else {
            print("Ошибка: не удалось инициализировать OrderDetailsViewController")
            return
        }
        
        // Передайте весь объект заказа
        orderDetailsVC.order = selectedOrder
        present(orderDetailsVC, animated: true)
    }



    func formatDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM yyyy"
            return displayFormatter.string(from: date)
        }
        return nil
    }
}
