import matrix_view
import neo
import math
import utils
import sequtils
import sets

proc true_index_sorted(index_sorted: Matrix[int], index_not_ordered: HashSet[int], col_index: int): seq[int] =
    result = new_seq[int](index_not_ordered.len)
    var curr_i = 0
    var i_sorted_index = 0
    while i_sorted_index < index_not_ordered.len:
        let value = index_sorted[curr_i, col_index]
        if value in index_not_ordered:
            result[i_sorted_index] = value
            inc i_sorted_index
        inc curr_i

type 
    Dimension* = enum
        Row,
        Column
    MatrixViewSorted*[T: int|float] = ref object
        index_sorted*: Matrix[int]
        col_index*: seq[int]
        row_index*: seq[int]
        original: Matrix[T]
    ColMatrixViewSorted*[T: int|float] = ref object
        original*: Matrix[T]
        row_index*: seq[int]
        col_index*: int

proc len*(c: ColMatrixViewSorted): int =
    c.row_index.len

proc new_matrix_view_sorted*[T: int|float](m: Matrix[T], row_index, col_index :seq[int]): MatrixViewSorted[T] =
    result = new(MatrixViewSorted[T])
    var index_sorted = newSeq[seq[int]](m.N)
    for i_col in col_index:
        index_sorted[i_col] = m.column(i_col).argsort
    result.index_sorted = index_sorted.matrix(rowMajor).T
    result.row_index = row_index
    result.col_index = col_index
    result.original = m

proc new_matrix_view_sorted*[T: int|float](m: Matrix[T], row_index:seq[int]): MatrixViewSorted[T] =
    new_matrix_view_sorted(m, row_index, (0..<m.N).to_seq)


proc new_matrix_view_sorted*[T: int|float](m: MatrixViewSorted[T], row_index : seq[int]): MatrixViewSorted[T] =
    result = new(MatrixViewSorted[T])
    result.index_sorted = m.index_sorted
    result.row_index = m.row_index
    result.col_index = (0..<m.original.N).to_seq()
    result.original = m.original


proc new_matrix_view_sorted*[T: int|float](m: MatrixViewSorted[T], row_index, col_index : seq[int]): MatrixViewSorted[T] =
    result = new(MatrixViewSorted[T])
    result.row_index := row_index
    result.col_index := col_index
    result.original = m.original
    result.index_sorted = m.index_sorted
    

proc column_sorted*[T: int|float](m: MatrixViewSorted[T], j: Natural): ColMatrixViewSorted[T] =
    result = new(ColMatrixViewSorted[T])
    result.col_index = j
    result.row_index = true_index_sorted(m.index_sorted, m.row_index.toHashSet, j)
    result.original = m.original

proc index_of*[T: int|float](m: ColMatrixViewSorted[T], i: Natural): Natural =
    ## Return the index of the nth element ordered
    m.row_index[i]

proc len*[T: int|float](c: ColMatrixViewSorted[T]): Natural =
    c.row_index.len

proc M*[T: int|float](m: MatrixViewSorted[T]): Natural =
    m.row_index.len
    
proc N*[T: int|float](m: MatrixViewSorted[T]): Natural =
    m.col_index.len
      
proc shape*[T: int|float](m: MatrixViewSorted[T]): array[2, int] =
    m.index_sorted.shape

    
proc `[]`*[T: int|float](m: ColMatrixViewSorted[T], i: Natural): T =
    return m.original[m.row_index[i], m.col_index]

iterator items*[T: int|float](m: MatrixViewSorted, slice: HSlice[Positive, Positive]): T =
    for i in slice:
        yield m[i]

iterator items*[T: int|float](m: ColMatrixViewSorted[T]): T =
    for i in m.row_index:
        yield m.original[i, m.col_index]
        

proc `$`*[T: int|float](m: ColMatrixViewSorted[T]): string =
    result = "@[ "
    for v in m:
        result = result & $v & " "
    result = result & "]"