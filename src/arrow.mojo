from utils.vector import DynamicVector
from memory.unsafe import Pointer
from memory import memset_zero


alias PADDING = 64


@value
struct Bitmap:
    var data: Pointer[UInt8]
    var length: Int
    var mem_use: Int

    fn __init__(inout self, bools: DynamicVector[Bool]):
        """
        Arrow buffers are recommended to have an alignment and padding of 64 bytes
        source: https://arrow.apache.org/docs/format/Columnar.html#buffer-alignment-and-padding.
        """
        let num_bytes = ((len(bools)) + 7) // 8
        let num_bytes_with_padding = ((num_bytes + PADDING - 1) // PADDING) * PADDING
        let ptr = Pointer[UInt8].aligned_alloc(PADDING, num_bytes_with_padding)
        memset_zero(ptr, num_bytes_with_padding)

        for i in range(len(bools)):
            let idx = (i // 8)
            let bit_mask: UInt8 = 0b10000000 >> (i % 8) if (
                bools[i]
            ) else 0  # TODO non branching version when it exists
            ptr.store(idx, ptr.load(idx) | bit_mask)

        self.data = ptr
        self.length = len(bools)
        self.mem_use = num_bytes_with_padding

    fn __getitem__(self, index: Int) -> Bool:
        let byte_index = index // 8
        let bit_index = index % 8
        let bit_mask: UInt8 = 0b10000000 >> bit_index
        return ((self.data.load(byte_index) & bit_mask) != 0).__bool__()

    fn __len__(self) -> Int:
        return self.length


@value
struct ArrowBoolArray:
    var validity: Bitmap
    var buffer: Bitmap


struct ArrowFixedWidthBuffer[T: AnyType]:
    # maybe use Dtype for T instead of AnyType, but DynamicVector uses AnyType
    var data: Pointer[UInt8]
    var length: Int
    var mem_use: Int

    fn __init__(inout self, values: DynamicVector[T]):
        let byte_width = sizeof[T]()
        let num_bytes = len(values) * byte_width
        let num_bytes_with_padding = ((num_bytes + PADDING - 1) // PADDING) * PADDING
        let ui8_ptr = Pointer[UInt8].aligned_alloc(PADDING, num_bytes_with_padding)
        let ptr = ui8_ptr.bitcast[T]()
        memset_zero(ptr, num_bytes_with_padding)

        for i in range(values.size):
            ptr.store(i, values[i])

        self.data = ui8_ptr
        self.length = len(values)
        self.mem_use = num_bytes_with_padding

    fn __getitem__(self, index: Int) -> T:
        # TODO: bounds check
        let ptr = self.data.bitcast[T]()
        return ptr.load(index)

    fn __len__(self) -> Int:
        return self.length
