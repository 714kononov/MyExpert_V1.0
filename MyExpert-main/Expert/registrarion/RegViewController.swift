import UIKit
import Firebase
import FirebaseAuth

class UserData {
    static let shared = UserData()
    
    // Объявляем свойства как опциональные
    var userEmail: UITextField = UITextField()
    var userPassword: UITextField = UITextField()
    var userPhoneForm: UITextField = UITextField()
    var username: UITextField = UITextField()
    

    // Приватный инициализатор, чтобы предотвратить создание других экземпляров класса
    private init() {}
}

class TechHelp
{
    static let shared = TechHelp()
    var userID: String?
    var helper: String?
}


class RegViewController: UIViewController {

    let H2 = UILabel()
    let button1 = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Устанавливаем градиентный фон
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.gray.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Создаем первый заголовок
        let H1 = UILabel()
        H1.text = "Добро пожаловать!"
        H1.textColor = .white
        H1.font = UIFont.systemFont(ofSize: 16)
        H1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(H1)
        
        // Создаем второй заголовок
        H2.textColor = .white
        H2.font = UIFont.systemFont(ofSize: 14)
        H2.translatesAutoresizingMaskIntoConstraints = false
        
        // Атрибутированный текст с оранжевым словом "все"
        let text = "Заполните все поля для регистрации"
        let attributedString = NSMutableAttributedString(string: text)
        
        if let range = text.range(of: "все") {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.foregroundColor, value: UIColor.orange, range: nsRange)
        }
        
        H2.attributedText = attributedString
        view.addSubview(H2)
        
        

        // Поля ввода
        UserData.shared.username.backgroundColor = .black
        UserData.shared.username.textColor = .white
        UserData.shared.username.borderStyle = .roundedRect
        UserData.shared.username.translatesAutoresizingMaskIntoConstraints = false
        UserData.shared.username.attributedPlaceholder = NSAttributedString(string: "Имя", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(UserData.shared.username)
        
        UserData.shared.userPhoneForm.backgroundColor = .black
        UserData.shared.userPhoneForm.textColor = .white
        UserData.shared.userPhoneForm.borderStyle = .roundedRect
        UserData.shared.userPhoneForm.keyboardType = .numberPad
        UserData.shared.userPhoneForm.translatesAutoresizingMaskIntoConstraints = false
        UserData.shared.userPhoneForm.attributedPlaceholder = NSAttributedString(string: "Номер телефона", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(UserData.shared.userPhoneForm)
        
        UserData.shared.userEmail.backgroundColor = .black
        UserData.shared.userEmail.textColor = .white
        UserData.shared.userEmail.borderStyle = .roundedRect
        UserData.shared.userEmail.translatesAutoresizingMaskIntoConstraints = false
        UserData.shared.userEmail.attributedPlaceholder = NSAttributedString(string: "Почта", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(UserData.shared.userEmail)
        
        UserData.shared.userPassword.backgroundColor = .black
        UserData.shared.userPassword.textColor = .white
        UserData.shared.userPassword.borderStyle = .roundedRect
        UserData.shared.userPassword.translatesAutoresizingMaskIntoConstraints = false
        UserData.shared.userPassword.isSecureTextEntry = true
        UserData.shared.userPassword.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(UserData.shared.userPassword)
        
        // Кнопка регистрации
        button1.setTitle("Зарегистрироваться", for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button1.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button1.setTitleColor(.white, for: .normal)
        button1.layer.cornerRadius = 10
        button1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button1)
        button1.isUserInteractionEnabled = true
        button1.addTarget(self, action: #selector(safedatabase), for: .touchUpInside)

        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            H1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            H1.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -200),
            
            H2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            H2.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 10),
            
            UserData.shared.username.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            UserData.shared.username.topAnchor.constraint(equalTo: H2.bottomAnchor,constant: 10),
            UserData.shared.username.widthAnchor.constraint(equalToConstant: 250),
            UserData.shared.username.heightAnchor.constraint(equalToConstant: 40),
            
            UserData.shared.userEmail.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            UserData.shared.userEmail.topAnchor.constraint(equalTo: UserData.shared.username.bottomAnchor, constant: 10),
            UserData.shared.userEmail.widthAnchor.constraint(equalToConstant: 250),
            UserData.shared.userEmail.heightAnchor.constraint(equalToConstant: 40),
            
            UserData.shared.userPhoneForm.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            UserData.shared.userPhoneForm.topAnchor.constraint(equalTo: UserData.shared.userEmail.bottomAnchor, constant: 10),
            UserData.shared.userPhoneForm.widthAnchor.constraint(equalToConstant: 250),
            UserData.shared.userPhoneForm.heightAnchor.constraint(equalToConstant: 40),
            
            
            UserData.shared.userPassword.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            UserData.shared.userPassword.topAnchor.constraint(equalTo: UserData.shared.userPhoneForm.bottomAnchor, constant: 10),
            UserData.shared.userPassword.widthAnchor.constraint(equalToConstant: 250),
            UserData.shared.userPassword.heightAnchor.constraint(equalToConstant: 40),
            
            button1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button1.topAnchor.constraint(equalTo: UserData.shared.userPassword.bottomAnchor, constant: 10),
            button1.widthAnchor.constraint(equalToConstant: 250),
            button1.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func safedatabase() {
            guard let emailText = UserData.shared.userEmail.text, !emailText.isEmpty,
                  let passwordText = UserData.shared.userPassword.text,!passwordText.isEmpty,
                  let phoneText = UserData.shared.userPhoneForm.text, !phoneText.isEmpty,
                  let nameText = UserData.shared.username.text, !nameText.isEmpty else {
                showAlert(title: "Ошибка", message: "Заполните все поля")
                return
            }
            
            // Проверка валидности email
            if !isValidEmail(emailText) {
                showAlert(title: "Ошибка", message: "Неверный формат почты")
                return
            }
            
            // Проверка длины пароля
            if passwordText.count < 6 {
                showAlert(title: "Ошибка", message: "Пароль должен быть не менее 6 символов")
                return
            }
            
            print("Регистрация с почтой: \(emailText), паролем: \(passwordText)")
            
            // Регистрация пользователя в Firebase
            Auth.auth().createUser(withEmail: emailText, password: passwordText) { authResult, error in
                if let error = error as NSError? {
                    if let authErrorCode = AuthErrorCode.Code(rawValue: error.code), authErrorCode == .emailAlreadyInUse {
                        self.showAlert(title: "Ошибка", message: "Пользователь с такой почтой уже существует")
                        print("Ошибка регистрации: Почта уже используется")
                    } else {
                        self.showAlert(title: "Ошибка", message: "Ошибка при регистрации")
                        print("Ошибка регистрации: \(error.localizedDescription)")
                    }
                    return
                }
                
                // После успешной регистрации добавляем данные в Firestore
                guard let uid = authResult?.user.uid else { return } // Получаем uid пользователя
                let userData: [String: Any] = [
                    "email": emailText,
                    "password": passwordText,
                    "name": nameText,
                    "phone": phoneText,
                    "uid": uid
                ]
                
                Firestore.firestore().collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        self.showAlert(title: "Ошибка", message: "Ошибка при сохранении данных: \(error.localizedDescription)")
                    } else {
                        self.showAlert(title: "Успешно!", message: "Вы успешно зарегистрировались!")
                        print("Успешная регистрация пользователя с почтой \(emailText) и uid \(uid)")
                        TechHelp.shared.userID = uid
                        self.getHelper()
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    
    func getHelper() {
        Firestore.firestore().collection("experts")
            .whereField("Access", isEqualTo: 2)
            .whereField("phone", isEqualTo: "89033233302") // Добавляем условие для номера телефона
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Ошибка запроса: \(error.localizedDescription)")
                    return
                }
                
                if let document = querySnapshot?.documents.first {
                    let helperID = document.data()["uid"] as? String
                    TechHelp.shared.helper = helperID
                    self.createChatForUserAndExpert(userID: TechHelp.shared.userID ?? "", helperID: TechHelp.shared.helper ?? "")
                } else {
                    print("Нет админа с телефоном босса")
                }
            }

    }

    
    func createChatForUserAndExpert(userID: String, helperID: String) {
        let db = Firestore.firestore()

        // Проверяем, существует ли чат с таким же orderID
        db.collection("HelpChats").whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Ошибка при проверке существования чата: \(error.localizedDescription)")
                return
            }
            
            // Проверяем, найден ли чат с таким orderID
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                print("Чат с таким orderID уже существует")
                return // Чат уже существует, поэтому не создаем новый
            } else {
                // Чат с таким orderID не найден, создаем новый
                let chatID = UUID().uuidString  // генерируем уникальный идентификатор для чата
                let chatData: [String: Any] = [
                    "helperID": helperID,
                    "userID": userID,
                    "createdAt": Timestamp(date: Date())
                ]

                // Создаем документ в коллекции "HelpChats"
                db.collection("HelpChats").document(chatID).setData(chatData) { error in
                    if let error = error {
                        print("Ошибка создания чата: \(error.localizedDescription)")
                    } else {
                        print("Чат успешно создан между помошником и пользователем")
                    }
                }
            }
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // Скрыть клавиатуру для любого активного текстового поля
    }
    
    
    
    // Проверка валидности email с использованием регулярного выражения
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    // Функция для отображения UIAlertController
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "ОК", style: .default)
        alert.addAction(OKAction)
        present(alert, animated: true)
    }
    
}
