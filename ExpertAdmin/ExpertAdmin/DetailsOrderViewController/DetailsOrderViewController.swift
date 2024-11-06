import UIKit
import UniformTypeIdentifiers
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Foundation
import MobileCoreServices
import AVFAudio
import UniformTypeIdentifiers


class MoreDetailID {
    static let share = MoreDetailID()
    var id: String?
    var userID: String?
    var currentStatusID: Int?
}


class Chat
{
    static let shared = Chat()
    var orderID: String?
    var chatID: String?
}

class changeOrder {
    static let shared = changeOrder()
    var orderID: String?
    var changeStatusId: Int?
    var price: Int?
    var experdID: String?
    var comment: String?
    var fileURL: String?
    var expertName: String?
    var finishWork: Int?
    var File: String?
}

var types: [String] = ["ДТП", "Окон", "Заливов", "Обуви", "Одежды", "Строительная", "Бытовая техника", "Шуб", "Телефонов", "Мебель", "Переоценка кадастровой стоимости" ]
class DetailsOrderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIDocumentPickerDelegate {

    var order: (id: String, userName: String, userID: String, expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photos: [String], userAudio: String?)?
    var experts: [(id: String, expertName: String)] = []
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var collectionView: UICollectionView!
    private var photos: [String] = []

    private var typeLabel: UILabel!
    private var dateLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var priceLabel: UILabel!
    private var statusLabel: UILabel!
    private var userName: UILabel!
    private var comment: UITextField!
    private var accessbtn: UIButton!
    private var cancelbtn: UIButton!
    private var finishWork: UIButton!
    private var commentbtn: UIButton!
    private var price: UITextField!
    private var savebtn: UIButton!
    private var chooseExpert: UIButton!
    private var expertName: UILabel!
    private var pay:UILabel!
    private var chat: UIButton!
    private var userAudio: UIButton!
    private var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupScrollView()
        setupUI()
        
        // Проверяем, что массив не пустой, и передаем первый элемент
        if let order = order {
            displayOrderDetails(order: order)
        }
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Это важно для вертикального скролла
        ])
    }

    func setupUI() {
        let textContainerView = UIView()
        textContainerView.backgroundColor = .black
        textContainerView.layer.cornerRadius = 10
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textContainerView)

        typeLabel = UILabel()
        typeLabel.font = UIFont.systemFont(ofSize: 18)
        typeLabel.textColor = .white
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(typeLabel)

        dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 18)
        dateLabel.textColor = .white
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(dateLabel)

        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(descriptionLabel)

        priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 18)
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(priceLabel)

        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 18)
        statusLabel.textColor = .white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(statusLabel)

        userName = UILabel()
        userName.font = UIFont.systemFont(ofSize: 18)
        userName.textColor = .white
        userName.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(userName)
        
        expertName = UILabel()
        expertName.font = UIFont.systemFont(ofSize: 18)
        expertName.textColor = .white
        expertName.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(expertName)
        
        pay = UILabel()
        pay.font = UIFont.systemFont(ofSize: 18)
        pay.textColor = .white
        pay.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(pay)
        

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 150, height: 150)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)

        accessbtn = UIButton()
        accessbtn.setTitle("Подтвердить", for: .normal)
        accessbtn.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        accessbtn.setTitleColor(.white, for: .normal)
        accessbtn.layer.cornerRadius = 10
        accessbtn.translatesAutoresizingMaskIntoConstraints = false
        accessbtn.addTarget(self, action: #selector(accessbtnTapped), for: .touchUpInside)
        contentView.addSubview(accessbtn)

        cancelbtn = UIButton()
        cancelbtn.setTitle("Отменить", for: .normal)
        cancelbtn.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        cancelbtn.setTitleColor(.white, for: .normal)
        cancelbtn.layer.cornerRadius = 10
        cancelbtn.translatesAutoresizingMaskIntoConstraints = false
        cancelbtn.addTarget(self, action: #selector(cancelbtnTapped), for: .touchUpInside)
        contentView.addSubview(cancelbtn)
        
        finishWork = UIButton()
        finishWork.setTitle("Cдать работу", for: .normal)
        finishWork.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        finishWork.setTitleColor(.white, for: .normal)
        finishWork.layer.cornerRadius = 10
        finishWork.translatesAutoresizingMaskIntoConstraints = false
        finishWork.addTarget(self, action: #selector(finishWorkTapped), for: .touchUpInside)
        contentView.addSubview(finishWork)

        commentbtn = UIButton()
        commentbtn.setTitle("Комментарий", for: .normal)
        commentbtn.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        commentbtn.setTitleColor(.white, for: .normal)
        commentbtn.layer.cornerRadius = 10
        commentbtn.translatesAutoresizingMaskIntoConstraints = false
        commentbtn.addTarget(self, action: #selector(commentbtnTapped), for: .touchUpInside)
        contentView.addSubview(commentbtn)

        savebtn = UIButton()
        savebtn.setTitle("Сохранить", for: .normal)
        savebtn.backgroundColor = .red
        savebtn.setTitleColor(.white, for: .normal)
        savebtn.layer.cornerRadius = 10
        savebtn.translatesAutoresizingMaskIntoConstraints = false
        savebtn.addTarget(self, action: #selector(savebtnTapped), for: .touchUpInside)
        contentView.addSubview(savebtn)

        chooseExpert = UIButton()
        chooseExpert.setTitle("Назнач Эксперта", for: .normal)
        chooseExpert.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        chooseExpert.setTitleColor(.white, for: .normal)
        chooseExpert.layer.cornerRadius = 10
        chooseExpert.translatesAutoresizingMaskIntoConstraints = false
        chooseExpert.addTarget(self, action: #selector(chooseExpertTapped), for: .touchUpInside)
        contentView.addSubview(chooseExpert)
        

        comment = UITextField()
        comment.attributedPlaceholder = NSAttributedString(
            string: "Комментарий",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        comment.borderStyle = .roundedRect
        comment.backgroundColor = .black
        comment.textColor = .white
        comment.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(comment)

        price = UITextField()
        price.attributedPlaceholder = NSAttributedString(
            string: "Цена",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        price.borderStyle = .roundedRect
        price.backgroundColor = .black
        price.textColor = .white
        price.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(price)
        
        let button = UIButton()
        button.setTitle("Добавить файл", for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openDocumentPicker), for: .touchUpInside)
        contentView.addSubview(button)
        
        chat = UIButton()
        chat.setTitle("Чат", for: .normal)
        chat.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        chat.setTitleColor(.white, for: .normal)
        chat.layer.cornerRadius = 10
        chat.translatesAutoresizingMaskIntoConstraints = false
        chat.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        contentView.addSubview(chat)
        
        userAudio = UIButton()
        userAudio.setTitle("Прослушать голосовое", for: .normal)
        userAudio.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        userAudio.setTitleColor(.white, for: .normal)
        userAudio.layer.cornerRadius = 10
        userAudio.translatesAutoresizingMaskIntoConstraints = false
        userAudio.addTarget(self, action: #selector(listenAudioTapped), for: .touchUpInside)
        textContainerView.addSubview(userAudio)

        // Устанавливаем ограничения
        NSLayoutConstraint.activate([
            // Позиционируем основной контейнер
            textContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            textContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Элементы внутри textContainerView
            typeLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: 20),
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

            pay.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            pay.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            pay.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            statusLabel.topAnchor.constraint(equalTo: pay.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            userName.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            userName.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            userName.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            expertName.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 10),
            expertName.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            expertName.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            
            userAudio.topAnchor.constraint(equalTo: expertName.bottomAnchor, constant: 10),
            userAudio.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            userAudio.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            userAudio.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -20),

            // Коллекция изображений
            collectionView.topAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 150),

            // Поля "Цена" и "Комментарий"
            price.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            price.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            price.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            price.heightAnchor.constraint(equalToConstant: 40),

            comment.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 20),
            comment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            comment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            comment.heightAnchor.constraint(equalToConstant: 40),

            // Кнопки
            accessbtn.topAnchor.constraint(equalTo: comment.bottomAnchor, constant: 20),
            accessbtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            accessbtn.widthAnchor.constraint(equalToConstant: 170),
            accessbtn.heightAnchor.constraint(equalToConstant: 40),

            cancelbtn.topAnchor.constraint(equalTo: accessbtn.topAnchor),
            cancelbtn.leadingAnchor.constraint(equalTo: accessbtn.trailingAnchor, constant: 20),
            cancelbtn.widthAnchor.constraint(equalToConstant: 170),
            cancelbtn.heightAnchor.constraint(equalToConstant: 40),

            commentbtn.topAnchor.constraint(equalTo: accessbtn.bottomAnchor, constant: 20),
            commentbtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            commentbtn.widthAnchor.constraint(equalToConstant: 170),
            commentbtn.heightAnchor.constraint(equalToConstant: 40),

            chooseExpert.topAnchor.constraint(equalTo: commentbtn.topAnchor),
            chooseExpert.leadingAnchor.constraint(equalTo: commentbtn.trailingAnchor, constant: 20),
            chooseExpert.widthAnchor.constraint(equalToConstant: 170),
            chooseExpert.heightAnchor.constraint(equalToConstant: 40),

            button.topAnchor.constraint(equalTo: chooseExpert.bottomAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            button.widthAnchor.constraint(equalToConstant: 170),
            button.heightAnchor.constraint(equalToConstant: 40),
            
            chat.topAnchor.constraint(equalTo: chooseExpert.bottomAnchor, constant: 20),
            chat.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 20),
            chat.widthAnchor.constraint(equalToConstant: 170),
            chat.heightAnchor.constraint(equalToConstant: 40),
            
            finishWork.topAnchor.constraint(equalTo: chat.bottomAnchor, constant: 20),
            finishWork.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            finishWork.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            finishWork.heightAnchor.constraint(equalToConstant: 40),

            savebtn.topAnchor.constraint(equalTo: finishWork.bottomAnchor, constant: 20),
            savebtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            savebtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            savebtn.heightAnchor.constraint(equalToConstant: 40),

            // Нижний констрейнт для контента
            savebtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])


    }
    var isAudioPlaying = false

    @objc func listenAudioTapped() {
        guard let audioUrlString = order?.userAudio,
              let audioUrl = URL(string: audioUrlString) else {
            print("Аудио URL недоступен")
            return
        }

        if isAudioPlaying {
            // Остановить воспроизведение
            audioPlayer?.stop()
            isAudioPlaying = false
            userAudio.setTitle("Прослушать ГС", for: .normal)
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
                            self?.userAudio.setTitle("Остановить ГС", for: .normal) // Изменяем заголовок кнопки
                        } catch {
                            print("Ошибка воспроизведения аудио: \(error.localizedDescription)")
                        }
                    }
                } catch {
                    print("Ошибка загрузки аудио: \(error.localizedDescription)")
                }
            }
        }
    }

    func displayOrderDetails(order: (id: String, userName: String,userID: String, expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photos: [String], userAudio: String?)) {
        // Обновляем элементы интерфейса на основе заказа
        print("DocID current order: \(order.id)")
        Chat.shared.orderID = order.id
        
        let expertizType = types[order.typeExpertiz - 1]
        typeLabel.text = "Тип: \(expertizType)"
        dateLabel.text = "Дата: \(order.date)"
        descriptionLabel.text = order.userText ?? "Нет описания"
        priceLabel.text = "Цена: \(order.price)"
        statusLabel.text = "Статус: \(order.status)"
        pay.text = order.pay == 0 ? "Оплата: Заказ не оплачен" : "Оплата: Заказ оплачен"
        userName.text = "Заказчик: \(order.userName)"
        expertName.text = "Эксперт: \(order.expertName)"
        MoreDetailID.share.currentStatusID = order.status
        
        userAudio.isHidden = (order.userAudio?.isEmpty ?? true) ? true : false
        // Загружаем фотографии
        photos = order.photos // Сохраняем массив ссылок на фотографии
        print("Ссылки на фото: \(photos)") // Печать всех ссылок на фотографии
        collectionView.reloadData() // Обновляем collectionView для отображения новых данных
    }


    // UICollectionViewDataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count // Возвращаем количество загруженных фотографий
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)

        // Удаляем предыдущие subviews (если ячейка переиспользуется)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        // Создаем UIImageView для изображения
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        // Проверяем, достаточно ли фотографий в массиве
        guard indexPath.row < photos.count else {
            print("Ошибка: недостаточно фотографий в массиве photos для indexPath \(indexPath.row)")
            imageView.image = UIImage(named: "placeholder") // Картинка-заглушка
            cell.contentView.addSubview(imageView)
            return cell
        }

        let imageUrl = photos[indexPath.row]
        
        // Проверяем корректность URL
        if imageUrl.hasPrefix("gs://") || imageUrl.hasPrefix("http://") || imageUrl.hasPrefix("https://") {
            let storageRef = Storage.storage().reference(forURL: imageUrl)

            // Загружаем изображение из Firebase Storage
            storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Ошибка загрузки изображения: \(error)")
                    imageView.image = UIImage(named: "placeholder") // Картинка-заглушка
                } else if let data = data, let image = UIImage(data: data) {
                    let rotatedImage = image.rotate(radians: .pi / 2)
                    imageView.image = rotatedImage
                }
            }
        } else {
            print("Некорректный URL: \(imageUrl)")
            imageView.image = UIImage(named: "placeholder") // Картинка-заглушка
        }

        // Добавляем UITapGestureRecognizer
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(doubleTap)

        // Добавляем UIImageView в ячейку
        cell.contentView.addSubview(imageView)

        return cell
    }


    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            var superview = imageView.superview
            while superview != nil, !(superview is UICollectionViewCell) {
                superview = superview?.superview
            }
            
            if let cell = superview as? UICollectionViewCell, // Убедимся, что нашли ячейку
               let indexPath = collectionView.indexPath(for: cell) { // Получаем indexPath ячейки
                let imageUrl = photos[indexPath.row]
                print("нажата фотка: \(imageUrl)") // Получаем URL изображения
                openFullImage(with: imageUrl) // Открываем полный просмотр изображения
            }
        }
    }


    func openFullImage(with imageUrl: String) {
        print("Открыта полная версия фотки")
        let fullImageVC = UIStoryboard(name: "FullImageViewController", bundle: nil)
        let vsa = fullImageVC.instantiateViewController(withIdentifier: "FullImageViewController")as! FullImageViewController// Ваш контроллер для отображения полной версии
        vsa.imageUrl = imageUrl // Передаем ссылку на изображение
        self.present(vsa, animated: true, completion: nil)
    }




    @objc func accessbtnTapped() {
        let alert = UIAlertController(title: "Подтверждение", message: "Вы подтвердили заказ", preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(OKAction)
        present(alert,animated: true)
        changeOrder.shared.changeStatusId = 1
        MoreDetailID.share.currentStatusID = 1
        changeOrder.shared.comment = "Заказ подтвержден, оплатите его по кнопке снизу"
    }

    @objc func cancelbtnTapped() {
        let alert = UIAlertController(title: "Отмена", message: "Вы отменили заказ", preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(OKAction)
        present(alert,animated: true)
        changeOrder.shared.changeStatusId = 3
        MoreDetailID.share.currentStatusID = 3
        changeOrder.shared.comment = "Заказ отменен, к сожалению мы не сможем Вам помочь"
    }

    @objc func commentbtnTapped() {
        if let text = comment.text, !text.isEmpty
        {
            changeOrder.shared.comment = text
            let alert = UIAlertController(title: "Отлично!", message: "Вы записали комментарий заказчику", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(OKAction)
            changeOrder.shared.changeStatusId = MoreDetailID.share.currentStatusID
            present(alert,animated: true)
        }else
        {
            let alert = UIAlertController(title: "Ошибка", message: "Поле комментария пустое", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(OKAction)
            present(alert,animated: true)
        }
    }

    @objc func savebtnTapped() {
        guard let orderID = MoreDetailID.share.id else {
            print("Ошибка: orderID не установлен")
            return
        }
        guard let userID = MoreDetailID.share.userID else
        {
            print("Ошибка: userID не установлен")
            return
        }

        // Создаем словарь с изменениями
        var updates: [String: Any] = [:]
        
        // Проверяем, нужно ли обновить цену
        if let newPriceText = price.text, let newPrice = Int(newPriceText) {
            updates["price"] = newPrice
        }

        // Проверяем, нужно ли назначить эксперта
        if let expertID = changeOrder.shared.experdID {
            updates["expertID"] = expertID // или другое поле для ID эксперта
            updates["expertName"] = changeOrder.shared.expertName
        }
        if let comment = changeOrder.shared.comment
        {
            updates["expertAnswer"] = comment
            updates["status"] = changeOrder.shared.changeStatusId
        }
        if let save = changeOrder.shared.finishWork
        {
            updates["status"] = changeOrder.shared.changeStatusId
            print("Статус заказа изменен на : \(changeOrder.shared.changeStatusId)")
            updates["expertAnswer"] = changeOrder.shared.comment
            changeOrder.shared.finishWork = 0
        }
        if let file = changeOrder.shared.fileURL
        {
            updates["file"] = file
        }

        // Обновляем документ в Firestore
        Firestore.firestore().collection("users").document(userID).collection("orders").document(orderID).updateData(updates) { error in
            if let error = error {
                print("Ошибка обновления заказа: \(error)")
                let alertPrev = UIAlertController(title: "Ошибка!", message: "Данные заказа не были обновлены!", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                alertPrev.addAction(OKAction)
                self.present(alertPrev,animated: true)
                
            } else {
                print("Заказ успешно обновлен")
                // Можно добавить логику для обновления UI или уведомления пользователя
                if changeOrder.shared.changeStatusId != 0 {
                    self.createChatForUserAndExpert(userID: userID, expertID: Expert.shared.id ?? "", orderID: orderID)
                }
                let alertPrev = UIAlertController(title: "Успешно!", message: "Данные заказа успешно обновлены!", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                alertPrev.addAction(OKAction)
                self.present(alertPrev,animated: true)
            }
        }
    }


    @objc func chooseExpertTapped() {
        fetchExperts()
    }

    private func fetchExperts() {
        self.experts.removeAll()
        Firestore.firestore().collection("experts").getDocuments { (snapshot, error) in
            if let error = error {
                print("Ошибка получения документа: \(error)")
                return
            }
            for document in snapshot!.documents {
                let usrID = document.documentID
                guard let data = document.data() as? [String: Any] else {
                    print("Ошибка получения данных документа")
                    return
                }
                guard let usrName = data["expertName"] as? String else {
                    print("Ошибка получения имени эксперта")
                    return
                }
                self.experts.append((id: usrID, expertName: usrName))
            }
            
            // После загрузки экспертов отображаем UIAlertController
            self.presentExpertSelectionAlert()
        }
    }

    private func presentExpertSelectionAlert() {
        let alert = UIAlertController(title: "Выберите эксперта", message: nil, preferredStyle: .alert)

        for expert in experts {
            alert.addAction(UIAlertAction(title: expert.expertName, style: .default, handler: { _ in
                print("Эксперт: \(expert.expertName)\n ID: \(expert.id)")
                changeOrder.shared.experdID = expert.id
                changeOrder.shared.expertName = expert.expertName
            }))
        }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func openDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        // Запрос разрешения на доступ к защищенному ресурсу
        guard url.startAccessingSecurityScopedResource() else {
            print("Не удалось получить доступ к защищенному ресурсу")
            return
        }
        
        let fileName = url.lastPathComponent
        let storageRef = Storage.storage().reference().child("files/\(fileName)")
        
        do {
            let fileData = try Data(contentsOf: url) // Загрузка данных файла
            storageRef.putData(fileData, metadata: nil) { metadata, error in
                url.stopAccessingSecurityScopedResource() // Остановите доступ к защищенному ресурсу после завершения
                
                if let error = error {
                    print("Ошибка загрузки файла: \(error)")
                    return
                }
                
                storageRef.downloadURL { (downloadURL, error) in
                    if let error = error {
                        print("Ошибка получения URL файла: \(error)")
                        return
                    }
                    
                    if let downloadURL = downloadURL {
                        // Вызываем метод checkPay с замыканием
                        self.checkPay { payStatus in
                            if payStatus == 1 {
                                changeOrder.shared.fileURL = downloadURL.absoluteString
                                let alertPrev = UIAlertController(title: "Файл добавлен", message: "Файл был добавлен в заказ, пользователь может его скачать", preferredStyle: .actionSheet)
                                let OKAction = UIAlertAction(title: "Ок", style: .default)
                                alertPrev.addAction(OKAction)
                                self.present(alertPrev, animated: true)
                                print("Ссылка на файл: \(downloadURL)")
                            } else {
                                let alertPrev = UIAlertController(title: "Ошибка!", message: "Заказ не оплачен! Нельзя добавить файл до оплаты", preferredStyle: .actionSheet)
                                let OKAction = UIAlertAction(title: "Ок", style: .default)
                                alertPrev.addAction(OKAction)
                                self.present(alertPrev, animated: true)
                            }
                        }
                    }
                }
            }
        } catch {
            print("Ошибка загрузки данных файла: \(error.localizedDescription)")
            url.stopAccessingSecurityScopedResource() // Не забудьте остановить доступ к ресурсу в случае ошибки
        }
    }

    func checkPay(completion: @escaping (Int) -> Void) {
        guard let uid = MoreDetailID.share.userID else { return }
        guard let orderID = MoreDetailID.share.id else { return }
        
        Firestore.firestore().collection("users").document(uid).collection("orders").document(orderID).getDocument { (orderSnapshot, error) in
            if let error = error {
                print("Ошибка запроса: \(error)")
                completion(0) // Возвращаем 0 в случае ошибки
                return
            }
            
            guard let orderSnapshot = orderSnapshot, orderSnapshot.exists else {
                print("Документ не найден: \(orderID)")
                completion(0) // Возвращаем 0, если документ не найден
                return
            }
            
            guard let data = orderSnapshot.data() else {
                print("Ошибка получения данных")
                completion(0) // Возвращаем 0, если данные не получены
                return
            }
            
            guard let pay = data["pay"] as? Int else {
                print("Ошибка извлечения полей заказа: \(orderID)")
                completion(0) // Возвращаем 0, если не удалось извлечь значение
                return
            }
            
            let res = pay == 1 ? 1 : 0
            completion(res) // Возвращаем результат через замыкание
        }
    }

        // Обработка ошибки
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Выбор файла отменен")
        }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // Скрыть клавиатуру для любого активного текстового поля
    }
    
    @objc func finishWorkTapped() {
        guard let uid = MoreDetailID.share.userID else { return }
        guard let orderID = MoreDetailID.share.id else { return }
        
        Firestore.firestore().collection("users").document(uid).collection("orders").document(orderID).getDocument { (orderSnapshot, error) in
            if let error = error {
                print("Ошибка получения заказа: \(error)")
                return
            }
            
            guard let orderSnapshot = orderSnapshot, orderSnapshot.exists else {
                print("Документ заказа не найден")
                return
            }
            
            guard let data = orderSnapshot.data() as? [String: Any] else {
                print("Ошибка получения данных документа")
                return
            }
            
            guard let userName = data["userName"] as? String,
                  let date = data["date"] as? String,
                  let typeExpertiz = data["typeExpertiza"] as? Int,
                  let pay = data["pay"] as? Int,
                  let status = data["status"] as? Int,
                  let price = data["price"] as? Int,
                  let file = data["file"] as? String,
                  let expertName = data["expertName"] as? String,
                  let imageUrls = data["imageUrls"] as? [String] else {
                print("Ошибка при извлечении обязательных полей")
                return
            }
            
            let userText = data["userText"] as? String
            let photos = imageUrls.filter { !$0.isEmpty }
            
            // Проверка условий
            if pay == 1, !file.isEmpty{
                let order = (
                    id: orderID,
                    userName: userName,
                    userID: uid,
                    expertName: expertName,
                    date: date,
                    typeExpertiz: typeExpertiz,
                    pay: pay,
                    status: status,
                    userText: userText,
                    price: price,
                    photos: photos
                )
                changeOrder.shared.finishWork = 1
                changeOrder.shared.changeStatusId = 2
                changeOrder.shared.comment = "Ура, работа готова! Вы можете скачать файл по кнопке снизу, если у вас остались какие то вопросы вы можете написать эксперту или в тех.поддержку! Спасибо что выбрали нас!"
                let alertPrev = UIAlertController(title: "Вы уверены?", message: "Пожалуйста проверьте всю необходимую информацию перед сдачей работы", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Сдать", style: .default)
                let NoAction = UIAlertAction(title: "Проверить", style: .default)
                alertPrev.addAction(OKAction)
                alertPrev.addAction(NoAction)
                self.present(alertPrev, animated: true)
                // Обработка объекта order
            } else {
                print("Проверка не пройдена: Убедитесь, что pay = 1")
                let action = UIAlertController(title: "Ошибка", message: "Заказ не оплачен или файл с экспертизой не добавлен", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)}
                action.addAction(OKAction)
                self.present(action, animated: true)
            }
        }
    }

    
    
    @objc func chatTapped()
    {   if let usID = MoreDetailID.share.id
        {
            ChatType.shared.status = 1
            fetchChatID()
        }
    }
    
    func fetchChatID() {
        Firestore.firestore().collection("chats").whereField("orderID", isEqualTo: Chat.shared.orderID).getDocuments { (querySnapshot, error) in
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
                    print("ID чата: \(chatID)")
                    let storyboard = UIStoryboard(name: "ChatViewController", bundle: nil)
                    let vsa = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                    vsa.userName = Expert.shared.name
                    vsa.userID = Expert.shared.id
                    vsa.chatID = Chat.shared.chatID
                    print("ID чата перед открытием:\(Chat.shared.chatID)")
                    self.present(vsa , animated: true)
                }
            } else {
                print("Чат с таким orderID не найден")
            }
        }
    }


    
    func createChatForUserAndExpert(userID: String, expertID: String, orderID: String) {
        let db = Firestore.firestore()

        // Проверяем, существует ли чат с таким же orderID
        db.collection("chats").whereField("orderID", isEqualTo: orderID).getDocuments { (querySnapshot, error) in
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
                    "orderID": orderID,
                    "expertID": expertID,
                    "userID": userID,
                    "createdAt": Timestamp(date: Date())
                ]

                // Создаем документ в коллекции "chats"
                db.collection("chats").document(chatID).setData(chatData) { error in
                    if let error = error {
                        print("Ошибка создания чата: \(error.localizedDescription)")
                    } else {
                        print("Чат успешно создан между экспертом и пользователем")
                    }
                }
            }
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
