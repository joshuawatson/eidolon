import Foundation

class AdminCardTestingViewController: UIViewController {

    lazy var keys = EidolonKeys()
    var cardHandler: CardHandler!

    @IBOutlet weak var logTextView: UITextView!

     override func viewDidLoad() {
        super.viewDidLoad()


        self.logTextView.text = ""

        let merchantToken = AppSetup.sharedState.useStaging ? self.keys.cardflightMerchantAccountStagingToken() : self.keys.cardflightMerchantAccountToken()
        cardHandler = CardHandler(apiKey: self.keys.cardflightAPIClientKey(), accountToken:merchantToken)
        
        cardHandler.cardSwipedSignal.subscribeNext({ (message) -> Void in
                self.log("\(message)")
                return

            }, error: { (error) -> Void in

                self.log("\n====Error====\n\(error)\n\n")
                if self.cardHandler.card != nil {
                    self.log("==\n\(self.cardHandler.card!)\n\n")
                }


            }, completed: {

                if let card = self.cardHandler.card {
                    let cardDetails = "Card: \(card.name) - \(card.encryptedSwipedCardNumber) \n \(card.cardToken)"
                    self.log(cardDetails)
                }

                self.cardHandler.startSearching()
        })

        cardHandler.startSearching()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cardHandler.end()
    }

    func log(string: String) {
        self.logTextView.text = "\(self.logTextView.text)\n\(string)"

    }

    @IBAction func backTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }


}