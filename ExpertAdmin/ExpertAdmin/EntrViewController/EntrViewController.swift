import UIKit
import FirebaseAppCheck
import Firebase
import FirebaseFirestore
import FirebaseStorage

class OrderStatus
{
    static let shared = OrderStatus()
    var status: Int?
}
class ChatType
{
    static let shared = ChatType()
    var status: Int?
}

class EntrViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Задний фон окна
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        // Лого
        let mainLogo = UIImageView()
        mainLogo.image = UIImage(named: "logo_final")
        mainLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLogo)
        
        // Кнопки

        let newOrder = createButton(text: "Заказы")
        let checkOrder = createButton(text: "Отчеты")
        let experts = createButton(text: "Эксперты")
        let myexpertiz = createButton(text: "Мои экспертизы")
        let techHelp = createButton(text: "Тех.поддержка")

        // Add buttons to the view
        view.addSubview(newOrder)
        view.addSubview(myexpertiz)
        view.addSubview(checkOrder)
        view.addSubview(experts)
        view.addSubview(techHelp)

        // Set up gestures
        newOrder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(firstTapped)))
        checkOrder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MineOrderTapped)))
        experts.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showExperts)))
        myexpertiz.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(myExpertizTapped)))
        techHelp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUsersTapped)))
        
        if Expert.shared.status == 0
        {
            newOrder.isHidden = true
            checkOrder.isHidden = true
            experts.isHidden = true
            techHelp.isHidden = true
            
            NSLayoutConstraint.activate([
                
                mainLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                mainLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
                mainLogo.widthAnchor.constraint(equalToConstant: 100),
                mainLogo.heightAnchor.constraint(equalToConstant: 100),
                
                
                myexpertiz.topAnchor.constraint(equalTo: mainLogo.bottomAnchor, constant: 30),
                myexpertiz.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                myexpertiz.widthAnchor.constraint(equalToConstant: 200),
                myexpertiz.heightAnchor.constraint(equalToConstant: 50)
            ])
        }else
        {
            // Activate constraints
            NSLayoutConstraint.activate([
                // Логотип
                mainLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                mainLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -200),
                mainLogo.widthAnchor.constraint(equalToConstant: 100),
                mainLogo.heightAnchor.constraint(equalToConstant: 100),
                
                // Кнопки
                newOrder.topAnchor.constraint(equalTo: mainLogo.bottomAnchor, constant: 30),
                newOrder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                newOrder.widthAnchor.constraint(equalToConstant: 200),
                newOrder.heightAnchor.constraint(equalToConstant: 50),
                
                
                checkOrder.topAnchor.constraint(equalTo: newOrder.bottomAnchor, constant: 30),
                checkOrder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                checkOrder.widthAnchor.constraint(equalToConstant: 200),
                checkOrder.heightAnchor.constraint(equalToConstant: 50),
                
                experts.topAnchor.constraint(equalTo: checkOrder.bottomAnchor, constant: 30),
                experts.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                experts.widthAnchor.constraint(equalToConstant: 200),
                experts.heightAnchor.constraint(equalToConstant: 50),
                
                myexpertiz.topAnchor.constraint(equalTo: experts.bottomAnchor, constant: 30),
                myexpertiz.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                myexpertiz.widthAnchor.constraint(equalToConstant: 200),
                myexpertiz.heightAnchor.constraint(equalToConstant: 50),
                
                techHelp.topAnchor.constraint(equalTo: myexpertiz.bottomAnchor, constant: 30),
                techHelp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                techHelp.widthAnchor.constraint(equalToConstant: 200),
                techHelp.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }

    
    // Метод создания кнопки
    func createButton(text: String) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    // Метод обработки нажатия на первую кнопку
    @objc func firstTapped() {
        OrderStatus.shared.status = 0
        let storyboard = UIStoryboard(name: "NewExpertizViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "NewExpertizViewController")as! NewExpertizViewController
        present(vsa,animated: true)
    }
    
    // Метод обработки нажатия на вторую кнопку
    @objc func secondTapped() {
        OrderStatus.shared.status = 1
        let storyboard = UIStoryboard(name: "NewExpertizViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "NewExpertizViewController")as! NewExpertizViewController
        present(vsa,animated:true)
    }
    
    @objc func MineOrderTapped()
    {
        let storyboard = UIStoryboard(name: "FilterViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        present(vsa,animated: true)
    }
    @objc func CheckCancelOrder()
    {
        OrderStatus.shared.status = 3
        let storyboard = UIStoryboard(name: "NewExpertizViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "NewExpertizViewController")as! NewExpertizViewController
        present(vsa,animated:true)
    }
    
    @objc func showExperts()
    {
        let storyboard = UIStoryboard(name: "ExpertsViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "ExpertsViewController") as! ExpertsViewController
        present(vsa,animated: true)
    }
    @objc func checkReadyOrder()
    {
        OrderStatus.shared.status = 2
        let storyboard = UIStoryboard(name: "NewExpertizViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "NewExpertizViewController") as! NewExpertizViewController
        present(vsa,animated: true)
    }
    @objc func myExpertizTapped()
    {
        let storyboard = UIStoryboard(name: "MyOrderViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "MyOrderViewController") as! MyOrderViewController
        present(vsa,animated: true)
    }
    @objc func showUsersTapped() {
        ChatType.shared.status = 0
             // Переход на контроллер списка пользователей
        let usersListVC = UIStoryboard(name: "UsersChatViewController", bundle: nil)
        let vsa = usersListVC.instantiateViewController(withIdentifier: "UsersChatViewController") as! UsersChatViewController
        self.present(vsa, animated: true, completion: nil)
    }

 }

