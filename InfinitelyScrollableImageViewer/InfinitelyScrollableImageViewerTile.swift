import UIKit

class InfinitelyScrollableImageViewerTile: UIView {
    private var imageView: UIImageView?
    private var dataTask: URLSessionDataTask?
    private var loadingImageUrl: URL?
    
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
    
    deinit {
        dataTask?.cancel()
    }
    
    internal func reload(with imageUrl: URL) {
        imageView?.image = nil
        dataTask?.cancel()
        loadingImageUrl = imageUrl
        
        let request = URLRequest(url: imageUrl, timeoutInterval: 5)
        dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            var image: UIImage? = nil
            if
                let data = data,
                let mimeType = response?.mimeType,
                let httpUrlResponse = response as? HTTPURLResponse,
                200..<300 ~= httpUrlResponse.statusCode &&
                mimeType.hasPrefix("image") &&
                error == nil
            {
                image = UIImage(data: data)
            }
            
            DispatchQueue.main.async() { [weak self] in
                if imageUrl == self?.loadingImageUrl {
                    self?.imageView?.image = image
                    self?.dataTask = nil
                }
            }
        }
        dataTask?.resume()
    }
}
