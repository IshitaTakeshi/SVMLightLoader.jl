import Base.Test: @test

using SVMLightLoader


println("Testing isnumeric")

@test SVMLightLoader.isnumeric("4.0")
@test SVMLightLoader.isnumeric("0")
@test SVMLightLoader.isnumeric(".3")
@test !SVMLightLoader.isnumeric("#")
@test !SVMLightLoader.isnumeric("A")


println("Testing line_to_data")

line_to_data = SVMLightLoader.line_to_data

# when the format is invalid
try line_to_data(" #comment") catch err @test isa(err, NoDataException) end
try line_to_data("# comment") catch err @test isa(err, NoDataException) end
try line_to_data("\n") catch err @test isa(err, NoDataException) end
try line_to_data("-1 2:1.0 5:") catch err @test isa(err, InvalidFormatError) end
try line_to_data("-1 :3") catch err @test isa(err, InvalidFormatError) end
try line_to_data("A") catch err @test isa(err, InvalidFormatError) end

(indices, values), label = line_to_data("-1")
@test (indices, values) == (Int64[], Float64[])
@test label == -1

(indices, values), label = line_to_data("-1 #comment")
@test (indices, values) == (Int64[], Float64[])
@test label == -1

# when the format is correct
(indices, values), label = line_to_data("-1 2:1.0 5:3.0 #comment")
@test (indices, values) == ([2, 5], [1.0, 3.0])
@test label == -1

(indices, values), label = line_to_data("2 2:1 5:3 #comment")
@test (indices, values) == ([2, 5], [1.0, 3.0])
@test label == 2

I = [2, 10, 15, 5, 12, 20]
J = [1, 1, 1, 2, 2, 3]
V = [2.5, -5.2, 1.5, 1.0, -3.0, 27.0]
X = sparse(I, J, V)

y = [1.0, 2.0, 3.0]

ndim = 30
Xndim = sparse(I, J, V, ndim, maximum(J))


println("Testing load_svmlight_file")

vectors, labels = load_svmlight_file("test.txt")
@test vectors == X
@test labels == y

vectors, labels = load_svmlight_file("test.txt", ndim)
@test vectors == Xndim
@test labels == y

error_thrown = false
try
    load_svmlight_file("invalid.txt")
catch error
    error_thrown = true
    @test isa(error, InvalidFormatError)
end
@test error_thrown


println("Testing iteration of SVMLightFile")

i = 0
for (vector, label) in SVMLightFile("test.txt")
    i += 1
    @test findnz(vector) == findnz(X[:, i])
    @test label == y[i]
end
@test i == size(X, 2)

i = 0
for (vector, label) in SVMLightFile("test.txt", ndim)
    i += 1
    @test findnz(vector) == findnz(X[:, i])
    @test label == y[i]
end
@test i == size(X, 2)

# empty.txt contains only newlines and comments
i = 1
for (vector, label) in SVMLightFile("empty.txt")
    i += 1
end

@test i == 1  # nothing should be loaded

error_thrown = false
try
    for (vector, label) in SVMLightFile("invalid.txt") end
catch error
    error_thrown = true
    @test isa(error, InvalidFormatError)
end
@test error_thrown


println("Testing length(s::SVMLightFile)")

@test length(SVMLightFile("test.txt")) == size(X, 2)


println("Testing List Comprehensions")

list = [label for (vector, label) in SVMLightFile("empty.txt")]
@test list == []

list = [label for (vector, label) in SVMLightFile("test.txt")]
@test list == [1.0, 2.0, 3.0]
