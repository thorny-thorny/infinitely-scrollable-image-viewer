import UIKit

class InfinitelyScrollableImageViewer: UIView {
    private let tileSize: CGFloat = 100
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 4
    
    private var baseOffset = CGPointZero
    private var offset = CGPointZero {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var baseScale: CGFloat = 1
    private var scale: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
        
    var displayedTiles = [TilePosition:InfinitelyScrollableImageViewerTile]()
    
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
            offset = CGPointMake(baseOffset.x + translation.x / scale, baseOffset.y + translation.y / scale)
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
            scale = min(maxScale, max(minScale, baseScale * pinchGR.scale))
        case .ended, .cancelled, .failed:
            baseScale = scale
        @unknown default:
            break
        }
    }
    
    private func tileToLocalRect(position: TilePosition, rect: CGRect) -> CGRect {
        let absoluteX = tileSize * (CGFloat(position.column) - 0.5)
        let absoluteY = tileSize * (CGFloat(position.row) - 0.5)
        
        let x = (absoluteX + offset.x) * scale + rect.width * 0.5
        let y = (absoluteY + offset.y) * scale + rect.height * 0.5
        
        return CGRectMake(x, y, tileSize * scale, tileSize * scale)
    }
    
    private func localPointToTile(point: CGPoint, rect: CGRect) -> TilePosition {
        // Inverted tileToLocalRect
        let column = Int(floor(((point.x - rect.width * 0.5) / scale - offset.x) / tileSize)) - 1
        let row = Int(floor(((point.y - rect.height * 0.5) / scale - offset.y) / tileSize)) - 1
        
        return TilePosition(column: column, row: row)
    }
    
    override func layoutSubviews() {
        let topLeftPosition = localPointToTile(point: CGPointZero, rect: bounds)
        let columns = Int(ceil(bounds.width / (tileSize * scale))) + 3
        let rows = Int(ceil(bounds.height / (tileSize * scale))) + 3
        
        let columnsRange = topLeftPosition.column..<(topLeftPosition.column + columns)
        let rowsRange = topLeftPosition.row..<(topLeftPosition.row + rows)
        
        var pool = [TilePosition:InfinitelyScrollableImageViewerTile]()
        
        displayedTiles.forEach { position, tile in
            if !(columnsRange ~= position.column) || !(rowsRange ~= position.row) {
                pool[position] = tile
            }
        }
        
        pool.forEach { position, _ in
            displayedTiles.removeValue(forKey: position)
        }

        for column in columnsRange {
            for row in rowsRange {
                let position = TilePosition(column: column, row: row)
                let tileFrame = tileToLocalRect(position: position, rect: bounds)
                
                if let displayedTile = displayedTiles[position] {
                    displayedTile.frame = tileFrame
                } else {
                    let tile: InfinitelyScrollableImageViewerTile
                    if let poolElement = pool.randomElement() {
                        pool.removeValue(forKey: poolElement.key)

                        tile = poolElement.value
                        tile.frame = tileFrame
                    } else {
                        tile = InfinitelyScrollableImageViewerTile(frame: tileFrame)
                        addSubview(tile)
                    }
                    
                    displayedTiles[position] = tile
                    tile.reload()
                }
            }
        }
        
        pool.forEach { _, tile in
            tile.removeFromSuperview()
        }
    }
}
