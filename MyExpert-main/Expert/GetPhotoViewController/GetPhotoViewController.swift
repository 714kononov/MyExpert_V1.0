import UIKit

class GetPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageViews: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        let H1 = UITextView()
        
        // Создаем атрибутированную строку для H1
        let fullText = "Шаг второй"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Определяем диапазон для слова "Шаг" и задаем ему оранжевый цвет
        let orangeColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        let rangeForOrangeText = (fullText as NSString).range(of: "Шаг")
        attributedString.addAttribute(.foregroundColor, value: orangeColor, range: rangeForOrangeText)
        
        // Определяем диапазон для слова "второй" и задаем ему белый цвет
        let rangeForWhiteText = (fullText as NSString).range(of: "второй")
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: rangeForWhiteText)
        
        // Устанавливаем шрифт для всего текста
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 30), range: NSMakeRange(0, attributedString.length))
        
        // Применяем атрибутированную строку к UITextView
        H1.attributedText = attributedString
        H1.backgroundColor = .clear
        H1.isScrollEnabled = false
        H1.isEditable = false
        H1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(H1)
        
        let text1 = createText(withText: "Сделай фотографию Вашего недостатка")
        view.addSubview(text1)
        
        // Создаем 4 UIImageView для отображения выбранных изображений
        for _ in 0..<4 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            
            // Добавляем "плюсик" в центр UIImageView
            let plusImageView = UIImageView(image: UIImage(systemName: "plus"))
            plusImageView.tintColor = .white
            plusImageView.translatesAutoresizingMaskIntoConstraints = false
            plusImageView.tag = 100 // Используем этот тег, чтобы скрыть "плюсик" после добавления изображения
            imageView.addSubview(plusImageView)
            
            NSLayoutConstraint.activate([
                plusImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                plusImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                plusImageView.widthAnchor.constraint(equalToConstant: 40),
                plusImageView.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            view.addSubview(imageView)
            imageViews.append(imageView)
        }
        
        // Отступы между изображениями
        let horizontalSpacing: CGFloat = 10.0
        let verticalSpacing: CGFloat = 10.0
        
        // Размещаем 4 UIImageView в два ряда по два
        NSLayoutConstraint.activate([
            H1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            H1.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            text1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text1.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 20),
            text1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            imageViews[0].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageViews[0].topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 20),
            imageViews[0].widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            imageViews[0].heightAnchor.constraint(equalTo: imageViews[0].widthAnchor),
            
            imageViews[1].leadingAnchor.constraint(equalTo: imageViews[0].trailingAnchor, constant: horizontalSpacing),
            imageViews[1].topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 20),
            imageViews[1].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageViews[1].widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            imageViews[1].heightAnchor.constraint(equalTo: imageViews[1].widthAnchor),
            
            imageViews[2].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageViews[2].topAnchor.constraint(equalTo: imageViews[0].bottomAnchor, constant: verticalSpacing),
            imageViews[2].widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            imageViews[2].heightAnchor.constraint(equalTo: imageViews[2].widthAnchor),
            
            imageViews[3].leadingAnchor.constraint(equalTo: imageViews[2].trailingAnchor, constant: horizontalSpacing),
            imageViews[3].topAnchor.constraint(equalTo: imageViews[1].bottomAnchor, constant: verticalSpacing),
            imageViews[3].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageViews[3].widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            imageViews[3].heightAnchor.constraint(equalTo: imageViews[3].widthAnchor)
        ])
        
        // Кнопки "Назад" и "Далее"
        let prevButton = createButton(title: "Назад")
        let nextButton = createButton(title: "Далее")
        view.addSubview(prevButton)
        view.addSubview(nextButton)
        
        prevButton.isUserInteractionEnabled = true
        nextButton.isUserInteractionEnabled = true
        
        let nextAction = UITapGestureRecognizer(target: self, action: #selector(nextTapped))
        nextButton.addGestureRecognizer(nextAction)
        
        let prevAction = UITapGestureRecognizer(target: self, action: #selector(prevTapped))
        prevButton.addGestureRecognizer(prevAction)
        
        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            prevButton.topAnchor.constraint(equalTo: imageViews[2].bottomAnchor, constant: 60),
            prevButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            prevButton.heightAnchor.constraint(equalToConstant: 40),
            
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.topAnchor.constraint(equalTo: imageViews[2].bottomAnchor, constant: 60),
            nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            nextButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func createText(withText text: String) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.text = text
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
    
    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc func nextTapped() {
        // Проверка, что хотя бы одно изображение выбрано
        let selectedImages = imageViews.filter { $0.image != nil }
        
        if selectedImages.count > 0 {
            let storyboard = UIStoryboard(name: "TypeViewController", bundle: nil)
            let vsa = storyboard.instantiateViewController(withIdentifier: "TypeViewController") as! TypeViewController
            present(vsa, animated: true)
            
        } else {
            // Если ни одно изображение не выбрано, показать ошибку
            let errorAlert = UIAlertController(title: "Ошибка", message: "Пожалуйста, выберите хотя бы одно изображение.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
            errorAlert.addAction(OKAction)
            present(errorAlert, animated: true, completion: nil)
        }
    }
    
    @objc func prevTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if let tappedImageView = sender.view as? UIImageView, let index = imageViews.firstIndex(of: tappedImageView) {
            selectImage(for: index)
        }
    }
    
    func selectImage(for index: Int) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            imagePickerController.view.tag = index // Используем tag для определения, какой UIImageView был нажат
            present(imagePickerController, animated: true, completion: nil)
        } else {
            // Если камера недоступна (например, на симуляторе), можно выбрать изображение из галереи
            let alert = UIAlertController(title: "Камера недоступна", message: "Ваше устройство не поддерживает камеру или она недоступна. Выберите изображение из галереи.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default) { _ in
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.view.tag = index
                self.present(imagePickerController, animated: true, completion: nil)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            let index = picker.view.tag
            imageViews[index].image = selectedImage
            
            // Сохранение изображения в соответствующую переменную
            let imageData = selectedImage.pngData()
            switch index {
            case 0:
                UserOrder.shared.userPhoto1 = imageData
            case 1:
                UserOrder.shared.userPhoto2 = imageData
            case 2:
                UserOrder.shared.userPhoto3 = imageData
            case 3:
                UserOrder.shared.userPhoto4 = imageData
            default:
                break
            }
            
            // Скрываем "плюсик" после выбора изображения
            if let plusImageView = imageViews[index].viewWithTag(100) as? UIImageView {
                plusImageView.isHidden = true
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // Скрыть клавиатуру для любого активного текстового поля
    }
}
