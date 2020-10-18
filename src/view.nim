import sequtils
import utils

type
    VectorView*[T: int|float32|float32] = ref object
        data: seq[T]
        index: seq[int]
    MatrixView*[T: int|float32|float32] = ref object
        data: seq[seq[T]]
        index: seq[int]
        columns: seq[int]
    ColumnMatrixView*[T: int|float32|float32] = ref object
        data: seq[seq[T]]
        index: seq[int]
        fixed: int


proc new_vector_view*[T: int|float32|float32](data: seq[T], index: seq[int]): VectorView[T] =
    result = new(VectorView[T])
    result.data := data
    result.index = index

proc new_vector_view*[T: int|float32|float32](v: VectorView[T], index: seq[int]): VectorView[T] =
    new_vector_view(v.data, index)
    

proc new_matrix_view*[T: int|float32|float32](data: seq[seq[T]], index, columns: seq[int]): MatrixView[T] =
    result = new(MatrixView[T])
    result.data := data
    result.index = index
    result.columns = columns

proc new_matrix_view*[T: int|float32|float32](data: seq[seq[T]], index: seq[int]): MatrixView[T] =
    new_matrix_view(data, index, (0..<data[0].len).to_seq)
    
proc new_matrix_view*[T: int|float32|float32](m: MatrixView[T], index: seq[int]): MatrixView[T] =
    new_matrix_view(m.data, index, m.columns)
        
proc new_matrix_view*[T: int|float32|float32](m: MatrixView[T], index, columns: seq[int]): MatrixView[T] =
    new_matrix_view(m.data, index, columns)
    
proc set_index*[T: int|float32|float32, V: VectorView[T] | MatrixView[T]](m: V, index: seq[int]) =
    m.index = index

proc column*[T: int | float32](m: MatrixView[T], col: int): ColumnMatrixView[T] =
    result = new(ColumnMatrixView[T])
    result.data := m.data
    result.index = m.index
    result.fixed = col

proc get_raw*[T: int | float32](v: VectorView[T], i: int): T =
    v.data[i]

proc len*[T: int|float32|float32](m: MatrixView[T]): int = m.index.len
proc ncols*[T: int|float32|float32](m: MatrixView[T]): int = m.data[0].len
proc len*[T: int|float32|float32](m: VectorView[T]): int = m.index.len
proc len*[T: int|float32|float32](m: ColumnMatrixView[T]): int = m.index.len

iterator items*[T: int|float32|float32](c: ColumnMatrixView[T]): T =
    for i in c.index:
        yield c.data[i][c.fixed]

iterator pairs*[T: int|float32|float32](c: ColumnMatrixView[T]): tuple[i: int, v: T] =
    for i in c.index:
        yield (i, c.data[i][c.fixed])

iterator items*[T: int|float32|float32](c: VectorView[T]): T =
    for i in c.index:
        yield c.data[i]

iterator pairs*[T: int|float32|float32](c: VectorView[T]): tuple[i: int, v: T] =
    for i in c.index:
        yield (i, c.data[i])

proc `[]`*[T: int|float32|float32](v: VectorView[T], i: int): T =
    v.data[v.index[i]]



proc to_seq*[T: int | float32](c: ColumnMatrixView[T]): seq[T] =
    result = new_seq[T](c.len)
    var i = 0
    for v in c:
        result[i] = v
        inc i

proc to_seq*[T: int | float32](c: VectorView[T]): seq[T] =
    result = new_seq[T](c.len)
    var i = 0
    for v in c:
        result[i] = v
        inc i
        