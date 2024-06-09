from memory.unsafe import Pointer
from memory import memset_zero


alias PADDING = 64
alias ALIGNMENT = 64


struct Bitmap:
    # TODO: make copyable and movable
    var data: Pointer[UInt8]
    var length: Int
    var mem_use: Int

    fn __init__(inout self, bools: List[Bool]):
        """
        Arrow buffers are recommended to have an alignment and padding of 64 bytes
        source: https://arrow.apache.org/docs/format/Columnar.html#buffer-alignment-and-padding.
        """
        var num_bytes = ((len(bools)) + 7) // 8
        var num_bytes_with_padding = (
            (num_bytes + PADDING - 1) // PADDING
        ) * PADDING
        var ptr = Pointer[UInt8].alloc(
            num_bytes_with_padding, alignment=ALIGNMENT
        )
        memset_zero(ptr, num_bytes_with_padding)

        for i in range(len(bools)):
            var idx = (i // 8)
            var bit_mask: UInt8 = 0b10000000 >> (i % 8) if (
                bools[i]
            ) else 0  # TODO non branching version when it exists
            ptr.store(idx, ptr.load(idx) | bit_mask)

        self.data = ptr
        self.length = len(bools)
        self.mem_use = num_bytes_with_padding

    fn __getitem__(self, index: Int) raises -> Bool:
        if index < 0 or index >= self.length:
            raise Error("index out of range for Bitmap")

        var byte_index = index // 8
        var bit_index = index % 8
        var bit_mask: UInt8 = 0b10000000 >> bit_index
        return ((self.data.load(byte_index) & bit_mask) != 0).__bool__()

    fn __len__(self) -> Int:
        return self.length

    fn __del__(owned self):
        self.data.free()


struct ArrowBoolVector:
    var validity: Bitmap
    var buffer: Bitmap


struct ArrowFixedWidthVector[T: AnyTrivialRegType]:
    # TODO: support null values
    var length: Int
    var null_count: Int
    var validity: Bitmap
    var value: Pointer[UInt8]
    var view: Pointer[T]

    var mem_use: Int

    fn __init__(inout self, values: List[T]):
        var byte_width = sizeof[T]()
        var num_bytes = len(values) * byte_width
        var num_bytes_with_padding = (
            (num_bytes + PADDING - 1) // PADDING
        ) * PADDING
        var ui8_ptr = Pointer[UInt8].alloc(
            num_bytes_with_padding, alignment=ALIGNMENT
        )
        var ptr = ui8_ptr.bitcast[T]()
        memset_zero(ptr, num_bytes_with_padding)

        var validity_list = List[Bool](len(values))

        for i in range(values.size):
            validity_list.append(True)
            var val = values[i]
            ptr.store(i, val)

        self.value = ui8_ptr
        self.validity = Bitmap(validity_list)
        self.null_count = 0
        self.view = ptr
        self.length = len(values)
        self.mem_use = num_bytes_with_padding

    fn __getitem__(self, index: Int) raises -> T:
        if index < 0 or index >= self.length:
            raise Error("index out of range for ArrowFixedWidthVector")
        return self.view.load(index)

    fn __len__(self) -> Int:
        return self.length

    fn __del__(owned self):
        self.value.free()


struct ArrowIntVector:
    """
    Temporary solution until we can create ArrowFixedWidthVector[Int]
    Depends on https://github.com/modularml/mojo/issues/2956 to be fixed.
    """

    var length: Int
    var null_count: Int
    var validity: Bitmap
    var value: Pointer[UInt8]
    var view: Pointer[Int]

    var mem_use: Int

    fn __init__(inout self, values: List[Int]):
        var byte_width = sizeof[Int]()
        var num_bytes = len(values) * byte_width
        var num_bytes_with_padding = (
            (num_bytes + PADDING - 1) // PADDING
        ) * PADDING
        var ui8_ptr = Pointer[UInt8].alloc(
            num_bytes_with_padding, alignment=ALIGNMENT
        )
        var ptr = ui8_ptr.bitcast[Int]()
        memset_zero(ptr, num_bytes_with_padding)

        var validity_list = List[Bool](len(values))

        for i in range(values.size):
            validity_list.append(True)
            var val = values[i]
            ptr.store(i, val)

        self.value = ui8_ptr
        self.validity = Bitmap(validity_list)
        self.null_count = 0
        self.view = ptr
        self.length = len(values)
        self.mem_use = num_bytes_with_padding

    fn __getitem__(self, index: Int) raises -> Int:
        if index < 0 or index >= self.length:
            raise Error("index out of range for ArrowIntVector")
        return self.view.load(index)

    fn __len__(self) -> Int:
        return self.length

    fn __del__(owned self):
        self.value.free()
