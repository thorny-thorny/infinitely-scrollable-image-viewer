import UIKit

class InfinitelyScrollableImageViewer: UIView {
    var baseOffset = CGPointZero
    var offset = CGPointZero
    
    var baseScale: CGFloat = 1
    var scale: CGFloat = 1
    
    let tileSize: CGFloat = 100
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(onPinch))
        
        addGestureRecognizer(panGR)
        addGestureRecognizer(pinchGR)
    }
    
    @objc private func onPan(_ panGR: UIPanGestureRecognizer) {
        switch panGR.state {
        case .possible, .began:
            break
        case .changed:
            let translation = panGR.translation(in: self)
            offset = CGPointMake(baseOffset.x + translation.x, baseOffset.y + translation.y)
        case .ended, .cancelled, .failed:
            baseOffset = offset
        @unknown default:
            break
        }
        
        setNeedsDisplay()
    }
    
    @objc private func onPinch(_ pinchGR: UIPinchGestureRecognizer) {
        switch pinchGR.state {
        case .possible, .began:
            break
        case .changed:
            scale = baseScale * pinchGR.scale
        case .ended, .cancelled, .failed:
            baseScale = scale
        @unknown default:
            break
        }
        
        setNeedsDisplay()
    }
    
    private func tileToLocalRect(column: Int, row: Int, rect: CGRect) -> CGRect {
        let absoluteX = tileSize * (CGFloat(column) - 0.5)
        let absoluteY = tileSize * (CGFloat(row) - 0.5)
        
        let x = (absoluteX + offset.x) * scale + rect.width * 0.5
        let y = (absoluteY + offset.y) * scale + rect.height * 0.5
        
        return CGRectMake(x, y, tileSize * scale, tileSize * scale)
    }
    
    private func localPointToTile(point: CGPoint, rect: CGRect) -> (Int, Int) {
        // Inverted tileToLocalRect
        let column = Int(floor(((point.x - rect.width * 0.5) / scale - offset.x) / tileSize))
        let row = Int(floor(((point.y - rect.height * 0.5) / scale - offset.y) / tileSize))
        
        return (column, row)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let (topLeftColumn, topLeftRow) = localPointToTile(point: CGPointZero, rect: rect)
        let columns = Int(ceil(rect.width / (tileSize * scale))) + 1
        let rows = Int(ceil(rect.height / (tileSize * scale))) + 1
        
        UIGraphicsPushContext(context)
        
        for column in topLeftColumn...(topLeftColumn + columns) {
            for row in topLeftRow...(topLeftRow + rows) {
                let rect = tileToLocalRect(column: column, row: row, rect: rect)
                context.stroke(rect)
                NSAttributedString(string: "\(column) : \(row)").draw(in: rect)
            }
        }

        UIGraphicsPopContext()
    }
}
