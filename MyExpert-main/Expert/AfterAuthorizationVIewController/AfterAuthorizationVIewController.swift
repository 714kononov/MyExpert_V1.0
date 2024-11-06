import UIKit

class AfterAuthorizationViewController:UIViewController
{
    override func viewDidLoad() {
        
        //Градиент
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.gray.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradient, at: 0)
        
    }
}
