import SwiftUI


struct ViewControllerRepresentable: UIViewControllerRepresentable
{
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = OrderDetailsViewController()
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //
    }
}
