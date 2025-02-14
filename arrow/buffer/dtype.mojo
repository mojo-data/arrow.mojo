from arrow.util import ALIGNMENT, get_num_bytes_with_padding


struct DTypeBuffer[element_type: DType]:
    alias _scalar_type = Scalar[element_type]
    alias _ptr_type = UnsafePointer[Self._scalar_type]
    alias element_byte_width = sizeof[Scalar[element_type]]()
    var _buffer: Self._ptr_type
    var length: Int
    var mem_used: Int

    fn __init__(mut self, length: Int = 0):
        self.length = length
        var num_bytes = self.length * Self.element_byte_width
        self.mem_used = get_num_bytes_with_padding(num_bytes)

        var alloc_count = self.mem_used // Self.element_byte_width
        self._buffer = Self._ptr_type.alloc(alloc_count, alignment=ALIGNMENT)
        memset_zero(self._buffer, alloc_count)

    fn __init__(mut self, values: List[Self._scalar_type]):
        self = Self(len(values))
        for i in range(len(values)):
            self._unsafe_setitem(i, values[i])

    @always_inline
    fn _unsafe_getitem(self, index: Int) -> Self._scalar_type:
        return self._buffer[index]

    fn __getitem__(self, index: Int) raises -> Self._scalar_type:
        if index < 0 or index >= self.length:
            raise Error("index out of range for DTypeBuffer")
        return self._unsafe_getitem(index)

    @always_inline
    fn _unsafe_setitem(self, index: Int, value: Self._scalar_type):
        self._buffer[index] = value

    fn __setitem__(self, index: Int, value: Self._scalar_type) raises:
        if index < 0 or index >= self.length:
            raise Error("index out of range for DTypeBuffer")
        self._unsafe_setitem(index, value)

    fn __len__(self) -> Int:
        return self.length

    fn __moveinit__(mut self, owned existing: Self):
        self._buffer = existing._buffer
        self.length = existing.length
        self.mem_used = existing.mem_used

    fn __copyinit__(mut self, existing: Self):
        self.length = existing.length
        self.mem_used = existing.mem_used
        self._buffer = Self._ptr_type.alloc(self.mem_used, alignment=ALIGNMENT)
        for i in range(self.mem_used):
            self._buffer[i] = existing._buffer[i]

    fn __del__(owned self):
        self._buffer.free()
