import UIKit
import AVFoundation

class OrderViewController: UIViewController, AVAudioRecorderDelegate {

    var inputField: UITextField!
    var recordButton: UIButton!
    var audioRecorder: AVAudioRecorder?
    var audioFileURL: URL?
    var orders: [(id: String, userName: String, userID: String, expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photos: [String], audioURL: URL?)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        let H1 = UITextView()
        let fullText = "Шаг первый"
        let attributedString = NSMutableAttributedString(string: fullText)
        let orangeColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        let rangeForOrangeText = (fullText as NSString).range(of: "Шаг")
        attributedString.addAttribute(.foregroundColor, value: orangeColor, range: rangeForOrangeText)
        let rangeForWhiteText = (fullText as NSString).range(of: "первый")
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: rangeForWhiteText)
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 30), range: NSMakeRange(0, attributedString.length))
        H1.attributedText = attributedString
        H1.backgroundColor = .clear
        H1.isScrollEnabled = false
        H1.isEditable = false
        H1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(H1)
        
        let text1 = createText(withText: "Вам необходимо описать, что у вас случилось, но кратко, доходчиво и понятно, без всякой воды.")
        view.addSubview(text1)
        
        inputField = UITextField()
        inputField.placeholder = "Введите описание здесь..."
        inputField.attributedPlaceholder = NSAttributedString(
            string: "Введите описание здесь...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)]
        )
        inputField.textColor = .white
        inputField.font = UIFont.systemFont(ofSize: 18)
        inputField.borderStyle = .roundedRect
        inputField.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        inputField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputField)
        
        // Кнопка записи ГС
        recordButton = UIButton(type: .system)
        recordButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        recordButton.tintColor = .white
        recordButton.addTarget(self, action: #selector(recordAudio), for: .touchUpInside)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recordButton)
        
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
            H1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            H1.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            text1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text1.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 20),
            text1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputField.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 20),
            inputField.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -10),
            inputField.heightAnchor.constraint(equalToConstant: 50),
            
            // Кнопка записи ГС рядом с UITextField
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recordButton.centerYAnchor.constraint(equalTo: inputField.centerYAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 30),
            recordButton.heightAnchor.constraint(equalToConstant: 30),
            
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            prevButton.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 60),
            prevButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            prevButton.heightAnchor.constraint(equalToConstant: 40),
            
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 60),
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

    @objc func recordAudio() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }

    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            // Запрашиваем разрешение на использование микрофона
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            audioFileURL = audioFilename
            recordButton.setImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
            
            print("Запись начата, файл: \(audioFilename.absoluteString)") // Добавлено для отладки

        } catch {
            print("Ошибка при записи: \(error.localizedDescription)") // Вывод ошибки
            finishRecording(success: false)
        }
    }

    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        recordButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)

        if success {
            print("Запись сохранена: \(audioFileURL?.absoluteString ?? "Ошибка сохранения")")
            // Сохраните ссылку на аудио в массив orders
            if let audioURL = audioFileURL {
                UserOrder.shared.userAudio = audioURL.absoluteString
            }
        } else {
            audioFileURL = nil
            print("Не удалось записать аудио")
        }
    }

    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }


    @objc func nextTapped() {
        if let messageText = inputField.text, !messageText.isEmpty {
            UserOrder.shared.userText = messageText
            
            
            let storyboard = UIStoryboard(name: "GetPhotoViewController", bundle: nil)
            let vsa = storyboard.instantiateViewController(withIdentifier: "GetPhotoViewController") as! GetPhotoViewController
            present(vsa, animated: true)
        } else {
            let errorAlert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите описание.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(errorAlert, animated: true)
        }
    }

    @objc func prevTapped() {
        // Логика для обработки нажатия кнопки "Назад"
        dismiss(animated: true)
    }

    @objc func hideKeyboard() {
        inputField.resignFirstResponder()
    }
}
