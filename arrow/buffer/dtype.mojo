from arrow.util import ALIGNMENT, get_num_bytes_with_padding


struct DTypeBuffer[type: DType]:
    alias _ptr_type = DTypePointer[type]
    alias element_type = Scalar[type]
    alias element_byte_width = sizeof[Self.element_type]()
    var _buffer: Self._ptr_type
    var length: Int
    var mem_used: Int

    fn __init__(inout self, length: Int):
        self.length = length
        var num_bytes = self.length * Self.element_byte_width
        self.mem_used = get_num_bytes_with_padding(num_bytes)

        var alloc_count = self.mem_used // Self.element_byte_width
        self._buffer = Self._ptr_type.alloc(alloc_count, alignment=ALIGNMENT)
        memset_zero(self._buffer, alloc_count)

    fn __init__(inout self, values: List[Int]):
        self = Self(len(values))
        for i in range(len(values)):
            self._unsafe_setitem(i, values[i])

    @always_inline
    fn _unsafe_getitem(self, index: Int) -> Self.element_type:
        return self._buffer[index]

    fn __getitem__(self, index: Int) raises -> Self.element_type:
        if index < 0 or index >= self.length:
            raise Error("index out of range for DTypeBuffer")
        return self._unsafe_getitem(index)

    @always_inline
    fn _unsafe_setitem(self, index: Int, value: Self.element_type):
        self._buffer[index] = value

    fn __setitem__(self, index: Int, value: Self.element_type) raises:
        if index < 0 or index >= self.length:
            raise Error("index out of range for DTypeBuffer")
        self._unsafe_setitem(index, value)

    fn __len__(self) -> Int:
        return self.length

    fn __moveinit__(inout self, owned existing: Self):
        self._buffer = existing._buffer
        self.length = existing.length
        self.mem_used = existing.mem_used

    fn __copyinit__(inout self, existing: Self):
        self.length = existing.length
        self.mem_used = existing.mem_used
        self._buffer = Self._ptr_type.alloc(self.mem_used, alignment=ALIGNMENT)
        for i in range(self.mem_used):
            self._buffer[i] = existing._buffer[i]

    fn __del__(owned self):
        self._buffer.free()
