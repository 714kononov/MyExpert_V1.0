import UIKit

class AboutUsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создаем слой градиента
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        // Создаем UIScrollView
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Создаем контейнер для контента внутри UIScrollView
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Заголовок H1
        let H1 = UILabel()
        H1.text = "О нас"
        H1.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        H1.textColor = .white
        H1.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(H1)
        
        // Создаем текстовые блоки
        let text1 = createTextView(withText: "Мы не банальные оценщики, ограничивающие себя типовой работой в регионе. Мы амбициозны и темпераментны, упрямы, современны и не обычны. Мы единственные в Пензе кто принимал участие в Олимпийской стройке страны. Наша компания безупречно поставила на кадастровый учет ряд объектов для Государственной корпорации «Олимпстрой». Мы принимали участие в конкурсах на оценку недвижимости посольства МИДа России в Мексике, многоквартирных домов во Владивостоке, списания боевых вертолетов МИ-24 в Ростове, оценку рыболовных судов на Камчатке.")
        
        //Фото офиса
        images = [UIImage(named: "image1")!, UIImage(named: "image2")!, UIImage(named: "image3")!, UIImage(named: "image4")!, UIImage(named: "image5")!, UIImage(named: "image6")!, UIImage(named: "image7")!]
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear  // Прозрачный фон
        collectionView.showsHorizontalScrollIndicator = false  // Скрываем горизонтальный индикатор скроллинга
        
        // Регистрируем ячейку
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        
        // Устанавливаем делегаты
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Добавляем все элементы в contentView
        contentView.addSubview(H1)
        contentView.addSubview(text1)
        contentView.addSubview(collectionView)
        
        let container = UIView()
        container.backgroundColor = .orange
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        
        let text2 = createTextView(withText: "Мы не авантюристы, а скорее искатели приключений в хорошем смысле этого слова.")
        let text3 = createTextView(withText: "Практически в любой сфере у нас есть свои консультанты и компетентные специалисты, позволяющие качественно, профессионально и обосновано выполнить поставленную перед нами задачу. Чем сложнее работа, тем интересней она для нас, причем финансовая сторона вопроса далеко не всегда на первом месте.")
        container.addSubview(text2)
        contentView.addSubview(text3)
        
        // Настраиваем констрейнты для scrollView и contentView
        NSLayoutConstraint.activate([
            // Констрейнты для scrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Констрейнты для contentView внутри scrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),  // Ширина contentView равна ширине scrollView
            container.topAnchor.constraint(equalTo: scrollView.bottomAnchor,constant: 20),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20)
        ])
        
        // Настраиваем констрейнты для текста и фотографий
        NSLayoutConstraint.activate([
            H1.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            H1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            text1.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 20),
            text1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            text1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            
            text2.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            text2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            text2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            text3.topAnchor.constraint(equalTo: text2.bottomAnchor, constant: 20),
            text3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            text3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            text3.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.8, height: collectionView.frame.height)
    }
    
    // Создаем функцию для создания UITextView
    func createTextView(withText text: String) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
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
