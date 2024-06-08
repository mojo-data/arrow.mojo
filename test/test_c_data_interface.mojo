from arrow import ArrowArray, ArrowSchema
from python import Python


def test_arrow_c_load():
    var sys = Python.import_module("sys")
    for p in sys.path:
        print(p)

    var pd = Python.import_module("pandas")
    var pa = Python.import_module("pyarrow")

    df = pd.read_csv("./test_data.csv")
    rb = pa.record_batch(df)


def main():
    test_arrow_c_load()
