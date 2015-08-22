using SVMLightLoader

import Base.Test: @test


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
try line_to_data("-1") catch err @test isa(err, InvalidFormatError) end
try line_to_data("-1 #comment") catch err @test isa(err, InvalidFormatError) end
try line_to_data("A") catch err @test isa(err, InvalidFormatError) end

# when the format is correct
vector, label = line_to_data("-1 2:1.0 5:3.0 #comment",
                             ElementType=Float64, LabelType=Int64)
@test vector == sparsevec(Dict{Int64, Float64}(2 => 1.0, 5 => 3.0))
@test label == -1  # label should be Int64

vector, label = line_to_data("2 2:1 5:3 #comment",
                             ElementType=Float64, LabelType=Int64)
@test vector == sparsevec(Dict{Int64, Float64}(2 => 1.0, 5 => 3.0))
@test label == 2.0  # label should be Float64


println("Testing iteration of SVMLightFile")

X = (sparsevec([2, 10, 15], [2.5, -5.2, 1.5]),
     sparsevec([5, 12], [1.0, -3.0]),
     sparsevec([20], [27.0]))
y = (1.0, 2.0, 3.0)

i = 0
for (vector, label) in SVMLightFile("test.txt", Float64, Float64)
    i += 1
    @test vector == X[i]
    @test label == y[i]
end
@test i == length(X)

# empty.txt contains only newlines and comments
i = 1
for (vector, label) in SVMLightFile("empty.txt", Float64, Float64)
    i += 1
end

@test i == 1  # nothing should be loaded


println("Testing length(s::SVMLightFile)")
@test length(SVMLightFile("test.txt", Float64, Float64)) == length(X)
