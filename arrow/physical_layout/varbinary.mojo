from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.arrow import Bitmap
from arrow.buffer import BinaryBuffer, OffsetBuffer


struct ArrowStringVector:
    """Each value in this layout consists of 0 or more bytes. While primitive
    arrays have a single values buffer, variable-size binary have an offsets
    buffer and data buffer.

    For example, the position and length of slot j is computed as:
    ```
    slot_position = offsets[j]
    slot_length = offsets[j + 1] - offsets[j]  // (for 0 <= j < length)
    ```
    It should be noted that a null value may have a positive slot length. That
    is, a null value may occupy a non-empty memory space in the data buffer.
    When this is true, the content of the corresponding memory space is
    undefined.

    Offsets must be monotonically increasing, that is offsets[j+1] >= offsets[j]
    for 0 <= j < length, even for null slots. This property ensures the location
    for all values is valid and well defined.

    Generally the first slot in the offsets array is 0, and the last slot is the
    length of the values array. When serializing this layout, we recommend
    normalizing the offsets to start at 0.

    Example Layout: ``VarBinary``
    ```
    ['joe', null, null, 'mark']
    ```

    will be represented as follows:

    * Length: 4, Null count: 2
    * Validity bitmap buffer:

    | Byte 0 (validity bitmap) | Bytes 1-63            |
    |--------------------------|-----------------------|
    | 00001001                 | 0 (padding)           |

    * Offsets buffer:

    | Bytes 0-19     | Bytes 20-63           |
    |----------------|-----------------------|
    | 0, 3, 3, 3, 7  | unspecified (padding) |

    * Value buffer:

    | Bytes 0-6      | Bytes 7-63            |
    |----------------|-----------------------|
    | joemark        | unspecified (padding) |
    """

    var length: Int
    """The length of the vector."""
    var null_count: Int
    """The amount of nulls in the vector."""
    var validity: Bitmap
    """Whether any array slot is valid (non-null). A 1 (set bit) for index j
    indicates that the value is not null, while a 0 (bit not set) indicates that
    it is null.
    """
    var offsets: OffsetBuffer
    """The offsets buffer which encodes the start position of each slot in the
    data buffer.
    """
    var value_buffer: BinaryBuffer
    """A Buffer of UInt8 bytes."""
    var mem_used: Int
    """The amount of bytes used."""

    fn __init__(inout self, values: List[String]):
        """Construct an `ArrowStringVector` from a List[String].

        Args:
            values: The List.
        """
        var validity_list = List[Bool](capacity=len(values))
        var offset_list = List[Int](capacity=len(values) + 1)

        # Calculate the size of the buffer and allocate it
        var buffer_size = 0
        for i in range(len(values)):
            buffer_size += values[i]._buffer.size
        self.value_buffer = BinaryBuffer(buffer_size)

        offset_list.append(0)
        var offset_cursor = 0
        for i in range(len(values)):
            validity_list.append(True)
            var bytes = values[i].as_bytes()
            self.value_buffer._unsafe_set_sequence(offset_cursor, bytes)
            offset_cursor += len(bytes)
            offset_list.append(offset_cursor)

        self.length = len(values)
        self.null_count = 0
        self.validity = Bitmap(validity_list)
        self.offsets = OffsetBuffer(offset_list)
        self.mem_used = self.value_buffer.mem_used + self.offsets.mem_used

    fn __getitem__(self, index: Int) raises -> String:
        """Get an item at the given index.

        Args:
            index: The index.

        Returns:
            The value.

        Raises:
            - index out of range for ArrowFixedWidthVector.
        """

        if index < 0 or index >= self.length:
            raise Error("index out of range for ArrowStringVector")
        var start = self.offsets[index]
        var length = self.offsets[index + 1] - start

        var bytes = self.value_buffer._unsafe_get_sequence(start, length)
        bytes.extend(
            List(UInt8(0))
        )  # TODO: null terminate string without copying
        return String(bytes)

    fn __len__(self) -> Int:
        """Get the length.

        Returns:
            The length.
        """

        return self.length
