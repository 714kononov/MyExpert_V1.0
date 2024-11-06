import UIKit
import SQLite3
import MobileCoreServices

class MoreDetailsViewController: UIViewController {
    
    var db: OpaquePointer?
    
    class Order
    {
        static let shared = Order()
        var orderID:Int?
        var expertAnswer:String?
        var price:Int?
        var expertName: String?
        var expertID:Int?
        var result:Int?
    }

    var experts: [(id: Int, name: String)] = []
    
    // Элементы интерфейса для отображения данных
    var descriptionLabel: UILabel!
    var dateLabel: UILabel!
    var priceLabel:UILabel!
    var expertName: UILabel!
    var imageView1: UIImageView!
    var imageView2: UIImageView!
    var imageView3: UIImageView!
    var imageView4: UIImageView!
    var priceTextField: UITextField!
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        // Подключение к базе данных
        connectToDatabase()
        
        // Настройка интерфейса
        setupInterface()
        
        // Загрузка данных о заказе
        loadOrderDetails()
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
    
    // Настройка интерфейса
    func setupInterface() {
        // Создание контейнера для даты и описания
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Настройка лейбла даты
        dateLabel = UILabel()
        dateLabel.textColor = .white
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        priceLabel = UILabel()
        priceLabel.textColor = .white
        priceLabel.numberOfLines = 0
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(priceLabel)
        
        expertName = UILabel()
        expertName.textColor = .white
        expertName.numberOfLines = 0
        expertName.textAlignment = .center
        expertName.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(expertName)
        
        // Настройка лейбла описания
        descriptionLabel = UILabel()
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        // Настройка констрейнтов для контейнера
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            // Констрейнты для даты и описания внутри контейнера
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            
            // Констрейнты для expertName
            expertName.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            expertName.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            expertName.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            expertName.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10)
        ])


        
        // Настройка изображений
        imageView1 = createImageView()
        imageView2 = createImageView()
        imageView3 = createImageView()
        imageView4 = createImageView()
        
        let stackView = UIStackView(arrangedSubviews: [imageView1, imageView2, imageView3, imageView4])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Настройка кнопок
        let confirmButton = createButton(with: "Подтвердить заказ")
        confirmButton.addTarget(self, action: #selector(confirmOrder), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        let cancelButton = createButton(with: "Отменить заказ")
        cancelButton.addTarget(self, action: #selector(cancelOrder), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        let buttonStackView = UIStackView(arrangedSubviews: [confirmButton, cancelButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        // Поле для ввода цены
        priceTextField = UITextField()
        priceTextField.placeholder = "Введите цену"
        priceTextField.borderStyle = .roundedRect
        priceTextField.keyboardType = .numberPad
        priceTextField.textColor = .white       // Текст будет белым
        priceTextField.backgroundColor = .black // Фон текстового поля будет черным
        priceTextField.attributedPlaceholder = NSAttributedString(string: "Введите цену", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]) // Плейсхолдер светло-серый
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(priceTextField)
        
        //Кнопка назначить цену
        
        let chooseExpert = createButton(with: "Назначить эксперта")
        chooseExpert.addTarget(self, action: #selector(chooseExpertTapped), for: .touchUpInside)
        view.addSubview(chooseExpert)
        
        let addFile = createButton(with: "Экспертиза")
        addFile.addTarget(self, action: #selector(openFileManager), for: .touchUpInside)
        view.addSubview(addFile)
        
        //Кнопка закрыть
        let closeWindowsButton = UIButton()
        closeWindowsButton.setTitle("Записать изменения", for: .normal)
        closeWindowsButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        closeWindowsButton.setTitleColor(.white, for: .normal)
        closeWindowsButton.layer.cornerRadius = 10
        closeWindowsButton.translatesAutoresizingMaskIntoConstraints = false
        closeWindowsButton.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
        view.addSubview(closeWindowsButton)
        
        // Центрирование элементов и установка констрейнтов
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 170),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.widthAnchor.constraint(equalToConstant: 170),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            
            priceTextField.topAnchor.constraint(equalTo: cancelButton.bottomAnchor,constant: 30),
            priceTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            priceTextField.widthAnchor.constraint(equalToConstant: 200),
            priceTextField.heightAnchor.constraint(equalToConstant: 40),

            
            chooseExpert.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 20),
            chooseExpert.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chooseExpert.widthAnchor.constraint(equalToConstant: 200),
            chooseExpert.heightAnchor.constraint(equalToConstant: 50),
            
            addFile.topAnchor.constraint(equalTo: chooseExpert.bottomAnchor, constant: 20),
            addFile.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addFile.widthAnchor.constraint(equalToConstant: 200),
            addFile.heightAnchor.constraint(equalToConstant: 50),
            
            closeWindowsButton.topAnchor.constraint(equalTo: addFile.bottomAnchor,constant: 100),
            closeWindowsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeWindowsButton.widthAnchor.constraint(equalToConstant: 250),
            closeWindowsButton.heightAnchor.constraint(equalToConstant: 70)
            
            
        ])
    }

    
    // Метод для создания ImageView
    func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true // Включаем взаимодействие
        view.addSubview(imageView)
        
        // Добавляем жест для увеличения изображения при нажатии
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }
    
    // Обработчик нажатия на изображение
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView, let image = imageView.image {
            let imageVC = UIViewController()
            imageVC.view.backgroundColor = .black
            let enlargedImageView = UIImageView(image: image)
            enlargedImageView.contentMode = .scaleAspectFit
            enlargedImageView.frame = imageVC.view.frame
            imageVC.view.addSubview(enlargedImageView)
            
            let closeGesture = UITapGestureRecognizer(target: self, action: #selector(dismissImage))
            imageVC.view.addGestureRecognizer(closeGesture)
            
            self.present(imageVC, animated: true, completion: nil)
        }
    }
    
    @objc func dismissImage() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Загрузка данных о заказе
    func loadOrderDetails() {
        guard let id = MoreDetailID.share.id else {
            print("ID заказа не найден.")
            return
        }
        Order.shared.orderID = MoreDetailID.share.id
        let query = "SELECT date, UserText, photo1, photo2, photo3, photo4, pay, expertID FROM orders WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(statement, 1, Int32(id)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметра: \(errmsg)")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            let date = String(cString: sqlite3_column_text(statement, 0))
            let description = String(cString: sqlite3_column_text(statement, 1))
            let photo1 = sqlite3_column_text(statement, 2).map { String(cString: $0) }
            let photo2 = sqlite3_column_text(statement, 3).map { String(cString: $0) }
            let photo3 = sqlite3_column_text(statement, 4).map { String(cString: $0) }
            let photo4 = sqlite3_column_text(statement, 5).map { String(cString: $0) }
            
            // Извлечение новых полей
            let price = sqlite3_column_int(statement, 6) // price
            let expertID = sqlite3_column_int(statement, 7) // expertID
            
            //Получить имя эксперта из таблицы Experts по expertID
            
            dateLabel.text = "Дата: \(date)"
            descriptionLabel.text = description
            priceLabel.text = "Цена за экспертизу: \(price)"
            
            loadExpertName(for: Int(expertID))

            // Сохранение цены и ID эксперта в Order.shared
            Order.shared.price = Int(price)
            Order.shared.expertID = Int(expertID)

            // Загрузка фотографий
            if let photo1 = photo1, !photo1.isEmpty {
                imageView1.isHidden = false
                loadImage(from: photo1, into: imageView1)
            }
            if let photo2 = photo2, !photo2.isEmpty {
                imageView2.isHidden = false
                loadImage(from: photo2, into: imageView2)
            }
            if let photo3 = photo3, !photo3.isEmpty {
                imageView3.isHidden = false
                loadImage(from: photo3, into: imageView3)
            }
            if let photo4 = photo4, !photo4.isEmpty {
                imageView4.isHidden = false
                loadImage(from: photo4, into: imageView4)
            }
        } else {
            print("Заказ не найден.")
        }
        
        sqlite3_finalize(statement)
    }
    
    func loadExpertName(for expertID: Int) {
        let query = "SELECT Name FROM experts WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(statement, 1, Int32(expertID)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметра: \(errmsg)")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            let expertNameText = String(cString: sqlite3_column_text(statement, 0))
            expertName.text = "Эксперт: \(expertNameText)"
        } else {
            expertName.text = "Эксперт: Не найден"
        }
        
        sqlite3_finalize(statement)
    }

    
    func loadImage(from urlString: String, into imageView: UIImageView) {
        if let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
            imageView.image = UIImage(data: data)
        }
    }
    
    // Обработчик для кнопки "Подтвердить"
    @objc func confirmOrder() {
        let confirmMessage = "Здравствуйте! Мы сможем вам помочь вам необходимо оплатить экспертизу нажав по кнопке снизу, после оплаты мы сразу же перейдем созданию экспертизы"
        //updateOrderAnswer(with: confirmMessage, for: id)
        //updateOrderResult(with: 2, for: id) // Меняем result на 2
        let action = UIAlertController(title: "Подтверждение заказа", message: "Вы подтвердили заказ на экспертизу", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ок", style: .default)
        action.addAction(OKAction)
        Order.shared.expertAnswer = confirmMessage
        Order.shared.result = 2
        present(action,animated: true)
    }
    
    // Обработчик для кнопки "Отменить"
    @objc func cancelOrder() {
        let cancelMessage = "Здравствуйте! К сожалению мы не сможем вам помочь"
        let action = UIAlertController(title: "Отмена заказа", message: "Вы отменили заказ на экспертизу", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ок", style: .default)
        action.addAction(OKAction)
        Order.shared.expertAnswer = cancelMessage
        Order.shared.result = 3
        present(action,animated: true)
    }
    
    func createButton(with text: String?) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    
    @objc func closeWindow() {
        var answer: String = ""

        if let optionalAnswer = Order.shared.expertAnswer {
            answer = optionalAnswer
        }
        
        guard let priceText = priceTextField.text , !priceText.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Поле не должно быть пустым! Введите цену за экспертизу", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(OKAction)
            present(alert,animated: true)
            return
        }
        
        // Проверяем, что введены только цифры
        guard let price1 = Int(priceText) else {
            let alert = UIAlertController(title: "Ошибка", message: "Введите необходимую сумму для оплаты экспертизы", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(OKAction)
            present(alert,animated: true)
            
            return
        }
        
        Order.shared.price = Int(priceText)

        let orderID = Order.shared.orderID ?? 0
        let price = Order.shared.price ?? 0
        let expert = Order.shared.expertID ?? 0
        let result = Order.shared.result ?? 0

        writeChangeIntoOrder(orderID: orderID, expertAnswer: answer, price: price, expert: expert, result: result)
        self.dismiss(animated: true)
    }

    
    @objc func chooseExpertTapped() {
        getExperts()
        
        if !experts.isEmpty {
            showExpertSelection()
        } else {
            print("Список экспертов пуст")
        }
    }

    func showExpertSelection() {
        let alert = UIAlertController(title: "Выберите эксперта", message: nil, preferredStyle: .actionSheet)
        
        for expert in experts {
            let action = UIAlertAction(title: expert.name, style: .default) { _ in
                // Действие при выборе эксперта
                self.expertSelected(expert.id, name: expert.name)
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Предполагается, что `self` является контроллером
        self.present(alert, animated: true, completion: nil)
    }

    func expertSelected(_ id: Int, name: String) {
        print("Выбран эксперт: \(name) с ID: \(id)")
        Order.shared.expertID = id
    }

    func getExperts() {
        let query = "SELECT id, Name FROM experts"
        var statement: OpaquePointer?

        if sqlite3_prepare(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке запроса: \(errmsg)")
            return
        }

        experts.removeAll() // Очистка перед загрузкой новых экспертов

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let name = String(cString: sqlite3_column_text(statement, 1))

            experts.append((id: id, name: name))
        }

        sqlite3_finalize(statement)
    }
    
    
    func writeChangeIntoOrder(orderID: Int?, expertAnswer: String?, price: Int?, expert: Int?, result: Int?) {
        guard let db = db else {
            print("Ошибка: Не удалось получить соединение с базой данных.")
            return
        }

        // Обновляем запрос, добавив поле result
        let updateStatementString = "UPDATE orders SET answerExpert = ?, pay = ?, expertID = ?, result = ? WHERE id = ?"
        var updateStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            // Привязываем параметры к запросу
            sqlite3_bind_text(updateStatement, 1, (expertAnswer as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, Int32(price ?? 0))
            sqlite3_bind_int(updateStatement, 3, Int32(expert ?? 0))
            sqlite3_bind_int(updateStatement, 4, Int32(result ?? 0)) // Добавлено поле result
            sqlite3_bind_int(updateStatement, 5, Int32(orderID ?? 0)) // Изменен порядок параметров

            // Выполняем запрос на обновление данных
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Данные успешно обновлены в таблице orders.")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("Ошибка при выполнении запроса: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
        }

        // Финализируем запрос
        sqlite3_finalize(updateStatement)
    }
    
    @objc func openFileManager()
    {

    }
    
    
}

