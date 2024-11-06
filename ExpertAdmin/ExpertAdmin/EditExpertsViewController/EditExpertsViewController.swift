import UIKit
import SQLite3
import MobileCoreServices

class EditExpertsViewController: UIViewController {
    
    var db: OpaquePointer?
    
    var Expertname: UITextField!
    var Expertaccess: UITextField!
    var Expertphone: UITextField!
    var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        // Подключение к базе данных
        connectToDatabase()
        
        // Настройка интерфейса
        setupInterface()
        
        // Загрузка данных об эксперте
        loadExpertDetails()
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
        // Поле для имени эксперта
        Expertname = UITextField()
        Expertname.backgroundColor = .darkGray
        Expertname.textColor = .white
        Expertname.borderStyle = .roundedRect
        Expertname.placeholder = "Имя эксперта"
        Expertname.translatesAutoresizingMaskIntoConstraints = false
        if let expertName = Expertname {
            expertName.isEnabled = false
        } else {
            print("Expertphone is nil")
        }
        view.addSubview(Expertname)
        
        // Поле для уровня доступа
        Expertaccess = UITextField()
        Expertaccess.backgroundColor = .darkGray
        Expertaccess.textColor = .white
        Expertaccess.borderStyle = .roundedRect
        Expertaccess.placeholder = "Уровень доступа"
        Expertaccess.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(Expertaccess)
        
        // Поле для телефона эксперта
        Expertphone = UITextField()
        Expertphone.backgroundColor = .darkGray
        Expertphone.textColor = .white
        Expertphone.borderStyle = .roundedRect
        Expertphone.placeholder = "Телефон эксперта"
        Expertphone.translatesAutoresizingMaskIntoConstraints = false
        if let expertPhone = Expertphone
        {
            expertPhone.isEnabled = false
        }else{
            print("ExpertPhone is nil")
        }
      
        view.addSubview(Expertphone)
        
        // Кнопка для сохранения изменений
        saveButton = UIButton()
        saveButton.setTitle("Сохранить изменения", for: .normal)
        saveButton.backgroundColor = .orange
        saveButton.layer.cornerRadius = 10
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        view.addSubview(saveButton)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            Expertname.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            Expertname.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            Expertname.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            Expertaccess.topAnchor.constraint(equalTo: Expertname.bottomAnchor, constant: 20),
            Expertaccess.leadingAnchor.constraint(equalTo: Expertname.leadingAnchor),
            Expertaccess.trailingAnchor.constraint(equalTo: Expertname.trailingAnchor),
            
            Expertphone.topAnchor.constraint(equalTo: Expertaccess.bottomAnchor, constant: 20),
            Expertphone.leadingAnchor.constraint(equalTo: Expertaccess.leadingAnchor),
            Expertphone.trailingAnchor.constraint(equalTo: Expertaccess.trailingAnchor),
            
            saveButton.topAnchor.constraint(equalTo: Expertphone.bottomAnchor, constant: 40),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Загрузка данных об эксперте
    func loadExpertDetails() {
        guard let id = expert.shared.ID else {
            print("ID Эксперта не найден")
            return
        }
        
        let query = "SELECT name, access, phone FROM Experts WHERE id = ?"
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
            let name = String(cString: sqlite3_column_text(statement, 0))
            let access = Int(sqlite3_column_int(statement, 1))
            let phone = String(cString: sqlite3_column_text(statement, 2))
            
            Expertname.text = name
            Expertaccess.text = String(access)
            Expertphone.text = phone
        } else {
            print("Эксперт не найден.")
        }
        
        sqlite3_finalize(statement)
    }
    
    // Сохранение изменений в БД
    @objc func saveChanges() {
        guard let id = expert.shared.ID,
              let name = Expertname.text,
              let accessText = Expertaccess.text, let access = Int(accessText),
              let phone = Expertphone.text else {
            print("Некорректные данные для сохранения")
            return
        }
        
        print("Данные перед сохранением, ИМЯ:\(name), КОД Доступа: \(accessText), телефон:\(phone)")
        
        let updateQuery = "UPDATE Experts SET Name = ?, Access = ? WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
            return
        }
        
        // Привязываем параметры
        if sqlite3_bind_text(statement, 1, name, -1, nil) != SQLITE_OK ||  // name привязывается к первому параметру
            sqlite3_bind_int(statement, 2, Int32(access)) != SQLITE_OK ||   // access привязывается ко второму
            sqlite3_bind_int(statement, 3, Int32(id)) != SQLITE_OK {        // id привязывается к третьему
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметров: \(errmsg)")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Данные эксперта успешно обновлены")
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при обновлении данных: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
    }
}
