import UIKit
import Firebase
import FirebaseAuth
import FirebaseAppCheck


class RegViewController: UIViewController {
    
    class ExpertData {
        static let shared = ExpertData()
        
        // Объявляем свойства как опциональные
        var userEmail: UITextField = UITextField()
        var userPassword: UITextField = UITextField()
        var userPhoneForm: UITextField = UITextField()
        var username: UITextField = UITextField()
        

        // Приватный инициализатор, чтобы предотвратить создание других экземпляров класса
        private init() {}
    }

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
        ExpertData.shared.username.backgroundColor = .black
        ExpertData.shared.username.textColor = .white
        ExpertData.shared.username.borderStyle = .roundedRect
        ExpertData.shared.username.translatesAutoresizingMaskIntoConstraints = false
        ExpertData.shared.username.attributedPlaceholder = NSAttributedString(string: "Имя", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(ExpertData.shared.username)
        
        ExpertData.shared.userPhoneForm.backgroundColor = .black
        ExpertData.shared.userPhoneForm.textColor = .white
        ExpertData.shared.userPhoneForm.borderStyle = .roundedRect
        ExpertData.shared.userPhoneForm.translatesAutoresizingMaskIntoConstraints = false
        ExpertData.shared.userPhoneForm.attributedPlaceholder = NSAttributedString(string: "Номер телефона", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(ExpertData.shared.userPhoneForm)
        
        ExpertData.shared.userEmail.backgroundColor = .black
        ExpertData.shared.userEmail.textColor = .white
        ExpertData.shared.userEmail.borderStyle = .roundedRect
        ExpertData.shared.userEmail.translatesAutoresizingMaskIntoConstraints = false
        ExpertData.shared.userEmail.attributedPlaceholder = NSAttributedString(string: "Почта", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(ExpertData.shared.userEmail)
        
        ExpertData.shared.userPassword.backgroundColor = .black
        ExpertData.shared.userPassword.textColor = .white
        ExpertData.shared.userPassword.borderStyle = .roundedRect
        ExpertData.shared.userPassword.translatesAutoresizingMaskIntoConstraints = false
        ExpertData.shared.userPassword.isSecureTextEntry = true
        ExpertData.shared.userPassword.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(ExpertData.shared.userPassword)
        
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
            H1.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            
            H2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            H2.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 10),
            
            ExpertData.shared.username.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ExpertData.shared.username.topAnchor.constraint(equalTo: H2.bottomAnchor,constant: 10),
            ExpertData.shared.username.widthAnchor.constraint(equalToConstant: 250),
            ExpertData.shared.username.heightAnchor.constraint(equalToConstant: 40),
            
            ExpertData.shared.userEmail.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ExpertData.shared.userEmail.topAnchor.constraint(equalTo: ExpertData.shared.username.bottomAnchor, constant: 10),
            ExpertData.shared.userEmail.widthAnchor.constraint(equalToConstant: 250),
            ExpertData.shared.userEmail.heightAnchor.constraint(equalToConstant: 40),
            
            ExpertData.shared.userPhoneForm.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ExpertData.shared.userPhoneForm.topAnchor.constraint(equalTo: ExpertData.shared.userEmail.bottomAnchor, constant: 10),
            ExpertData.shared.userPhoneForm.widthAnchor.constraint(equalToConstant: 250),
            ExpertData.shared.userPhoneForm.heightAnchor.constraint(equalToConstant: 40),
            
            
            ExpertData.shared.userPassword.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ExpertData.shared.userPassword.topAnchor.constraint(equalTo: ExpertData.shared.userPhoneForm.bottomAnchor, constant: 10),
            ExpertData.shared.userPassword.widthAnchor.constraint(equalToConstant: 250),
            ExpertData.shared.userPassword.heightAnchor.constraint(equalToConstant: 40),
            
            button1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button1.topAnchor.constraint(equalTo: ExpertData.shared.userPassword.bottomAnchor, constant: 10),
            button1.widthAnchor.constraint(equalToConstant: 250),
            button1.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func safedatabase() {
            guard let emailText = ExpertData.shared.userEmail.text, !emailText.isEmpty,
                  let passwordText = ExpertData.shared.userPassword.text,!passwordText.isEmpty,
                  let phoneText = ExpertData.shared.userPhoneForm.text, !phoneText.isEmpty,
                  let nameText = ExpertData.shared.username.text, !nameText.isEmpty else {
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
                    "expertName": nameText,
                    "Access": 0,
                    "phone": phoneText,
                    "uid": uid
                ]
                
                Firestore.firestore().collection("experts").document(uid).setData(userData) { error in
                    if let error = error {
                        self.showAlert(title: "Ошибка", message: "Ошибка при сохранении данных: \(error.localizedDescription)")
                    } else {
                        self.showAlert(title: "Успешно!", message: "Вы успешно зарегистрировались!")
                        print("Успешная регистрация пользователя с почтой \(emailText) и uid \(uid)")
                        self.dismiss(animated: true)
                    }
                }
            }
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
    @objc func hideKeyboard() {
        view.endEditing(true) // Скрыть клавиатуру для любого активного текстового поля
    }
}
