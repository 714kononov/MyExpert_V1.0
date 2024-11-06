import UIKit
import SQLite3

class TypeIndex
{
    static let shared = TypeIndex()
    var Index:Int?
}

class NewViewController: UIViewController {
    
    var types: [String] = ["ДТП", "Окон", "Заливов", "Обуви", "Одежды", "Строительная", "Бытовая техника", "Шуб", "Телефонов", "Мебель"]
    var db: OpaquePointer?
    
    // Глобальная переменная для хранения индекса выбранного типа экспертизы

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)

        // Подключение к базе данных
        connectToDatabase()

        // Добавление кнопок экспертиз
        setupExpertiseButtons()
    }
    
    func connectToDatabase() {
        let fileManager = FileManager.default
        
        // Путь к базе данных в папке Documents
        let dbPath = "/Users/admin/Desktop/expert.sqlite"
        
        // Проверка, существует ли база данных по указанному пути
        if !fileManager.fileExists(atPath: dbPath) {
            print("База данных не найдена по пути: \(dbPath)")
            return
        }

        // Открытие базы данных
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при открытии базы данных: \(errmsg)")
            return
        } else {
            print("База данных успешно открыта по пути: \(dbPath)")
        }
    }
    
    // Запрос количества записей с result = 2 для конкретного типа экспертизы
    func fetchExpertCount(for typeExpertiz: Int) -> Int {
        var count = 0
        let query = "SELECT COUNT(*) FROM orders WHERE typeExpertiz = ? AND result = 1"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
            return count
        }
        
        // Привязываем значение типа экспертизы к запросу
        if sqlite3_bind_int(statement, 1, Int32(typeExpertiz)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметра: \(errmsg)")
            return count
        }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            count = Int(sqlite3_column_int(statement, 0))
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при выполнении SQL-запроса: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return count
    }
    
    // Метод для создания кнопок экспертиз
    func setupExpertiseButtons() {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        var rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.spacing = 20
        rowStackView.alignment = .fill
        rowStackView.distribution = .fillEqually
        
        for (index, type) in types.enumerated() {
            let button = createButton(text: type)
            let count = fetchExpertCount(for: index + 1)  // `index + 1` для соответствия typeExpertiz в БД
            
            // Добавляем действие для кнопки
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.tag = index + 1  // Используем `tag` для сохранения типа экспертизы (typeExpertiz)
            
            // Добавление "бейджа" со счетчиком на кнопку
            if count > 0 {
                let badgeLabel = createBadgeLabel(with: count)
                button.addSubview(badgeLabel)
                
                NSLayoutConstraint.activate([
                    badgeLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: -10),
                    badgeLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 10),
                    badgeLabel.widthAnchor.constraint(equalToConstant: 30),
                    badgeLabel.heightAnchor.constraint(equalToConstant: 30)
                ])
            }
            
            rowStackView.addArrangedSubview(button)
            
            if index % 2 != 0 || index == types.count - 1 {
                mainStackView.addArrangedSubview(rowStackView)
                rowStackView = UIStackView()
                rowStackView.axis = .horizontal
                rowStackView.spacing = 20
                rowStackView.alignment = .fill
                rowStackView.distribution = .fillEqually
            }
        }
        
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Метод для создания кнопки экспертизы
    func createButton(text: String) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    // Метод для создания "бейджа" со счетчиком
    func createBadgeLabel(with count: Int) -> UILabel {
        let label = UILabel()
        label.text = "\(count)"
        label.textAlignment = .center
        label.backgroundColor = UIColor.red
        label.textColor = .white
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
    
    // Метод для обработки нажатия на кнопку
    @objc func buttonTapped(_ sender: UIButton) {
        let typeIndex = sender.tag  // Используем tag для определения типа экспертизы
        TypeIndex.shared.Index = typeIndex  // Записываем в глобальную переменную индекс нажатой кнопки
        print("Выбранная экспертиза с типом: \(TypeIndex.shared.Index ?? -1)")
        
        let storyboard = UIStoryboard(name: "DetailsOrderViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "DetailsOrderViewController")as! DetailsOrderViewController
        present(vsa,animated: true)
    }
}
