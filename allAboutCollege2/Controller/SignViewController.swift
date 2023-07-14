//
//  ViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 3/18/23.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import FirebaseAuth
import CommonCrypto
import Firebase
class SignViewController: UIViewController, UITextViewDelegate {
    static var userName:String?
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var termTextView: UITextView!
    var authUserModel = AuthUserModel()
    private var currentNonce:String?
    private let appleSignInButton = ASAuthorizationAppleIDButton()
    override func viewDidLoad()  {
        super.viewDidLoad()
        view.addSubview(appleSignInButton)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        loadUserName(completion: { username in
            if username != nil{
                print("This is user1: \(username)")
                let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationViewController")
                UIApplication.shared.windows.first?.rootViewController? = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        })
        appleSignInButton.addTarget(self, action:#selector(handleAppleIdRequest) , for: .touchUpInside)
        
        let text = "By continuing , you agree to All About UIUC's Terms of Service and Privacy Policy"
        
        let attributedString = NSMutableAttributedString(string: text)
        
        
        attributedString.addAttribute(.link, value: "https://medium.com/@brianjeongjae123/terms-conditions-for-all-about-uiuc-50364e6c90d7", range: NSString(string:text).range(of: "Terms of Service"))
        attributedString.addAttribute(.link, value: "https://medium.com/@brianjeongjae123/privacy-policy-for-all-about-uiuc-d84983a2f160", range: NSString(string:text).range(of: "Privacy Policy"))
        termTextView.attributedText = attributedString
        termTextView.font = UIFont.systemFont(ofSize: 14)
        termTextView.textColor = .white
        termTextView.isEditable = false
        termTextView.isSelectable = true
        termTextView.delegate = self
        termTextView.textAlignment = .center
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL,
        in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool{
            UIApplication.shared.open(URL)
            return true
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        appleSignInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appleSignInButton.widthAnchor.constraint(equalToConstant: 269).isActive = true
        appleSignInButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
    }
    


    
   func loadUserName(completion: @escaping (_ username: String?) -> Void) {
       Auth.auth().currentUser?.providerID
        guard let uid = Auth.auth().currentUser?.uid else {completion(nil)
            return}
        Firestore.firestore().collection("users").document(uid ?? "").getDocument { snapshot, _ in
            guard let dictionary = snapshot?.data() else{ completion(nil)
                return
            }
            let username = dictionary["username"] as! String?
            if username != nil {
                completion(username)
            }
            else{
                completion(nil)
            }
        }
    }
}


extension SignViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!,
              didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        // Check for sign in error
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        // Get credential object using Google ID token and Google access token
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // Authenticate with Firebase using the credential object
        Auth.auth().signIn(with: credential) { [self] (authResult, error) in
            if let error = error {
                print("Error occurs when authenticate with Firebase: \(error.localizedDescription)")
            }
            else{
                NotificationCenter.default.post(name: .signInGoogleCompleted, object: nil)
                print("test")
                loadUserName { username in
                    if username != nil{
                        print("This is user2: \(username)")
                        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationViewController")
                        UIApplication.shared.windows.first?.rootViewController? = vc
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    }
                    else{
                        print("This is user3: \(username)")
                        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = mainStoryboard.instantiateViewController(withIdentifier: "UsernameViewController")
                        UIApplication.shared.windows.first?.rootViewController? = vc
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    }
                }
        
            }
                             
        }
    }
}

extension SignViewController: ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("falied!")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let nonce = currentNonce else{
            return
        }
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else{
            return
        }
        guard let token = credential.identityToken else{
            return
        }
        guard let tokenString = String(data: token, encoding: .utf8)else{
            return
        }
        
        let oAuthCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        
        Auth.auth().signIn(with: oAuthCredential){ (result, error) in
            if let error = error {
                print("Error occurs when authenticate with Firebase: \(error.localizedDescription)")
            }
            else{
                let firstName = credential.fullName?.givenName
                let lastName = credential.fullName?.familyName
                let email = credential.email
                
                self.loadUserName { username in
                    if username != nil{
                        print("This is user2: \(username)")
                        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationViewController")
                        UIApplication.shared.windows.first?.rootViewController? = vc
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    }
                    else{
                        print("This is user3: \(username)")
                        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = mainStoryboard.instantiateViewController(withIdentifier: "UsernameViewController")
                        UIApplication.shared.windows.first?.rootViewController? = vc
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    }
                }
                
                
            }
           
            
            
        }

    }
}

extension SignViewController: ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}


private extension SignViewController{
    @objc func handleAppleIdRequest(){
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
        
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
          let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
              fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
          }

          randoms.forEach { random in
            if length == 0 {
              return
            }

            if random < charset.count {
              result.append(charset[Int(random)])
              remainingLength -= 1
            }
          }
        }

        return result
      }
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = hashSHA256(data: inputData)
        let hashString = hashedData!.compactMap {
          return String(format: "%02x", $0)
        }.joined()

        return hashString
      }
    
    func hashSHA256(data:Data) -> Data? {
            var hashData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

            _ = hashData.withUnsafeMutableBytes {digestBytes in
                data.withUnsafeBytes {messageBytes in
                    CC_SHA256(messageBytes, CC_LONG(data.count), digestBytes)
                }
            }
            return hashData
    }
    

      
}





// MARK:- Notification names
extension Notification.Name {
    /// Notification when user successfully sign in using Google
    static var signInGoogleCompleted: Notification.Name {
        return .init(rawValue: #function)
    }
                
}


    

