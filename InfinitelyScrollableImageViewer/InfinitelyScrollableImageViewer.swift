import UIKit

class InfinitelyScrollableImageViewer: UIView {
    var baseOffset = CGPointZero
    var offset = CGPointZero
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let panGr = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        
        addGestureRecognizer(panGr)
    }
    
    @objc func onPan(_ panGr: UIPanGestureRecognizer) {
        let translation = panGr.translation(in: self)
        
        switch panGr.state {
        case .possible, .began:
            break
        case .changed:
            offset = CGPointMake(baseOffset.x + translation.x, baseOffset.y + translation.y)
        case .ended, .cancelled, .failed:
            baseOffset = offset
        @unknown default:
            break
        }
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let tileSize: CGFloat = 100
        
        let columns = Int(ceil(width / tileSize)) + 1
        let rows = Int(ceil(height / tileSize)) + 1
        
        let centerTileX = rect.width / 2 - tileSize / 2 + offset.x
        let centerTileY = rect.height / 2 - tileSize / 2 + offset.y
        
        let startX = centerTileX - tileSize * ceil(centerTileX / tileSize)
        let startY = centerTileY - tileSize * ceil(centerTileY / tileSize)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.red.cgColor)

        for column in 0..<columns {
            for row in 0..<rows {
                context?.stroke(CGRectMake(startX + tileSize * CGFloat(column), startY + tileSize * CGFloat(row), tileSize, tileSize))
            }
        }
    }
}
