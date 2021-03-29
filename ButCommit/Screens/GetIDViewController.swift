//
//  GetIDViewController.swift
//  ButCommit
//
//  Created by 이현호 on 2021/03/29.
//

import UIKit

class GetIDViewController: UIViewController {

    @IBOutlet weak var idInputTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idInputTextField.delegate = self
        doneButton.layer.cornerRadius = 10
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }

    @IBAction func didTapDoneButtonClick(_ sender: Any) {
        UserDefaults.standard.set(idInputTextField.text, forKey: "GithubKey")
        self.navigationController?.popViewController(animated: true)
    }
}

extension GetIDViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UserDefaults.standard.set(idInputTextField.text, forKey: "GithubKey")
        self.navigationController?.popViewController(animated: true)
        return true
    }
    
}
