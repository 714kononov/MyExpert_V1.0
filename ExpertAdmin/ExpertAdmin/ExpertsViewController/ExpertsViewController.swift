import UIKit
import Firebase
import FirebaseFirestore

class expert{
    static let shared = expert()
    var ID:Int?
}

class ExpertsViewController: UIViewController {
    
    var db: OpaquePointer?
    var experts: [(id: String, name: String, access: Int, phone: String)] = []
    var expertIDs: [Int: String] = [:]  // Словарь для хранения соответствия между tag и id
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        
        // Выполнение запроса к базе данных
        fetchOrders()
        
        // Настройка интерфейса
        setupOrderViews()
    }
    
    // Получение заказов из базы данных
    func fetchOrders() {
        let db = Firestore.firestore()
        
        db.collection("experts").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching experts: \(error)")
                return
            }
            
            guard let expertsSnapshot = snapshot else { return }
            
            self.experts.removeAll() // Удаляем все экспертов перед обновлением
            
            for document in expertsSnapshot.documents {
                let docID = document.documentID
                
                // Извлечение данных из документа
                let data = document.data()

                // Извлечение обязательных полей
                guard let name = data["expertName"] as? String,
                      let access = data["Access"] as? Int,
                      let phone = data["phone"] as? String else {
                    print("Error extracting required fields")
                    continue
                }
                
                // Создайте объект эксперта и добавьте его в массив
                let expertData = (id: docID, name: name, access: access, phone: phone)
                self.experts.append(expertData)
            }
            
            // Перезагружаем интерфейс с новыми данными
            self.setupOrderViews()
        }
    }


    
    // Настройка интерфейса
    func setupOrderViews() {
        // Удаляем все предыдущие subviews перед обновлением
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        for (index, expert) in experts.enumerated() {
            let expertView = createOrderView(id: expert.id, name: expert.name, access: expert.access, phone: expert.phone, tag: index)
            mainStackView.addArrangedSubview(expertView)
            expertIDs[index] = expert.id  // Сохраняем соответствие tag и id
        }
        
        let update = UIButton()
        update.backgroundColor = .black
        update.setTitle("Обновить", for: .normal)
        update.setTitleColor(.white, for: .normal)
        update.layer.cornerRadius = 7
        update.translatesAutoresizingMaskIntoConstraints = false
        update.addTarget(self, action: #selector(updateInfo), for: .touchUpInside)
        view.addSubview(update)
        
        NSLayoutConstraint.activate([
            update.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            update.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            update.heightAnchor.constraint(equalToConstant: 50),
            update.widthAnchor.constraint(equalToConstant: 200),
            
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: update.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Метод для создания представления эксперта
    func createOrderView(id: String, name: String, access: Int, phone: String, tag: Int) -> UIView {
        // Создаем основной контейнер
        let containerView = UIView()
        containerView.backgroundColor = .black
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Название эксперта
        let nameLabel = UILabel()
        nameLabel.text = "Эксперт: \(name)"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        // Уровень доступа
        let accessLabel = UILabel()
        accessLabel.text = "Уровень доступа: \(access)"
        accessLabel.textColor = .lightGray
        accessLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(accessLabel)
        
        // Телефон
        let phoneLabel = UILabel()
        phoneLabel.text = "Телефон: \(phone)"
        phoneLabel.textColor = .white
        phoneLabel.numberOfLines = 0
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(phoneLabel)
        
        // Кнопка "Редактировать"
        let editButton = UIButton()
        editButton.backgroundColor = .darkGray
        editButton.layer.cornerRadius = 10
        editButton.setTitle("Редактировать", for: .normal)
        editButton.isUserInteractionEnabled = true
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.tag = tag  // Устанавливаем tag
        editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)  // Добавляем действие нажатия
        containerView.addSubview(editButton)
        
        // Кнопка "Работы"
        let checkCurrentWork = UIButton()
        checkCurrentWork.backgroundColor = .darkGray
        checkCurrentWork.layer.cornerRadius = 10
        checkCurrentWork.setTitle("Работы", for: .normal)
        checkCurrentWork.isUserInteractionEnabled = true
        checkCurrentWork.translatesAutoresizingMaskIntoConstraints = false
        checkCurrentWork.tag = tag
        checkCurrentWork.addTarget(self, action: #selector(checkCurrentWorkTapped(_:)), for: .touchUpInside)
        containerView.addSubview(checkCurrentWork)

        // Устанавливаем ограничения (constraints)
        NSLayoutConstraint.activate([
            // Название эксперта
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            
            // Уровень доступа
            accessLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            accessLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            accessLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            // Телефон
            phoneLabel.topAnchor.constraint(equalTo: accessLabel.bottomAnchor, constant: 10),
            phoneLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            phoneLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            // Кнопка "Работы"
            checkCurrentWork.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 10),
            checkCurrentWork.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            checkCurrentWork.trailingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -5),
            checkCurrentWork.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            // Кнопка "Редактировать"
            editButton.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 10),
            editButton.leadingAnchor.constraint(equalTo: checkCurrentWork.trailingAnchor, constant: 10),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            editButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])

        return containerView
    }
    
    // Действие при нажатии на кнопку "Редактировать"
    @objc func editButtonTapped(_ sender: UIButton) {
        print(123)
        if let expertID = expertIDs[sender.tag] {
            print("Редактирование эксперта с ID: \(expertID)")
            MoreDetailID.share.id = expertID
            let storyboard = UIStoryboard(name: "EditExpertViewController", bundle: nil)
            let vsa = storyboard.instantiateViewController(withIdentifier: "EditExpertViewController") as! EditExpertViewController
            present(vsa, animated: true)
        }
    }
    
    // Действие при нажатии на кнопку "Работы"
    @objc func checkCurrentWorkTapped(_ sender: UIButton) {
        if let expertID = expertIDs[sender.tag] {
            print("Просмотр работ эксперта с ID: \(expertID)")
            MoreDetailID.share.id = expertID
            let storyboard = UIStoryboard(name: "checkCurrentWork", bundle: nil)
            let vsa = storyboard.instantiateViewController(withIdentifier: "checkCurrentWork") as! checkCurrentWork
            present(vsa, animated: true)
        }
    }
    
    @objc func updateInfo() {
        // Очистка текущих данных
        experts.removeAll()
        expertIDs.removeAll()

        // Обновление интерфейса (удаляем старые представления)
        setupOrderViews()
        
        // Загрузка обновленных данных
        fetchOrders()
    }
}
