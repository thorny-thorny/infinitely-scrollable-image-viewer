import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageViewer: InfinitelyScrollableImageViewer?
    let dataSource = RandomPicsumPhotosDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewer?.dataSource = dataSource
    }
}
