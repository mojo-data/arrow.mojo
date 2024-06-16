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

    alias _ptr_type = DTypePointer[DType.uint8]
    var _buffer: Self._ptr_type
    var length: Int
    var mem_used: Int
    # TODO maybe buffers shouldn't have length and mem_used, just size.
    # The layouts that use the buffers can keep track of their length.

    fn __init__(inout self, length_unpadded: Int):
        """Creates a new Bitmap that supports at least `length_unpadded` elements.

        Args:
            length_unpadded: The number of elements the Bitmap should support.
                Buffers are typically padded to 32, 64, or 128 bytes but it
                depends on the architecture.
        """
        var num_bytes = (length_unpadded + 7) // 8
        var num_bytes_with_padding = get_num_bytes_with_padding(num_bytes)

        self._buffer = Self._ptr_type.alloc(
            num_bytes_with_padding, alignment=ALIGNMENT
        )
        memset_zero(self._buffer, num_bytes_with_padding)
        self.length = length_unpadded
        self.mem_used = num_bytes_with_padding

    fn __init__(inout self, bools: List[Bool]):
        self = Self(len(bools))

        for i in range(len(bools)):
            self._unsafe_setitem(i, bools[i])

    fn _unsafe_setitem(self, index: Int, value: Bool):
        """Doesn't check if index is out of bounds.
        Only works if memory is true, doesn't work if memory is 1 and value is False
        """
        var byte_index = index // 8
        var bitmask = UInt8(value.__int__()) << (index % 8)
        var new_byte = self._buffer[
            byte_index
        ] | bitmask  # only works if memory is 0
        self._buffer[byte_index] = new_byte

    @always_inline
    fn _unsafe_getitem(self, index: Int) -> Bool:
        """Doesn't check if index is out of bounds.

        Follows this pseudo code from the Apache Arrow specification

        `is_valid[j] -> bitmap[j / 8] & (1 << (j % 8))`
        """
        var byte_index = index // 8
        var bitmask: UInt8 = 1 << (index % 8)
        return ((self._buffer[byte_index] & bitmask)).__bool__()

    fn __getitem__(self, index: Int) raises -> Bool:
        if index < 0 or index >= self.length:
            raise Error("index out of range for Bitmap")
        return self._unsafe_getitem(index)

    fn __len__(self) -> Int:
        return self.length

    fn __del__(owned self):
        self._buffer.free()

    fn __moveinit__(inout self, owned existing: Bitmap):
        self._buffer = existing._buffer
        self.length = existing.length
        self.mem_used = existing.mem_used

    fn __copyinit__(inout self, existing: Bitmap):
        self._buffer = Self._ptr_type.alloc(
            existing.mem_used, alignment=ALIGNMENT
        )
        for i in range(existing.mem_used):
            self._buffer[i] = existing._buffer[i]
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
