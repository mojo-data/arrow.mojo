from arrow.buffer.bitmap import Bitmap


struct ArrowBooleanArray:
    var length: Int
    var null_count: Int
    var _validity: Bitmap
    var _buffer: Bitmap
    var mem_used: Int

    fn __init__(inout self, values: List[Bool]):
        self.length = len(values)
        self.null_count = 0
        self._validity = Bitmap(List(True) * len(values))
        self._buffer = Bitmap(values)
        self.mem_used = self._validity.mem_used + self._buffer.mem_used

    fn __init__(inout self, length: Int):
        self.length = length
        self.null_count = 0
        self._validity = Bitmap(List(True) * length)
        self._buffer = Bitmap(length)
        self.mem_used = self._validity.mem_used + self._buffer.mem_used

    fn __init__(inout self, values: List[Optional[Bool]]):
        self.length = len(values)
        self.null_count = 0
        var validity_list = List[Bool](capacity=len(values))
        var value_list = List[Bool](capacity=len(values))

        for i in range(len(values)):
            if values[i] is None:
                validity_list.append(False)
                self.null_count += 1
            else:
                validity_list.append(True)
                value_list.append(
                    values[i].or_else(False)
                )  # TODO: pattern match instead of or_else

        self._validity = Bitmap(validity_list)
        self._buffer = Bitmap(value_list)
        self.mem_used = self._validity.mem_used + self._buffer.mem_used

    fn __len__(self) -> Int:
        return self.length

    fn __getitem__(self, index: Int) raises -> Optional[Bool]:
        if index < 0 or index >= self.length:
            raise Error("index out of range for ArrowBoolVector")
        if self._validity._unsafe_getitem(index):
            return self._buffer._unsafe_getitem(index)
        return None
