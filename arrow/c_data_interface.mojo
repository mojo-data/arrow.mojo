alias ARROW_FLAG_DICTIONARY_ORDERED = 1
alias ARROW_FLAG_NULLABLE = 2
alias ARROW_FLAG_MAP_KEYS_SORTED = 4

alias c_string = Pointer[UInt8]


@register_passable("trivial")
struct ArrowSchema:
    var format: c_string
    var name: c_string
    var metadata: c_string
    var flags: Int64
    var n_children: Int64
    var children: Pointer[Pointer[Self]]
    var dictionary: Pointer[Self]
    var release: Pointer[fn (Pointer[Self]) -> None]
    var private_data: Pointer[UInt8]


@register_passable("trivial")
struct ArrowArray:
    var length: Int64
    var null_count: Int64
    var offset: Int64
    var n_buffers: Int64
    var n_children: Int64
    var buffers: UnsafePointer[UnsafePointer[UInt8]]
    var children: UnsafePointer[UnsafePointer[Self]]
    var dictionary: UnsafePointer[Self]
    var release: UnsafePointer[fn (UnsafePointer[Self]) -> None]
    var private_data: UnsafePointer[UInt8]
