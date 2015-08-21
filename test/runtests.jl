using SVMLightLoader

import Base.Test: @test


@test !SVMLightLoader.isdata("# comment")
@test !SVMLightLoader.isdata("\n")
@test !SVMLightLoader.isdata("3.0")
@test SVMLightLoader.isdata("3.0 20:27")
@test SVMLightLoader.isdata("2.0 5:1.0 12:-3")

@test SVMLightLoader.isnumeric("4.0")
@test SVMLightLoader.isnumeric("0")
@test SVMLightLoader.isnumeric(".3")
@test !SVMLightLoader.isnumeric("#")
@test !SVMLightLoader.isnumeric("A")


line_to_sparse_vector = SVMLightLoader.line_to_sparse_vector

vector, label = line_to_sparse_vector("-1 2:1.0 5:3.0", Float64, Int64)
@test vector == sparsevec(Dict{Int64, Float64}(2 => 1.0, 5 => 3.0))
@test label == -1  # label should be Int64

vector, label = line_to_sparse_vector("2 2:1 5:3", Float64, Float64)
@test vector == sparsevec(Dict{Int64, Float64}(2 => 1.0, 5 => 3.0))
@test label == 2.0  # label should be Float64


function test_iterable(filename, X, y)
    assert(length(X) == length(y))

    i = 1
    for data in SVMLightFile(filename, Float64, Float64)
        vector, label = data
        @test vector == X[i]
        @test label == y[i]
        i += 1
    end
end


X = (sparsevec([2, 10, 15], [2.5, -5.2, 1.5]),
     sparsevec([5, 12], [1.0, -3]),
     sparsevec([20], [27]))
y = (1.0, 2.0, 3.0)

test_iterable("test.txt", X, y)
