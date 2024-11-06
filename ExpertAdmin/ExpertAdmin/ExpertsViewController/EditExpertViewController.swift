import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore

class experts{
    static let shared = experts()
    var id:String?
    var name: String?
    var access: Int?
    var phone: String?
}

class EditExpertViewController: UIViewController {
    
    var nameField: UITextField!
    var accessField: UITextField!
    var phoneField: UITextField!
    var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        fetchExpert()
        setupUI()
    }
    
    private func fetchExpert() {
        guard let docID = MoreDetailID.share.id else { return }

        Firestore.firestore().collection("experts").document(docID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching expert: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                let data = document.data()
                
                guard let name = data?["expertName"] as? String,
                      let access = data?["Access"] as? Int,
                      let phone = data?["phone"] as? String else {
                    print("Ошибка получения данных документа")
                    return
                }
                
                experts.shared.id = document.documentID
                experts.shared.name = name
                experts.shared.access = access
                experts.shared.phone = phone
                
                // Обновляем текстовые поля после получения данных
                self.nameField.text = name
                self.accessField.text = "\(access)"
                self.phoneField.text = phone
                
                print("Expert name: \(name)")
                print("Access: \(access)")
                print("Phone: \(phone)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func setupUI() {
        nameField = createTextField(placeholder: "Имя эксперта")
        accessField = createTextField(placeholder: "Доступ")
        phoneField = createTextField(placeholder: "Телефон")
        
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(.white, for: .normal) // Устанавливаем белый цвет текста
        saveButton.backgroundColor = .red // Устанавливаем черный фон для контраста

        // Добавляем обводку черного цвета
        saveButton.layer.cornerRadius = 4
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        
        // Добавляем элементы на экран
        view.addSubview(nameField)
        view.addSubview(accessField)
        view.addSubview(phoneField)
        view.addSubview(saveButton)
        
        // Расставляем Constraints для элементов
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            accessField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            accessField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            accessField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            phoneField.topAnchor.constraint(equalTo: accessField.bottomAnchor, constant: 20),
            phoneField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: 40),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 300),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .black
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    @objc func saveButtonTapped() {
        //guard let uid = Auth.auth().currentUser?.uid else { return }

        // Получаем ссылку на документ с указанным ID заказа
        guard let userID = MoreDetailID.share.id else { return }

        
        let orderRef = Firestore.firestore().collection("experts").document(userID)
        
        experts.shared.name = nameField.text
        // Преобразуем текст из accessField в целое число
        if let accessText = accessField.text, let accessValue = Int(accessText) {
            experts.shared.access = accessValue  // Присваиваем преобразованное значение
        } else {
            experts.shared.access = 0  // Значение по умолчанию, если преобразование не удалось
        }

        experts.shared.phone = phoneField.text
        
        print("\(experts.shared.name = nameField.text)\n",
              "\(experts.shared.access)",
             "\(experts.shared.phone = phoneField.text)")
        
        // Выполняем обновление полей
        orderRef.updateData([
            "expertName": experts.shared.name ?? "",  // Обновление статуса
            "Access": experts.shared.access ?? 0,    // Обновление цены
            "phone": experts.shared.phone ?? ""
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                let alert = UIAlertController(title: "Ошибка", message: "Ошибка сохранения изменений", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(OKAction)
                self.present(alert,animated: true)
            } else {
                print("Document successfully updated")
                let alert = UIAlertController(title: "Успешно", message: "Вы успешно внесли изменения в заказ", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(OKAction)
                self.present(alert,animated: true)
            }
        }
    }
}
