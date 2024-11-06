import Firebase
import FirebaseAuth
import UIKit




class UserSession {
    static let shared = UserSession()
    var userName: String?
    var userID: String?
    private init() {}
}

class UserOrder {
    static let shared = UserOrder()
    var userName: String?
    var userText: String?
    var userPhoto1: Data?
    var userPhoto2: Data?
    var userPhoto3: Data?
    var userPhoto4: Data?
    var userType: Int?
    var userAudio: String?
    
    init() {
        self.userName = UserSession.shared.userName
    }
}

class OrderStatus {
    static let shared = OrderStatus()
    var status: Int?
    
    private init() {
        self.status = 0
    }
}

class ViewController: UIViewController {
    
    
    
    let registrationLabel = UILabel()
    let loginTextField = UITextField()
    let successButton = UIButton(type: .system)
    let passwordTextField = UITextField()
    
    // Объявляем mainLogo как свойство класса
    let mainLogo = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Устанавливаем внешний вид представления
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        // Настраиваем логотип
        mainLogo.image = UIImage(named: "logo_final")
        mainLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLogo)
        
        NSLayoutConstraint.activate([
            mainLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            mainLogo.widthAnchor.constraint(equalToConstant: 100),
            mainLogo.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Настраиваем поля ввода
        setupTextFields()
        
        // Настраиваем кнопку "Войти"
        setupLoginButton()
        
        // Настраиваем UILabel для регистрации
        setupRegistrationLabel()
    }
    
    private func setupTextFields() {
        // Поле ввода логина
        // Поле ввода логина
        loginTextField.attributedPlaceholder = NSAttributedString(
            string: "Почта",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        loginTextField.borderStyle = .roundedRect
        loginTextField.backgroundColor = .black
        loginTextField.textColor = .white
        loginTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginTextField)

        // Поле ввода пароля
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Пароль",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = .black
        passwordTextField.textColor = .white
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)


        // Устанавливаем ограничения
        NSLayoutConstraint.activate([
            loginTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginTextField.topAnchor.constraint(equalTo: mainLogo.bottomAnchor, constant: 20), // Это позиционирует его под mainLogo
            loginTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            loginTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20), // Позиционируем его под loginTextField
            passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupLoginButton() {
        successButton.setTitle("Войти", for: .normal)
        successButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        successButton.setTitleColor(.white, for: .normal)
        successButton.layer.cornerRadius = 10
        successButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(successButton)
        
        NSLayoutConstraint.activate([
            successButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            successButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            successButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Обработчик нажатия на кнопку
        successButton.addTarget(self, action: #selector(buttonEntryTapped), for: .touchUpInside)
    }
    
    private func setupRegistrationLabel() {
        registrationLabel.textColor = UIColor.white
        registrationLabel.text = "Зарегистрироваться"
        registrationLabel.font = UIFont.systemFont(ofSize: 14)
        registrationLabel.textAlignment = .center
        registrationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(registrationLabel)
        
        // Устанавливаем ограничения
        NSLayoutConstraint.activate([
            registrationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registrationLabel.topAnchor.constraint(equalTo: successButton.bottomAnchor, constant: 20),
            registrationLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            registrationLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Обработчик нажатия на UILabel
        registrationLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(registrationLabelTapped))
        registrationLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func registrationLabelTapped() {
        let storyboard = UIStoryboard(name: "RegViewController", bundle: nil)
        if let vs = storyboard.instantiateViewController(withIdentifier: "RegViewController") as? RegViewController {
            present(vs, animated: true)
        }
    }
    
    @objc func buttonEntryTapped() {
        guard let loginText = loginTextField.text, !loginText.isEmpty,
              let passwordText = passwordTextField.text, !passwordText.isEmpty else {
            presentAlert(title: "Ошибка", message: "Заполните все поля")
            return
        }
        
        // Аутентификация через Firebase
        Auth.auth().signIn(withEmail: loginText, password: passwordText) { [weak self] result, error in
            if let error = error {
                self?.presentAlert(title: "Ошибка", message: "Упс... что-то пошло не так")
                print("Ошибка авторизации:\(error.localizedDescription)")
            } else {
                // Успешная аутентификация
                let id = result?.user.uid
                
                UserSession.shared.userID = id
                Payorder.shared.email = loginText
                
                Firestore.firestore().collection("users").document(id!).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        if let username = data?["name"] as? String {
                            print("Имя пользователя: \(username)")
                            UserSession.shared.userName = username
                            print("ID Пользователя: \(UserSession.shared.userID)")
                            // Переход на следующий экран
                            let storyboard = UIStoryboard(name: "EntrViewController", bundle: nil)
                            if let vsa = storyboard.instantiateViewController(withIdentifier: "EntrViewController") as? EntrViewController {
                                self?.present(vsa, animated: true)
                            } else {
                                self?.presentAlert(title: "Ошибка", message: "Не удалось найти EntrViewController")
                            }

                        } else {
                            print("Имя пользователя не найдено")
                        }
                    } else {
                        print("Ошибка при получении документа: \(error?.localizedDescription ?? "Неизвестная ошибка")")
                    }
                }
            }
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
        alert.addAction(OKAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // Скрыть клавиатуру для любого активного текстового поля
    }
}
