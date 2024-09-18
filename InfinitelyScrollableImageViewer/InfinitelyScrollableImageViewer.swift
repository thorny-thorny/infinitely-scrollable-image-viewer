import UIKit

class InfinitelyScrollableImageViewer: UIView {
    private let tileSize: CGFloat = 100
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 4
    private let extraTilesBorderWidth: CGFloat = 200
    
    weak var dataSource: InfinitelyScrollableImageViewerDataSource?
    
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
        
    private var displayedTiles = [TilePosition:InfinitelyScrollableImageViewerTile]()
    
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
    
    private func tileToLocalRect(position: TilePosition, halfSize: CGSize) -> CGRect {
        let absoluteX = tileSize * (CGFloat(position.column) - 0.5)
        let absoluteY = tileSize * (CGFloat(position.row) - 0.5)
        
        let x = floor((absoluteX + offset.x) * scale + halfSize.width)
        let y = floor((absoluteY + offset.y) * scale + halfSize.height)
        let size = floor(tileSize * scale)
        
        return CGRectMake(x, y, size, size)
    }
    
    private func localPointToTile(point: CGPoint, halfSize: CGSize) -> TilePosition {
        // Inverted tileToLocalRect
        let column = Int(floor(((point.x - halfSize.width) / scale - offset.x) / tileSize)) - 1
        let row = Int(floor(((point.y - halfSize.height) / scale - offset.y) / tileSize)) - 1
        
        return TilePosition(column: column, row: row)
    }
    
    override func layoutSubviews() {
        guard let dataSource = dataSource else {
            return
        }
        
        let scaledTileSize = floor(tileSize * scale)
        let extraTiles = Int(ceil(extraTilesBorderWidth / scaledTileSize))
        let halfSize = CGSizeMake(bounds.size.width / 2, bounds.size.height / 2)
        
        let topLeftPosition = localPointToTile(point: CGPointZero, halfSize: halfSize)
        let columns = Int(ceil(bounds.width / scaledTileSize)) + (extraTiles + 1) * 2
        let rows = Int(ceil(bounds.height / scaledTileSize)) + (extraTiles + 1) * 2
        
        let columnsRange = (topLeftPosition.column - extraTiles)..<(topLeftPosition.column + columns)
        let rowsRange = (topLeftPosition.row - extraTiles)..<(topLeftPosition.row + rows)
        
        var pool = [TilePosition:InfinitelyScrollableImageViewerTile]()
        
        displayedTiles.forEach { position, tile in
            if !(columnsRange ~= position.column) || !(rowsRange ~= position.row) {
                pool[position] = tile
            }
        }
        
        pool.forEach { position, _ in
            displayedTiles.removeValue(forKey: position)
        }
        
        let firstTileRect = tileToLocalRect(position: TilePosition(column: columnsRange.lowerBound, row: rowsRange.lowerBound), halfSize: halfSize)

        for column in columnsRange {
            for row in rowsRange {
                let position = TilePosition(column: column, row: row)
                let tileFrame = CGRectMake(
                    firstTileRect.origin.x + firstTileRect.width * CGFloat(column - columnsRange.lowerBound),
                    firstTileRect.origin.y + firstTileRect.height * CGFloat(row - rowsRange.lowerBound),
                    firstTileRect.width,
                    firstTileRect.height
                )
                
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
                    tile.reload(with: dataSource.urlForTile(at: position))
                }
            }
        }
        
        pool.forEach { _, tile in
            tile.removeFromSuperview()
        }
    }
}
