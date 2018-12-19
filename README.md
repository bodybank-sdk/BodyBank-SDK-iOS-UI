# BodyBank-SDK-iOS-UI

## Install
```
#Tutorial UI
pod 'BodyBankEnterpriseUI/Tutorial'

#Camera UI
pod 'BodyBankEnterpriseUI/Camera'

#History UI
pod 'BodyBankEnterpriseUI/History'
```


## Usage

### Tutorial
```
class ViewController: UIViewController{
    func showTutorial(){
        let tutorial = BodyBankEnterprise.TutorialUI.show(on: self, animated: true, completion: nil)
        tutorial?.delegate = self
    }
}

extension ViewController: TutorialViewControllerDelegate{
    func tutorialViewControllerDidEnd(viewController: TutorialViewController) {
       dismiss(animated: true, completion: nil)
    }
}

```

### Camera
```
class ViewController: UIViewController{
    func showCamera(){
       let camera = BodyBankEnterprise.CameraUI.show(on: self, animated: true, completion: nil)
        camera?.delegate = self
    }
}

extension ViewController: CameraViewControllerDelegate{
    func cameraViewControllerDidCancel(viewController: CameraViewController) {
       dismiss(animated: true, completion: nil)
    }
    
    func cameraViewControllerDidFinish(viewController: CameraViewController) {
        dismiss(animated: true) {
            let param = viewController.estimationParameter
            //Use params
        }
    }
}

```


### History
```
class ViewController: UIViewController{
    
    func showHistoryList(){
        let historyList = BodyBankEnterprise.HistoryUI.showList(on: self, animated: true, completion: nil)
        historyList?.delegate = self
    }
    
    func showHistoryDetail(){
        BodyBankEnterprise.getEstimationRequest(id: "id") { (request, errors) in
            if let request = request{
                DispatchQueue.main.async{
                    let historyDetail = BodyBankEnterprise.HistoryUI.showDetail(on: self, request: request, animated: true, completion: nil)
                    historyDetail?.delegate = self
                }
            }
        }
    }
    
}

extension ViewController: EstimationHistoryListViewControllerDelegate{
    func estimationHistoryListViewControllerDidFinish(viewController: EstimationHistoryListViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func estimationHistoryListViewController(viewController: EstimationHistoryListViewController, didSelectEstimationRequest estimationRequest: EstimationRequest, toShowDetailViewController detailViewController: EstimationHistoryViewController) {
    
    }
}

extension ViewController: EstimationHistoryViewControllerDelegate{
    func estimationzHistoryViewControllerDidFinish(viewController: EstimationHistoryViewController) {
        dismiss(animated: true, completion: nil)
    }

    func estimationzHistoryViewControllerDidCancel(viewController: EstimationHistoryViewController) {

    }
}


```
