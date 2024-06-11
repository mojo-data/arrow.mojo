from memory.unsafe import Pointer
from memory import memset_zero
from arrow.util import PADDING, ALIGNMENT, get_num_bytes_with_padding


struct Bitmap(StringableRaising):
    """Bitmap according to the Apache Arrow specification which can found here.

    Source: https://arrow.apache.org/docs/format/Columnar.html#validity-bitmaps

    The source provides this pseudo code:
    ```
    is_valid[j] -> bitmap[j / 8] & (1 << (j % 8))
    ```

    And the following explanation:
    > We use least-significant bit (LSB) numbering (also known as bit-endianness). This means that within a group of 8 bits, we read right-to-left:
    ```
    values = [0, 1, null, 2, null, 3]

    bitmap
    j mod 8   7  6  5  4  3  2  1  0
              0  0  1  0  1  0  1  1
    ```
    """

    var data: Pointer[UInt8]
    var length: Int
    var mem_used: Int

    fn __init__(inout self, bools: List[Bool]):
        """
        Arrow buffers are recommended to have an alignment and padding of 64 bytes
        source: https://arrow.apache.org/docs/format/Columnar.html#buffer-alignment-and-padding.
        """
        var num_bytes = ((len(bools)) + 7) // 8
        var num_bytes_with_padding = get_num_bytes_with_padding(num_bytes)
        var ptr = Pointer[UInt8].alloc(
            num_bytes_with_padding, alignment=ALIGNMENT
        )
        memset_zero(ptr, num_bytes_with_padding)

        for i in range(len(bools)):
            var byte_index = (i // 8)
            var bitmask = UInt8(bools[i].__int__()) << (i % 8)
            var new_byte = ptr.load(byte_index) | bitmask
            ptr.store(byte_index, new_byte)

        self.data = ptr
        self.length = len(bools)
        self.mem_used = num_bytes_with_padding

    @always_inline
    fn _unsafe_getitem(self, index: Int) -> Bool:
        var byte_index = index // 8
        var bitmask: UInt8 = 1 << (index % 8)
        return ((self.data.load(byte_index) & bitmask)).__bool__()

    fn __getitem__(self, index: Int) raises -> Bool:
        if index < 0 or index >= self.length:
            raise Error("index out of range for Bitmap")
        return self._unsafe_getitem(index)

    fn __len__(self) -> Int:
        return self.length

    fn __del__(owned self):
        self.data.free()

    fn __moveinit__(inout self, owned existing: Bitmap):
        self.data = existing.data
        self.length = existing.length
        self.mem_used = existing.mem_used

    fn __copyinit__(inout self, existing: Bitmap):
        self.data = Pointer[UInt8].alloc(existing.mem_used, alignment=ALIGNMENT)
        for i in range(existing.mem_used):
            self.data.store(i, existing.data.load(i))
        self.length = existing.length
        self.mem_used = existing.mem_used

    fn __str__(self) raises -> String:
        var output: String = "["
        for i in range(self.length):
            output = output + self[i].__str__()
            if i < self.length - 1:
                output = output + ", "
        return output + "]"

    fn to_list(self) raises -> List[Bool]:
        var bools = List[Bool](capacity=self.length)
        for i in range(self.length):
            bools.append(self[i])
        return bools
