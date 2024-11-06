import UIKit
import FirebaseStorage

class FullImageViewController: UIViewController, UIScrollViewDelegate {
    var imageUrl: String?
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScrollView()
        setupImageView()
        loadImage()
    }

    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0 // Максимальный зум
        view.addSubview(scrollView)
    }

    private func setupImageView() {
        imageView.frame = scrollView.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)

        // Добавляем жест закрытия по тапу
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
        imageView.addGestureRecognizer(tapGesture)
    }

    private func loadImage() {
        guard let imageUrl = imageUrl else { return }
        let storageRef = Storage.storage().reference(forURL: imageUrl)

        // Загружаем изображение
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Ошибка загрузки изображения: \(error)")
                self.imageView.image = UIImage(named: "placeholder")
            } else if let data = data, let image = UIImage(data:data) {
                let rotatedImage = image.rotate(radians: .pi/2)
                self.imageView.image = rotatedImage
            }
        }
    }

    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
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
