import UIKit
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ChatType
{
    static let shared = ChatType()
    var status: Int?
}

class EntrViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создаем слой градиента
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        // Добавляем логотип
        let mainLogo = UIImageView()
        mainLogo.image = UIImage(named: "logo_final")
        mainLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLogo)
        
        // Создаем заголовок "Добро пожаловать!"
        let H1 = UILabel()
        guard let usrname = UserSession.shared.userName else {return}
        H1.text = "Добро пожаловать, \(usrname)!"
        H1.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        H1.textColor = .white
        H1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(H1)
        
        // Создаем кнопки
        let orderExpertiz = createButton(title: "Заказать экспертизу")
        let listExpertiz = createButton(title: "Мои экспертизы")
        let techHelp = createButton(title: "Поддержка")
        let aboutUS = createButton(title: "О нас")
        
        //Функции для кнопок
        orderExpertiz.isUserInteractionEnabled = true
        listExpertiz.isUserInteractionEnabled = true
        techHelp.isUserInteractionEnabled = true
        aboutUS.isUserInteractionEnabled = true
        
        //Обработчики кнопок
        let orderAction = UITapGestureRecognizer(target: self, action: #selector(orderTapped))
        orderExpertiz.addGestureRecognizer(orderAction)
        
        let listAction = UITapGestureRecognizer(target: self, action: #selector(listTapped))
        listExpertiz.addGestureRecognizer(listAction)
        
        let techHelpAction = UITapGestureRecognizer(target: self, action: #selector(techHelpTapped))
        techHelp.addGestureRecognizer(techHelpAction)
        
        let aboutUsAction = UITapGestureRecognizer(target: self, action: #selector(aboutUSTapped))
        aboutUS.addGestureRecognizer(aboutUsAction)
        
        
        
        // Создаем StackView для размещения кнопок в виде таблицы
        let buttonStackView = UIStackView(arrangedSubviews: [orderExpertiz, listExpertiz, techHelp, aboutUS])
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 30
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        // Настраиваем Auto Layout
        NSLayoutConstraint.activate([
            
            //Размер лого и его положение
            mainLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -200),
            mainLogo.widthAnchor.constraint(equalToConstant: 100),
            mainLogo.heightAnchor.constraint(equalToConstant: 100),
            
            // Центрируем заголовок по горизонтали и размещаем его чуть выше центра экрана
            H1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            H1.centerYAnchor.constraint(equalTo: mainLogo.bottomAnchor, constant: 20),
            
            // Центрируем StackView по горизонтали и размещаем его под заголовком
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 30),
            buttonStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            buttonStackView.heightAnchor.constraint(equalToConstant: 300) // Высота StackView на основе количества кнопок
            
        ])
    }
    //Функции обратобки нажатия на кнопку
    @objc func orderTapped(){
        let storyboard = UIStoryboard(name: "OrderViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "OrderViewController")as! OrderViewController
        present(vsa,animated: true)
    }
    @objc func listTapped(){
        let storyboard = UIStoryboard(name: "MyOrderViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "MyOrderViewController")as! MyOrderViewController
        present(vsa,animated: true)
    }
    @objc func techHelpTapped(){
            fetchChatID()
    }
    
    func fetchChatID() {
        let uid = Auth.auth().currentUser?.uid
        Firestore.firestore().collection("HelpChats").whereField("userID", isEqualTo: uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Ошибка при получении чата по orderID: \(error.localizedDescription)")
                return
            }

            // Проверяем, найден ли документ
            if let document = querySnapshot?.documents.first {
                let chatID = document.documentID
                Chat.shared.chatID = chatID
                if chatID != nil
                {
                    ChatType.shared.status = 0
                    let storyboard = UIStoryboard(name: "ChatViewController", bundle: nil)
                    let vsa = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                    vsa.userName = UserSession.shared.userName
                    vsa.userID = UserSession.shared.userID
                    vsa.chatID = Chat.shared.chatID
                    self.present(vsa,animated: true)
                    print("ID чата: \(chatID)")
                }
            } else {
                print("Чат с таким orderID не найден")
            }
        }
    }
    @objc func aboutUSTapped(){
        let storyboard = UIStoryboard(name: "AboutUsViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "AboutUsViewController")
        as! AboutUsViewController
        present(vsa, animated: true)
    }
    
    // Функция для создания кнопок
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }
}
