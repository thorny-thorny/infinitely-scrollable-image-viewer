import Foundation

class SegmentedGridData<T> {
    private var segments = [TilePosition:[[T?]]]()
    public let segmentSize: Int
    
    init(segmentSize: Int) {
        self.segmentSize = segmentSize
    }
    
    private func normalizedSegmentIndexPosition(_ position: TilePosition) -> TilePosition {
        var column = position.column
        if column < 0 {
            column = column + segmentSize * Int(ceil(-Double(column) / Double(segmentSize)))
        }
        
        var row = position.row
        if row < 0 {
            row = row + segmentSize * Int(ceil(-Double(row) / Double(segmentSize)))
        }
        
        return TilePosition(column: column % segmentSize, row: row % segmentSize)
    }
    
    private func normalizedSegmentPosition(_ position: TilePosition) -> TilePosition {
        let column = Int(floor(Double(position.column) / Double(segmentSize)))
        let row = Int(floor(Double(position.row) / Double(segmentSize)))
        return TilePosition(column: column, row: row)
    }
    
    subscript(index:TilePosition) -> T? {
        get {
            let segmentPosition = normalizedSegmentPosition(index)
            
            if let segment = segments[segmentPosition] {
                let position = normalizedSegmentIndexPosition(index)
                return segment[position.column][position.row]
            } else {
                return nil
            }
        }
        set {
            let segmentPosition = normalizedSegmentPosition(index)
            
            var segment = segments[segmentPosition]
            if segment == nil {
                segment = [[T?]](repeating: [T?](repeating: nil, count: segmentSize), count: segmentSize)
            }
            
            if var segment = segment {
                let position = normalizedSegmentIndexPosition(index)
                segment[position.column][position.row] = newValue
                segments[segmentPosition] = segment
            }
        }
    }
}
