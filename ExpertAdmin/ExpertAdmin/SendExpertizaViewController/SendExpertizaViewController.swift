import UIKit
import SQLite3
import UniformTypeIdentifiers

class SendExpertizaViewController: UIViewController, UIDocumentPickerDelegate {
    
    var db: OpaquePointer?
    
    // Элементы интерфейса для отображения данных
    var descriptionLabel: UILabel!
    var dateLabel: UILabel!
    var imageView1: UIImageView!
    var imageView2: UIImageView!
    var imageView3: UIImageView!
    var imageView4: UIImageView!
    
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
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
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
        
        // Настройка кнопки "Отправить экспертизу"
        let sendFileButton = UIButton()
        sendFileButton.setTitle("Отправить экспертизу", for: .normal)
        sendFileButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        sendFileButton.layer.cornerRadius = 10
        sendFileButton.translatesAutoresizingMaskIntoConstraints = false
        sendFileButton.addTarget(self, action: #selector(openFilePicker), for: .touchUpInside)
        view.addSubview(sendFileButton)
        
        // Центрирование элементов и установка констрейнтов
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            sendFileButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            sendFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendFileButton.widthAnchor.constraint(equalToConstant: 200),
            sendFileButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // Метод для создания ImageView
    func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        
        // Добавляем жест для увеличения изображения при нажатии
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }
    
    // Загрузка данных о заказе
    func loadOrderDetails() {
        guard let id = MoreDetailID.share.id else {
            print("ID заказа не найден.")
            return
        }
        let query = "SELECT date, UserText, photo1, photo2, photo3, photo4 FROM orders WHERE id = ?"
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
            
            dateLabel.text = "Дата: \(date)"
            descriptionLabel.text = description
            
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
    
    func loadImage(from urlString: String, into imageView: UIImageView) {
        if let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
            imageView.image = UIImage(data: data)
        }
    }
    
    // Открытие файловой системы для выбора файла
    @objc func openFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.plainText], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    // Метод для обработки выбранного файла
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        
        // Здесь вы можете обработать выбранный файл
        print("Выбран файл: \(selectedFileURL)")
        
        // Можно отправить файл на сервер или сохранить в базе данных
    }
    
    // Метод для обработки отмены выбора
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Выбор файла отменен")
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
}
