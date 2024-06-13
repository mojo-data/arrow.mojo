from arrow.util import ALIGNMENT, get_num_bytes_with_padding


@value
struct BinaryBuffer:
    var _buffer: Pointer[UInt8]
    var length: Int
    var mem_used: Int

    fn __init__(inout self, length_unpadded: Int):
        self.length = length_unpadded
        self.mem_used = get_num_bytes_with_padding(length_unpadded)
        self._buffer = Pointer[UInt8].alloc(self.mem_used, alignment=ALIGNMENT)
        memset_zero(self._buffer, self.mem_used)

    fn __init__(inout self, values: List[UInt8]):
        self = Self(len(values))
        self._unsafe_set_sequence(0, values)

    @always_inline
    fn _unsafe_setitem(self, index: Int, value: UInt8):
        self._buffer.store(index, value)

    fn __setitem__(self, index: Int, value: UInt8) raises:
        if index < 0 or index >= self.length:
            raise Error("index out of range for BinaryBuffer")
        self._unsafe_setitem(index, value)

    @always_inline
    fn _unsafe_getitem(self, index: Int) -> UInt8:
        return self._buffer.load(index)

    fn __getitem__(self, index: Int) raises -> UInt8:
        if index < 0 or index >= self.length:
            raise Error("index out of range for BinaryBuffer")
        return self._unsafe_getitem(index)

    fn _unsafe_set_sequence(self, start: Int, values: List[UInt8]):
        for i in range(len(values)):
            self._unsafe_setitem(start + i, values[i])

    fn set_sequence(self, start: Int, values: List[UInt8]) raises:
        if start < 0 or start + len(values) > self.length:
            raise Error("index out of range for BinaryBuffer")
        self._unsafe_set_sequence(start, values)

    fn _unsafe_get_sequence(self, start: Int, length: Int) -> List[UInt8]:
        var values = List[UInt8](capacity=length)
        for i in range(length):
            values.append(self._unsafe_getitem(start + i))
        return values

    fn get_sequence(self, start: Int, length: Int) raises -> List[UInt8]:
        if start < 0 or start + length > self.length:
            raise Error("index out of range for BinaryBuffer")
        return self._unsafe_get_sequence(start, length)

    fn __len__(self) -> Int:
        return self.length

    # Lifecycle methods

    fn __moveinit__(inout self, owned existing: BinaryBuffer):
        self._buffer = existing._buffer
        self.length = existing.length
        self.mem_used = existing.mem_used

    fn __copyinit__(inout self, existing: BinaryBuffer):
        self.length = existing.length
        self.mem_used = existing.mem_used
        self._buffer = Pointer[UInt8].alloc(self.mem_used, alignment=ALIGNMENT)
        for i in range(self.mem_used):
            self._buffer.store(i, existing._buffer.load(i))

    fn __del__(owned self):
        self._buffer.free()
