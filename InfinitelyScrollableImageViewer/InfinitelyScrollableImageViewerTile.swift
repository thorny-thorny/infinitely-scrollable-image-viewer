import UIKit

class InfinitelyScrollableImageViewerTile: UIView {
    private var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageView = UIImageView(frame: bounds)
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        self.imageView = imageView
    }
    
    required init?(coder: NSCoder) {
        fatalError("You are not supposed to do this")
    }
    
    internal func reload() {
        imageView?.image = nil
        
        let url = URL(string: "https://picsum.photos/200/200")!
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard
                let httpUrlResponse = response as? HTTPURLResponse,
                httpUrlResponse.statusCode >= 200 && httpUrlResponse.statusCode < 300,
                let mimeType = response?.mimeType,
                mimeType.hasPrefix("image"),
                let data = data,
                error == nil,
                let image = UIImage(data: data)
            else {
                return
            }

            DispatchQueue.main.async() { [weak self] in
                self?.imageView?.image = image
            }
        }).resume()
    }
}
