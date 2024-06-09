var ARROW_FLAG_DICTIONARY_ORDERED = 1
var ARROW_FLAG_NULLABLE = 2
var ARROW_FLAG_MAP_KEYS_SORTED = 4


@value
struct ArrowSchema:
    var format: String
    var name: String
    var metadata: String
    var flags: Int64
    var n_children: Int64
    var children: List[UnsafePointer[Self]]
    var dictionary: UnsafePointer[Self]
    var release: UnsafePointer[fn (UnsafePointer[Self]) -> None]
    var private_data: UnsafePointer[UInt8]


@value
struct ArrowArray:
    var length: Int64
    var null_count: Int64
    var offset: Int64
    var n_buffers: Int64
    var n_children: Int64
    var buffers: List[UnsafePointer[UInt8]]
    var children: List[UnsafePointer[Self]]
    var dictionary: UnsafePointer[Self]
    var release: UnsafePointer[fn (UnsafePointer[Self]) -> None]
    var private_data: UnsafePointer[UInt8]
