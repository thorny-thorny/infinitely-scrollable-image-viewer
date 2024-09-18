import UIKit

class InfinitelyScrollableImageViewerCell: UIView {
    var column: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var row: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        UIGraphicsGetCurrentContext()?.stroke(rect)
        NSAttributedString(string: "\(column) : \(row)").draw(in: rect)
    }
}
