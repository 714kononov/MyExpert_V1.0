import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct Order: Identifiable {
    var id: String = UUID().uuidString
    var userName: String?
    var date: String?
    var userText: String?
    var typeExpertiza: Int?
    var price: Int?
    var pay: Int?
    var expertID: String?
    var expertName: String?
    var result: Int?
    var status: Int?
    var userID: String?
    var file: String?
    var userAudio: String?
    var expertAnswer: String?
}

class TypeViewController: UIViewController {
    
    var types: [String] = ["ДТП", "Окон", "Заливов", "Обуви", "Одежды", "Строительная", "Бытовая техника", "Шуб", "Телефонов", "Мебель", "Переоценка кадастровой стоимости","Другое"]
    var selectedType: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
           view.addGestureRecognizer(tapGesture)
        
            
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        let H1 = UITextView()
        let fullText = "Шаг третий"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let orangeColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        let rangeForOrangeText = (fullText as NSString).range(of: "Шаг")
        attributedString.addAttribute(.foregroundColor, value: orangeColor, range: rangeForOrangeText)
        
        let rangeForWhiteText = (fullText as NSString).range(of: "третий")
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: rangeForWhiteText)
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 30), range: NSMakeRange(0, attributedString.length))
        
        H1.attributedText = attributedString
        H1.backgroundColor = .clear
        H1.isScrollEnabled = false
        H1.isEditable = false
        H1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(H1)
        
        let text1 = UITextView()
        text1.text = "Укажите вид желаемой экспертизы"
        text1.font = UIFont.systemFont(ofSize: 20)
        text1.textColor = .white
        text1.backgroundColor = .clear
        text1.isScrollEnabled = false
        text1.isEditable = false
        text1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(text1)
        
        NSLayoutConstraint.activate([
            H1.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            H1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text1.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 20),
            text1.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        var previousLeftButton: UIButton? = nil
        var previousRightButton: UIButton? = nil
        
        let buttonSpacing: CGFloat = 20.0
        
        for (index, type) in types.enumerated() {
            let button = createButton(title: type)
            button.tag = index + 1
            button.addTarget(self, action: #selector(typeExpertiza(_:)), for: .touchUpInside)
            view.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            if index % 2 == 0 {
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
                if let previous = previousLeftButton {
                    button.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: buttonSpacing).isActive = true
                } else {
                    button.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 40).isActive = true
                }
                previousLeftButton = button
            } else {
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
                if let previous = previousRightButton {
                    button.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: buttonSpacing).isActive = true
                } else {
                    button.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 40).isActive = true
                }
                previousRightButton = button
            }
        }
        
        let prevButton = createButton(title: "Назад")
        prevButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(prevButton)
        
        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            prevButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            prevButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            prevButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.titleLabel?.numberOfLines = 0 // Позволяет неограниченное количество строк
        button.titleLabel?.lineBreakMode = .byWordWrapping 
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc func typeExpertiza(_ sender: UIButton) {
        selectedType = sender.tag
        UserOrder.shared.userType = selectedType

        // Получаем изображения
        let imagesToUpload: [UIImage] = [
                UserOrder.shared.userPhoto1.flatMap { UIImage(data: $0) },
                UserOrder.shared.userPhoto2.flatMap { UIImage(data: $0) },
                UserOrder.shared.userPhoto3.flatMap { UIImage(data: $0) },
                UserOrder.shared.userPhoto4.flatMap { UIImage(data: $0) }
            ].compactMap { $0 }

        uploadImagesToStorage(images: imagesToUpload) { [weak self] imageUrls in
            guard let self = self else { return }
            if let imageUrls = imageUrls {
                self.saveOrder(imageUrls: imageUrls)
            } else {
                self.errAlert(with: "Ошибка сохранения заказа, обратитесь в тех.поддержку")
                print("Не удалось загрузить изображения.")
            }
        }
    }
    
    func uploadImagesToStorage(images: [UIImage], completion: @escaping ([String]?) -> Void) {
        var imageUrls = [String]()
        let dispatchGroup = DispatchGroup()

        for image in images {
            dispatchGroup.enter()

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                dispatchGroup.leave()
                continue
            }

            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("images/\(imageName).jpg")

            storageRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    self.errAlert(with: "Ошибка сохранения заказа, обратитесь в тех.поддержку")
                    print("Ошибка при загрузке изображения: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        self.errAlert(with: "Ошибка сохранения заказа, обратитесь в тех.поддержку")
                        print("Ошибка при получении ссылки: \(error.localizedDescription)")
                    } else if let imageUrl = url?.absoluteString {
                        imageUrls.append(imageUrl)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(imageUrls.isEmpty ? nil : imageUrls)
        }
    }

    func saveOrder(imageUrls: [String]) {
        let db = Firestore.firestore()

        guard let name = UserOrder.shared.userName,
              let text = UserOrder.shared.userText,
              let type = UserOrder.shared.userType,
              let uid = Auth.auth().currentUser?.uid else {
            self.errAlert(with: "Отсутсвуют обязательные данные для сохранения заказа, попробуйте заново!")
            print("Ошибка: отсутствуют обязательные данные для сохранения заказа.")
            return
        }

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)

        // Загружаем аудиофайл перед сохранением заказа
        uploadAudioToStorage { [weak self] audioUrl in
            guard let self = self else { return }

            let order = Order(
                id: UUID().uuidString,
                userName: name,
                date: formattedDate,
                userText: text,
                typeExpertiza: type,
                price: 0,
                pay: 0,
                expertID: "Не назначен",
                expertName: "Не назначен",
                result: 0,
                status: 0,
                userID: uid,
                file: "",
                userAudio: audioUrl, // Сохраняем ссылку на аудиофайл
                expertAnswer: ""
            )

            let orderData: [String: Any] = [
                "id": order.id,
                "userName": order.userName ?? "",
                "date": order.date ?? "",
                "userText": order.userText ?? "",
                "typeExpertiza": order.typeExpertiza ?? 0,
                "price": order.price ?? 0,
                "pay": order.pay ?? 0,
                "expertID": order.expertID ?? "",
                "expertName": order.expertName ?? "Не назначен",
                "result": order.result ?? 0,
                "status": order.status ?? 0,
                "imageUrls": imageUrls, // Сохраняем массив ссылок на изображения
                "userID": uid,
                "file": "",
                "userAudio": order.userAudio ?? "", // Сохраняем ссылку на аудиофайл
                "expertAnswer": "Ожидайте подтрвеждения заказа от администратора! После подтверждения Вам будет доступен чат с экспертом и оплата заказа. По всем интересующим вопросам обращайтесь в тех.поддержку!"
            ]

            db.collection("users")
                .document(uid)
                .collection("orders")
                .document(order.id)
                .setData(orderData) { error in
                    if let error = error {
                        self.errAlert(with: "Ошибка при сохранении заказа")
                        print("Ошибка при сохранении заказа: \(error.localizedDescription)")
                    } else {
                        print("Заказ успешно сохранен!")
                        let alertController = UIAlertController(title: "Заказ сохранен", message: "Ваш заказ был успешно сохранен.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                            var presentingVC = self.presentingViewController
                            var count = 0
                            while presentingVC?.presentingViewController != nil && count < 2 {
                                presentingVC = presentingVC?.presentingViewController
                                count += 1
                            }
                            presentingVC?.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
        }
    }

    func uploadAudioToStorage(completion: @escaping (String?) -> Void) {
        guard let audioUrl = URL(string: UserOrder.shared.userAudio ?? "") else {
            print("Ошибка: неверный URL для аудиофайла.")
            completion(nil)
            return
        }
        
        do {
            let audioData = try Data(contentsOf: audioUrl)

            let audioName = UUID().uuidString + ".m4a" // Вы можете использовать нужное вам расширение
            let storageRef = Storage.storage().reference().child("audio/\(audioName)")

            storageRef.putData(audioData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Ошибка при загрузке аудио: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Ошибка при получении ссылки: \(error.localizedDescription)")
                        completion(nil)
                    } else if let downloadUrl = url?.absoluteString {
                        completion(downloadUrl) // Вернем URL загруженного аудио
                    }
                }
            }
        } catch {
            print("Ошибка при загрузке данных из аудиофайла: \(error.localizedDescription)")
            completion(nil)
        }
    }



    @objc func backTapped() {
        self.dismiss(animated: true)
    }
    @objc func hideKeyboard() {
        view.endEditing(true) // Скрыть клавиатуру для любого активного текстового поля
    }
    
    private func errAlert(with text: String)
    {
        let uialert = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
        let okaction = UIAlertAction(title: "Ок", style: .default)
        uialert.addAction(okaction)
        present(uialert, animated: true)
    }
}
