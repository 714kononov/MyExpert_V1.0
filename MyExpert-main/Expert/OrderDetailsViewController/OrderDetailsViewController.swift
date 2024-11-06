import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFAudio
import TinkoffASDKUI
import TinkoffASDKCore



class Chat {
    static let shared = Chat()
    var orderID: String?
    var chatID: String?
}

class Payorder
{
    static let shared = Payorder()
    var orderID: String?
    var email: String?
}

class OrderDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var order: (id: String, expertName: String?, expertAnswer: String, expertID: String?, userName: String, date: String, typeExpertiz: Int, pay: Int, price: Int, result: Int, status: Int, userText: String?, photo1: String?, photo2: String?, photo3: String?, photo4: String?, userAudio: String?)?
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var collectionView: UICollectionView!
    private var photos: [String] = []
    
    private var typeLabel: UILabel!
    private var dateLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var priceLabel: UILabel!
    private var statusLabel: UILabel!
    private var expertNameLabel: UILabel!
    private var text1Answer: UILabel!
    private var expertComment: UILabel!
    private var payButton: UIButton!
    private var chatButton: UIButton!
    private var downloadFile: UIButton!
    private var listenAudio: UIButton!
    private var audioPlayer: AVAudioPlayer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        setupScrollView()
        
        if let order = order {
            displayOrderDetails(order: order)
        }
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Установка constraints для scrollView и contentView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        setupUI()
    }
    
    func setupUI() {
        // Контейнер для текста с черным фоном
        let textContainerView = UIView()
        textContainerView.backgroundColor = .black
        textContainerView.layer.cornerRadius = 10
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textContainerView)
        
        // Добавление UILabel для отображения типа экспертизы
        typeLabel = UILabel()
        typeLabel.font = UIFont.systemFont(ofSize: 18)
        typeLabel.textColor = .white
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(typeLabel)
        
        // Добавление UILabel для отображения даты
        dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 18)
        dateLabel.textColor = .white
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(dateLabel)
    
        
        // Добавление UILabel для отображения описания заказа
        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(descriptionLabel)
        
        // Добавление UILabel для отображения цены
        priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 18)
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(priceLabel)
        
        // Добавление UILabel для отображения статуса
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 18)
        statusLabel.textColor = .white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(statusLabel)
        
        // Добавление UILabel для отображения имени эксперта
        expertNameLabel = UILabel()
        expertNameLabel.font = UIFont.systemFont(ofSize: 18)
        expertNameLabel.textColor = .white
        expertNameLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(expertNameLabel)
        
        // Настройка UICollectionView для фотографий
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 150, height: 150)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        contentView.addSubview(collectionView)
        
        // Контейнер для ответа эксперта
        let answerFromExpert = UIView()
        answerFromExpert.backgroundColor = .black
        answerFromExpert.translatesAutoresizingMaskIntoConstraints = false
        answerFromExpert.layer.cornerRadius = 10
        contentView.addSubview(answerFromExpert)
        
        text1Answer = UILabel()
        text1Answer.font = UIFont.systemFont(ofSize: 18)
        text1Answer.textColor = .white
        text1Answer.numberOfLines = 5
        text1Answer.translatesAutoresizingMaskIntoConstraints = false
        answerFromExpert.addSubview(text1Answer)
        
        let answerExpertText = UILabel()
        answerExpertText.font = UIFont.systemFont(ofSize: 16)
        answerExpertText.textColor = .white
        answerExpertText.numberOfLines = 0
        answerExpertText.translatesAutoresizingMaskIntoConstraints = false
        answerFromExpert.addSubview(answerExpertText)
        
        
        expertComment = UILabel()
        expertComment.font = UIFont.systemFont(ofSize: 18)
        expertComment.textColor = .white
        expertComment.numberOfLines = 0
        expertComment.translatesAutoresizingMaskIntoConstraints = false
        answerFromExpert.addSubview(expertComment)
        
        payButton = UIButton()
        payButton.isHidden = true
        payButton.setTitle("Оплатить", for: .normal)
        payButton.setTitleColor(.white, for: .normal)
        payButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        payButton.layer.cornerRadius = 10
        contentView.addSubview(payButton)
        
        chatButton = UIButton()
        chatButton.isHidden = true
        chatButton.setTitle("Чат с экспертом", for: .normal)
        chatButton.setTitleColor(.white, for: .normal)
        chatButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        chatButton.layer.cornerRadius = 10
        chatButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        contentView.addSubview(chatButton)
        
        downloadFile = UIButton()
        downloadFile.isHidden = true
        downloadFile.setTitle("Скачать экспертизу", for: .normal)
        downloadFile.setTitleColor(.white, for: .normal)
        downloadFile.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        downloadFile.translatesAutoresizingMaskIntoConstraints = false
        downloadFile.addTarget(self, action: #selector(downloadFileTapped), for: .touchUpInside)
        downloadFile.layer.cornerRadius = 10
        contentView.addSubview(downloadFile)
        
        listenAudio = UIButton()
        listenAudio.isHidden = true
        listenAudio.setTitle("Прослушать ГС", for: .normal)
        listenAudio.setTitleColor(.white, for: .normal)
        listenAudio.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        listenAudio.translatesAutoresizingMaskIntoConstraints = false
        listenAudio.layer.cornerRadius = 10
        listenAudio.addTarget(self, action: #selector(listenAudioTapped), for: .touchUpInside)
        textContainerView.addSubview(listenAudio)
        // Установка constraint для элементов интерфейса
        NSLayoutConstraint.activate([
            textContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            textContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            typeLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: 10),
            typeLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            typeLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            
            dateLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            
            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            
            statusLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            
            expertNameLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            expertNameLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            expertNameLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            
            listenAudio.topAnchor.constraint(equalTo: expertNameLabel.bottomAnchor, constant: 10),
            listenAudio.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            listenAudio.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            listenAudio.heightAnchor.constraint(equalToConstant: 30),
            listenAudio.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -10),
            
            collectionView.topAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 150),
            
            answerFromExpert.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            answerFromExpert.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            answerFromExpert.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            text1Answer.topAnchor.constraint(equalTo: answerFromExpert.topAnchor, constant: 10),
            text1Answer.leadingAnchor.constraint(equalTo: answerFromExpert.leadingAnchor, constant: 10),
            text1Answer.trailingAnchor.constraint(equalTo: answerFromExpert.trailingAnchor, constant: -10),

            
            expertComment.topAnchor.constraint(equalTo: text1Answer.bottomAnchor, constant: 10),
            expertComment.leadingAnchor.constraint(equalTo: answerExpertText.leadingAnchor, constant: 10),
            expertComment.trailingAnchor.constraint(equalTo: answerExpertText.trailingAnchor, constant: 10),
            expertComment.bottomAnchor.constraint(equalTo: answerFromExpert.bottomAnchor, constant: -10),
            
            
            payButton.topAnchor.constraint(equalTo: answerFromExpert.bottomAnchor, constant: 20),
            payButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            payButton.heightAnchor.constraint(equalToConstant: 50),
            
            chatButton.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: 20),
            chatButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chatButton.heightAnchor.constraint(equalToConstant: 50),
            
            downloadFile.topAnchor.constraint(equalTo: chatButton.bottomAnchor, constant: 20),
            downloadFile.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            downloadFile.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            downloadFile.heightAnchor.constraint(equalToConstant: 50),
            downloadFile.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    func displayOrderDetails(order: (id: String, expertName: String?,expertAnswer: String, expertID: String?, userName: String, date: String, typeExpertiz: Int, pay: Int, price: Int, result: Int,status:Int, userText: String?, photo1: String?, photo2: String?, photo3: String?, photo4: String?, userAudio: String?)) {
        // Заполнение данных в UILabel
        
        Chat.shared.orderID = order.id
        Payorder.shared.orderID = order.id
        print("ID заказа:\(Chat.shared.orderID)")
        switch order.typeExpertiz {
        case 1: typeLabel.text = "Тип экспертизы: ДТП"
        case 2: typeLabel.text = "Тип экспертизы: Окон"
        case 3: typeLabel.text = "Тип экспертизы: Заливов"
        case 4: typeLabel.text = "Тип экспертизы: Обуви"
        case 5: typeLabel.text = "Тип экспертизы: Одежды"
        case 6: typeLabel.text = "Тип экспертизы: Строительная"
        case 7: typeLabel.text = "Тип экспертизы: Бытовая техника"
        case 8: typeLabel.text = "Тип экспертизы: Шуб"
        case 9: typeLabel.text = "Тип экспертизы: Телефонов"
        case 10: typeLabel.text = "Тип экспертизы: Мебель"
        case 11: typeLabel.text = "Тип экспертизы: ПКС"
        case 12: typeLabel.text = "Тип экспертизы: Другое"
        default: typeLabel.text = "Тип экспертизы: Неизвестно"
        }
        
        dateLabel.text = "Дата заказа: \(order.date)"
        descriptionLabel.text = "Описание: \(order.userText ?? "Нет описания")"
        priceLabel.text = "Цена: \(order.price)₽"
        
        if order.expertName != "Не назначен" {chatButton.isHidden = false}
        if order.price != 0 {payButton.isHidden = false} else {payButton.isHidden = true}
        if order.status == 2 {
            downloadFile.isHidden = false
            payButton.isHidden = true
        } else {downloadFile.isHidden = true}
        
        listenAudio.isHidden = (order.userAudio?.isEmpty ?? true) ? true : false
        
        // Установка статуса заказа
        switch order.status {
        case 0:
            statusLabel.text = "Статус: На рассмотрении"
            text1Answer.text = "Комментарий: Мы получили Ваш заказ и уже изучаем все тонкости, ожидайте!"
        case 1:
            statusLabel.text = "Статус: В работе"
            text1Answer.text = "Комментарий: Заказ в работе, ожидайте готовности заказа"
        case 2:
            statusLabel.text = "Статус: Готов"
            text1Answer.text = "Комментарий: Ура! Заказ готов Вы можете скачать его по кнопке снизу!"
        case 3:
            statusLabel.text = "Статус: Отменен"
            text1Answer.text = "Комментарий: К сожалению заказ был отменен, мы не сможем Вам помочь!"
            payButton.isHidden = true
            downloadFile.isHidden = true
        default:
            statusLabel.text = "Статус: Ошибка"
            text1Answer.text = "Неизвестная ошибка с заказом, обратитесь в тех.поддержку"
        }
        
        if !order.expertAnswer.isEmpty {expertComment.text = "Комментарий эксперта: \(order.expertAnswer)"} else {expertComment.text = "Комментарий эксперта: Отсутствует"}

        
        if order.pay == 1{
                payButton.isHidden = true
            text1Answer.text = "Отлично! Заказ оплачен, мы уже работаем над вашим заказом, ожидайте дальнейших инструкций!"
            }
        
        
        expertNameLabel.text = "Эксперт: \(order.expertName ?? "Не назначен")"
        
        
        // Загружаем фотографии
        if let photo1 = order.photo1 {
            photos.append(photo1)
        }
        if let photo2 = order.photo2 {
            photos.append(photo2)
        }
        if let photo3 = order.photo3 {
            photos.append(photo3)
        }
        if let photo4 = order.photo4 {
            photos.append(photo4)
        }
        
        collectionView.reloadData()
    }
    
    @objc func downloadFileTapped() {
        guard let orderID = Chat.shared.orderID else { return }
        guard let uid = UserSession.shared.userID else { return }
        
        Firestore.firestore().collection("users").document(uid).collection("orders").document(orderID).getDocument { (orderSnapshot, error) in
            if let error = error {
                print("Ошибка выборки: \(error)")
                self.alert(message: "Не удалось открыть заказ, обратитесь в тех.поддержку", title: "Что то пошло не так")
                return
            }
            
            guard let orderSnapshot = orderSnapshot, orderSnapshot.exists else {
                print("Документ не найден")
                self.alert(message: "Не удалось открыть заказ, обратитесь в тех.поддержку", title: "Что то пошло не так")
                return
            }
            
            guard let data = orderSnapshot.data() else {
                print("Ошибка получения данных")
                self.alert(message: "Не удалось открыть заказ, обратитесь в тех.поддержку", title: "Что то пошло не так")
                return
            }
            
            guard let fileURLString = data["file"] as? String,
                  let fileURL = URL(string: fileURLString) else {
                print("Ошибка получения файла заказа: \(orderID)")
                self.alert(message: "Не удалось открыть заказ, обратитесь в тех.поддержку", title: "Что то пошло не так")
                return
            }
            
            // Открываем файл в браузере
            UIApplication.shared.open(fileURL, options: [:]) { success in
                if success {
                    print("Файл открыт успешно")
                } else {
                    self.alert(message: "Не удалось открыть файл, обратитесь в тех.поддержку", title: "Что то пошло не так")
                    print("Не удалось открыть файл")
                }
            }
        }
    }

    
    @objc func chatTapped()
    {
        ChatType.shared.status = 1
        fetchChatID()
    }
    
    var isAudioPlaying = false

    @objc func listenAudioTapped() {
        guard let audioUrlString = order?.userAudio,
              let audioUrl = URL(string: audioUrlString) else {
            self.alert(message: "Произошла ошибка загрузки аудио, обратитесь в тех.поддержку", title: "Что то пошло не так")
            print("Аудио URL недоступен")
            return
        }

        if isAudioPlaying {
            // Остановить воспроизведение
            audioPlayer?.stop()
            isAudioPlaying = false
            listenAudio.setTitle("Прослушать ГС", for: .normal)
        } else {
            // Воспроизведение аудио
            DispatchQueue.global().async { [weak self] in
                do {
                    let audioData = try Data(contentsOf: audioUrl)
                    DispatchQueue.main.async {
                        do {
                            self?.audioPlayer = try AVAudioPlayer(data: audioData)
                            self?.audioPlayer?.prepareToPlay()
                            self?.audioPlayer?.play()
                            self?.isAudioPlaying = true
                            self?.listenAudio.setTitle("Остановить ГС", for: .normal) // Изменяем заголовок кнопки
                        } catch {
                            self?.alert(message: "Произошла ошибка загрузки аудио, обратитесь в тех.поддержку", title: "Что то пошло не так")
                            print("Ошибка воспроизведения аудио: \(error.localizedDescription)")
                        }
                    }
                } catch {
                    self?.alert(message: "Произошла ошибка загрузки аудио, обратитесь в тех.поддержку", title: "Что то пошло не так")
                    print("Ошибка загрузки аудио: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func alert( message: String,  title: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(OKAction)
        self.present(alert, animated: true)
    }



    func fetchChatID() {
        Firestore.firestore().collection("chats").whereField("orderID", isEqualTo: Chat.shared.orderID).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.alert(message: "Не удалось открыть заказ, обратитесь в тех.поддержку", title: "Что то пошло не так")
                print("Ошибка при получении чата по orderID: \(error.localizedDescription)")
                return
            }
            
            // Проверяем, найден ли документ
            if let document = querySnapshot?.documents.first {
                let chatID = document.documentID
                Chat.shared.chatID = chatID
                if chatID != nil
                {
                    let storyboard = UIStoryboard(name: "ChatViewController", bundle: nil)
                    let vsa = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                    vsa.userName = UserSession.shared.userName
                    vsa.userID = UserSession.shared.userID
                    vsa.chatID = Chat.shared.chatID
                    self.present(vsa,animated: true)
                    print("ID чата: \(chatID)")
                }
            } else {
                self.alert(message: "Не удалось открыть чат с экспертом, обратитесь в тех.поддержку", title: "Что то пошло не так")
                print("Чат с таким orderID не найден")
            }
        }
    }
    
    @objc func payTapped()
    {
        let _ = PayModule(vc: self) { result in
            switch result
            {
                
            case .succeeded:
                self.alert(title: "Успешно!", message: "Вы успешно оплатили заказ, чек придет вам на почту, как только мы увидим платеж мы сразу же приступим к работе!")
            case .failed:
                self.alert(title: "Ой ой ой", message: "Произошла ошибка при совершении платежа, попробуйте еще раз!")
            case .cancelled:
                self.alert(title: "Эх..", message: "Вы отменили платеж!")
            }
        }
    }
    
    private func alert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: title, style: .default)
        alert.addAction(OKAction)
        present(alert, animated: true)
    }
    

    
    @objc func doubleTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        let imageUrlString = photos[imageView.tag]
        let imagePreviewVC = ImagePreviewViewController()
        imagePreviewVC.imageUrl = imageUrlString
        self.present(imagePreviewVC, animated: true)
    }

    
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photoUrl = photos[indexPath.item]
        
        // Загрузка изображения с Firebase Storage
        loadImage(from: photoUrl, into: cell.imageView, at: indexPath)
        
        return cell
    }
    
    // MARK: - Image Loading
    
    private func loadImage(from urlString: String, into imageView: UIImageView, at indexPath: IndexPath) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                // Поворачиваем изображение на 90 градусов по часовой стрелке
                let rotatedImage = image.rotate(radians: .pi / 2)
                DispatchQueue.main.async {
                    imageView.image = rotatedImage
                    imageView.layer.cornerRadius = 10
                    imageView.clipsToBounds = true
                    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped))
                    doubleTap.numberOfTapsRequired = 2
                    imageView.isUserInteractionEnabled = true
                    imageView.tag = indexPath.item
                    imageView.addGestureRecognizer(doubleTap)
                }
            }
        }.resume()
    }
    
    // MARK: - PhotoCell
    
    class PhotoCell: UICollectionViewCell {
        let imageView: UIImageView = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(imageView)
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            
            // Установка constraint для imageView
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

private extension UIImage {
    func rotate(radians: CGFloat) -> UIImage? {
        var newSize = CGRect(origin: .zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .size
        newSize.height = ceil(newSize.height)
        newSize.width = ceil(newSize.width)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}


