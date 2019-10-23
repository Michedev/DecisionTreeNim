import neo
import utils

type 
    MatrixView*[T: int|float] {.shallow.} = ref object of RootObj
        row_index*: seq[int] 
        col_index*: seq[int]
        original*: Matrix[T]
    VectorView*[T: int|float] {.shallow.} = ref object of RootObj
        index*: seq[int]
        original*: Vector[T]
    ColMatrixView*[T: int|float] {.shallow.} = ref object of RootObj
        row_index*: seq[int]
        col_index*: int
        original*: Matrix[T]

proc M*[T: int|float](m: MatrixView[T]): int {.inline.} =
    m.row_index.len

proc nrows*[T: int|float](m: MatrixView[T]): int {.inline.} =
    m.row_index.len
    
proc N*[T: int|float](m: MatrixView[T]): int {.inline.} =
    m.col_index.len
    
proc ncols*[T: int|float](m: MatrixView[T]): int {.inline.} =
    m.col_index.len

proc len*[T: int|float](v: VectorView[T]): int {.inline.} =
    v.index.len

proc len*[T: int|float](v: ColMatrixView[T]): int {.inline.} =
    v.row_index.len
    
    
proc new_matrix_view*[T: int|float](m: Matrix[T], row_index, col_index: seq[int]): MatrixView[T] =
    result = new(MatrixView[T])
    result.row_index := row_index
    result.col_index := col_index
    result.original = m

proc new_matrix_view*[T: int|float](m: Matrix[T], row_index: seq[int]): MatrixView[T] =
    ##Create matrix view taking all columns
    result = new(MatrixView[T])
    result.row_index := row_index
    result.col_index := ((0..<m.N).toSeq)
    result.original = m

proc new_matrix_view*[T: int|float](m: MatrixView[T], row_index, col_index: seq[int]): MatrixView[T] =
    result = new(MatrixView[T])
    result.row_index := row_index
    result.col_index := col_index
    result.original = m.original
    
    
proc new_matrix_view*[T: int|float](m: MatrixView[T], row_index: seq[int]): MatrixView[T] =
    ##Create matrix view taking all columns
    result = new(MatrixView[T])
    result.row_index := row_index
    result.col_index := (0..<m.N).toSeq
    result.original = m.original
    

proc new_vector_view*[T: int|float](v: Vector[T], index: seq[int]): VectorView[T] =
    result = new(VectorView[T])
    result.index := index
    result.original = v

proc new_vector_view*[T: int|float](v: VectorView[T], index: seq[int]): VectorView[T] {.inline.}=
    result = new(VectorView[T])
    result.index := index
    result.original = v.original

proc new_col_matrix_view*[T: int|float](m: MatrixView[T], j: Natural, row_index: seq[int]): ColMatrixView[T] =
    result = new(ColMatrixView[T])
    result.original = m.original
    result.col_index = j
    result.row_index := row_index
    
    
func `[]`*[T: int|float](v: VectorView[T], i: int): T =
    v.original[v.index[i]]
    
func `[]`*[T: int|float](v: ColMatrixView[T], i: int): T =
    v.original[v.row_index[i], v.col_index]
    

func shape*[T: int|float](m: MatrixView[T]): array[2, int] = [m.row_index.len, m.col_index.len]

proc column*[T: int|float](m: MatrixView[T], j: Natural): ColMatrixView[T] =
    result = new(ColMatrixView[T])
    result.original = m.original
    result.col_index = j
    result.row_index := m.row_index


proc row*[T: int|float](m: MatrixView[T], i: Natural): VectorView[T] =
    new_vector_view(m.original.row(i), m.col_index)


iterator items*[T: int|float](v: ColMatrixView[T]): T =
    for i in v.row_index:
        yield v.original[i, v.col_index]

iterator pairs*[T: int|float](v: ColMatrixView[T]): tuple[i: int, value: T] =
    var i: Natural = 0
    for value in v:
        yield (i, value)
        inc i

iterator items*[T: int|float](v: VectorView[T]): T =
    for i in v.index:
        yield v.original[i]      
    

iterator pairs*[T: int|float](v: VectorView[T]): tuple[i: int, value: T] =
    var i: Natural = 0
    for value in v:
        yield (i, value)
        inc i

iterator rows*[T: int|float](m: MatrixView[T]): Vector[T] =
    if m.original.N == m.col_index.len:
        for i_row in m.row_index:
            yield m.original.row(i_row)
    else:
        for i_row in m.row_index:
            let original_row = m.original.row(i_row)
            let projected_col = zeros(m.col_index.len)
            for i, i_col in m.col_index:
                projected_col[i] = original_row[i_col]
            yield projected_col

proc to_vector*[T: int|float](v: VectorView[T]): Vector[T] =
    result = zeros[T](v.len)
    for i, value in v:
        result[i] = value


proc toSeq*[T: int|float](vector: ColMatrixView[T]): seq[T] =
    result = new_seq[int](vector.row_index.len)
    for i, value in vector:
        result[i] = value