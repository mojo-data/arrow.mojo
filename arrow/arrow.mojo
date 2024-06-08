from memory.unsafe import Pointer
from memory import memset_zero


alias PADDING = 64


struct Bitmap(AnyType):
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
            num_bytes_with_padding, alignment=PADDING
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

    fn __getitem__(self, index: Int) -> Bool:
        var byte_index = index // 8
        var bit_index = index % 8
        var bit_mask: UInt8 = 0b10000000 >> bit_index
        return ((self.data.load(byte_index) & bit_mask) != 0).__bool__()

    fn __len__(self) -> Int:
        return self.length

    fn __del__(owned self):
        self.data.free()


struct ArrowBoolArray:
    var validity: Bitmap
    var buffer: Bitmap


struct ArrowFixedWidthBuffer[T: AnyTrivialRegType](AnyType):
    # maybe use Dtype for T instead of AnyType, but DynamicVector uses AnyType
    var data: Pointer[UInt8]
    var view: Pointer[T]
    var length: Int
    var mem_use: Int

    fn __init__(inout self, values: List[T]):
        var byte_width = sizeof[T]()
        var num_bytes = len(values) * byte_width
        var num_bytes_with_padding = (
            (num_bytes + PADDING - 1) // PADDING
        ) * PADDING
        var ui8_ptr = Pointer[UInt8].alloc(
            num_bytes_with_padding, alignment=PADDING
        )
        var ptr = ui8_ptr.bitcast[T]()
        memset_zero(ptr, num_bytes_with_padding)

        for i in range(values.size):
            ptr.store(i, values[i])

        self.data = ui8_ptr
        self.view = ptr
        self.length = len(values)
        self.mem_use = num_bytes_with_padding

    fn __getitem__(self, index: Int) -> T:
        # TODO: bounds check
        return self.view.load(index)

    fn __len__(self) -> Int:
        return self.length

    fn __del__(owned self):
        self.data.free()
