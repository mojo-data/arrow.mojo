from arrow import ArrowArray, ArrowSchema
from python import Python


def test_arrow_c_load():
    var pd = Python.import_module("pandas")
    var pa = Python.import_module("pyarrow")

    df = pd.read_csv("./test_data.csv")
    rb = pa.record_batch(df)
    # rb.schema. = "some_name"

    var schema = UnsafePointer[ArrowSchema]().alloc(1)
    var array = UnsafePointer[ArrowArray]().alloc(1)
    rb.schema._export_to_c(int[UnsafePointer[ArrowSchema]](schema))
    print(String(UnsafePointer(schema[].format.address)))
    print(String(UnsafePointer(schema[].name.address)))

    rb._export_to_c(int[UnsafePointer[ArrowArray]](array))
    print(array[].length)
    print(array[].n_buffers)
    print(array[].n_children)
    print(array[].children[0][].length)
    print(array[].children[1][].length)
    print(array[].children[2][].length)
    print(String(UnsafePointer(schema[].children[0][].format.address)))
    print(String(UnsafePointer(schema[].children[1][].format.address)))
    print(String(UnsafePointer(schema[].children[2][].format.address)))


def main():
    test_arrow_c_load()
