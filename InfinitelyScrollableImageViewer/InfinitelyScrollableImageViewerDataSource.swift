import Foundation

protocol InfinitelyScrollableImageViewerDataSource: AnyObject {
    func urlForTile(at position: TilePosition) -> URL
}
