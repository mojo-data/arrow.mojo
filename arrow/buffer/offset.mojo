from arrow.util import ALIGNMENT, get_num_bytes_with_padding


struct OffsetBuffer:
    var _buffer: Pointer[UInt8]
    var _buffer_int_view: Pointer[Int]
    var length: Int
    var mem_used: Int

    fn __init__(inout self, length: Int):
        self.length = length
        var byte_width = sizeof[Int]()
        var num_bytes = self.length * byte_width
        self.mem_used = get_num_bytes_with_padding(num_bytes)
        self._buffer = Pointer[UInt8].alloc(self.mem_used, alignment=ALIGNMENT)
        memset_zero(self._buffer, self.mem_used)
        self._buffer_int_view = self._buffer.bitcast[Int]()

    fn __init__(inout self, values: List[Int]):
        self = Self(len(values))
        for i in range(len(values)):
            self._unsafe_setitem(i, values[i])

    @always_inline
    fn _unsafe_getitem(self, index: Int) -> Int:
        return self._buffer_int_view.load(index)

    fn __getitem__(self, index: Int) raises -> Int:
        if index < 0 or index >= self.length:
            raise Error("index out of range for OffsetBuffer")
        return self._unsafe_getitem(index)

    @always_inline
    fn _unsafe_setitem(self, index: Int, value: Int):
        self._buffer_int_view.store(index, value)

    fn __setitem__(self, index: Int, value: Int) raises:
        if index < 0 or index >= self.length:
            raise Error("index out of range for OffsetBuffer")
        self._unsafe_setitem(index, value)

    fn __len__(self) -> Int:
        return self.length

    fn __moveinit__(inout self, owned existing: OffsetBuffer):
        self._buffer = existing._buffer
        self._buffer_int_view = existing._buffer_int_view
        self.length = existing.length
        self.mem_used = existing.mem_used

    fn __copyinit__(inout self, existing: OffsetBuffer):
        self.length = existing.length
        self.mem_used = existing.mem_used
        self._buffer = Pointer[UInt8].alloc(self.mem_used, alignment=ALIGNMENT)
        for i in range(self.mem_used):
            self._buffer.store(i, existing._buffer.load(i))
        self._buffer_int_view = self._buffer.bitcast[Int]()

    fn __del__(owned self):
        self._buffer.free()
