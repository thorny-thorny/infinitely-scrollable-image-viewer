import UIKit

class InfinitelyScrollableImageViewer: UIView {
    var baseOffset = CGPointZero
    var offset = CGPointZero {
        didSet {
            setNeedsLayout()
        }
    }
    
    var baseScale: CGFloat = 1
    var scale: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    let tileSize: CGFloat = 100
    
    var cellsPool = [InfinitelyScrollableImageViewerCell]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initBase()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initBase()
    }
    
    private func initBase() {
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
        let column = Int(floor(((point.x - rect.width * 0.5) / scale - offset.x) / tileSize)) - 1
        let row = Int(floor(((point.y - rect.height * 0.5) / scale - offset.y) / tileSize)) - 1
        
        return (column, row)
    }
    
    func adjustCellsPool(columns: Int, rows: Int) {
        let cellsCount = columns * rows
        
        if (cellsPool.count > cellsCount) {
            for i in cellsCount..<cellsPool.count {
                cellsPool[i].removeFromSuperview()
            }
            cellsPool = Array(cellsPool[0..<cellsCount])
        } else if (cellsPool.count < cellsCount) {
            let delta = cellsCount - cellsPool.count
            for _ in 1...delta {
                let cell = InfinitelyScrollableImageViewerCell(frame: CGRectMake(0, 0, tileSize, tileSize))
                addSubview(cell)
                cellsPool.append(cell)
            }
        }
    }
    
    override func layoutSubviews() {
        let (topLeftColumn, topLeftRow) = localPointToTile(point: CGPointZero, rect: bounds)
        let columns = Int(ceil(bounds.width / (tileSize * scale))) + 3
        let rows = Int(ceil(bounds.height / (tileSize * scale))) + 3
        
        adjustCellsPool(columns: columns, rows: rows)

        for column in 0..<columns {
            for row in 0..<rows {
                let cellIndex = column * rows + row
                let cell = cellsPool[cellIndex]

                cell.column = topLeftColumn + column
                cell.row = topLeftRow + row
                cell.frame = tileToLocalRect(column: cell.column, row: cell.row, rect: bounds)
                cell.reload()
            }
        }
    }
}
