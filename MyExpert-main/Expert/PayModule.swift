//
//  PayModule.swift
//  Expert
//
//  Created by admin on 06.11.2024.
//

import Foundation
import TinkoffASDKCore
import TinkoffASDKUI
import UIKit

class PayModule{
    
    let vc: UIViewController!
    let completion: (PayResult) -> ()
    
    let credential = AcquiringSdkCredential(
        terminalKey: "1730834238857DEMO",
        publicKey: "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv5yse9ka3ZQE0feuGtemYv3IqOlLck8zHUM7lTr0za6lXTszRSXfUO7jMb+L5C7e2QNFs+7sIX2OQJ6a+HG8kr+jwJ4tS3cVsWtd9NXpsU40PE4MeNr5RqiNXjcDxA+L4OsEm/BlyFOEOh2epGyYUd5/iO3OiQFRNicomT2saQYAeqIwuELPs1XpLk9HLx5qPbm8fRrQhjeUD5TLO8b+4yCnObe8vy/BMUwBfq+ieWADIjwWCMp2KTpMGLz48qnaD9kdrYJ0iyHqzb2mkDhdIzkim24A3lWoYitJCBrrB2xM05sm9+OdCI1f7nPNJbl5URHobSwR94IRGT7CJcUjvwIDAQAB"
    )
    
    
    
    let uiSDKConfiguration = UISDKConfiguration()
    
    init(vc:UIViewController, completion: @escaping (PayResult)->()){
        
        let email = Payorder.shared.email ?? ""
        self.vc = vc
        self.completion = completion
        
        print("Почта пользователя: \(email)")
        
        let coreSDKConfiguration = AcquiringSdkConfiguration(
            credential: credential,
            server: .test
        )
        
        let orderOptions = OrderOptions(
            /// Идентификатор заказа в системе продавца
            orderId: UUID().uuidString,
            // Полная сумма заказа в копейках
            amount: 100,
            // Краткое описание заказа
            description: "Оплата за экспертизу",
            // Данные чека
            receipt: nil,
            shops: nil,
            receipts: nil,
            savingAsParentPayment: false
        )
        
        let customerOptions = CustomerOptions(
            // Идентификатор покупателя в системе продавца.
            // С помощью него можно привязать карту покупателя к терминалу после успешного платежа
            customerKey: email,
            // Email покупателя
            email: email
        )
        
        // Используется для редиректа в приложение после успешного или неуспешного совершения оплаты с помощью `TinkoffPay`
        // В иных сценариях передавать эти данные нет необходимости
        let paymentCallbackURL = PaymentCallbackURL(
            successURL: "SUCCESS_URL",
            failureURL: "FAIL_URL"
        )
        
        let paymentOptions: PaymentOptions = .init(orderOptions: orderOptions, customerOptions: customerOptions,paymentCallbackURL: paymentCallbackURL )
        
        let paymentFlow: PaymentFlow = .full(paymentOptions: paymentOptions)
        
        let config: MainFormUIConfiguration = .init(orderDescription: "Оплата за экспертизу")
        
        do {
            let sdk = try AcquiringUISDK(
                coreSDKConfiguration: coreSDKConfiguration,
                uiSDKConfiguration: uiSDKConfiguration
            )
            
            sdk.presentMainForm(on: vc, paymentFlow: paymentFlow, configuration: config){result in
                switch result{
                    
                case .succeeded(let succ):
                    print(succ ?? "")
                    completion(.succeeded)
                case .failed(let err):
                    print(err ?? "")
                    completion(.failed)
                case .cancelled(let cancel):
                    print(cancel ?? "")
                    completion(.cancelled)
                }
            }
        } catch {
            // Ошибка может возникнуть при некорректном параметре `publicKey`
            assertionFailure("\(error)")
        }
    }
}
    
    
enum PayResult
    {
    case succeeded,failed, cancelled
}

