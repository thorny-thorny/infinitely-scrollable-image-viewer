import Foundation

class RandomPicsumPhotosDataSource: InfinitelyScrollableImageViewerDataSource {
    private let gridData = SegmentedGridData<Int>(segmentSize: 20)
    private var nextPhotoId = 0
    
    internal func urlForTile(at position: TilePosition) -> URL {
        var id = gridData[position]
        if id == nil {
            id = nextPhotoId
            nextPhotoId += 1
            
            gridData[position] = id
        }
        
        // Lot of pics do not exist anymore, using seed instead of id
        return URL(string: "https://picsum.photos/seed/\(id!)/100")!
    }
}
