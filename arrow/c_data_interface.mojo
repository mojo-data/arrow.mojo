alias ARROW_FLAG_DICTIONARY_ORDERED = 1
alias ARROW_FLAG_NULLABLE = 2
alias ARROW_FLAG_MAP_KEYS_SORTED = 4


# @value
# struct ArrowSchema:
#     var format: String
#     var name: String
#     var metadata: String
#     var flags: Int64
#     var n_children: Int64
#     var children: List[Pointer[Self]]
#     var dictionary: Pointer[Self]
#     var release: Pointer[fn (Pointer[Self]) -> None]
#     var private_data: Pointer[UInt8]


# @value
# struct ArrowArray:
#     var length: Int64
#     var null_count: Int64
#     var offset: Int64
#     var n_buffers: Int64
#     var n_children: Int64
#     var buffers: List[Pointer[UInt8]]
#     var children: List[Pointer[Self]]
#     var dictionary: Pointer[Self]
#     var release: Pointer[fn (Pointer[Self]) -> None]
#     var private_data: Pointer[UInt8]
