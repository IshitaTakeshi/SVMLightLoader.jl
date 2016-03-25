# Loader of svmlight / liblinear format files

# Copyright (c) 2015 Ishita Takeshi
# License is MIT


immutable SVMLightFile{HASDIM}
    file::IOStream
    ndim::Int

    function SVMLightFile(filename, ndim::Int)
        @assert HASDIM == (ndim >= 0)
        return new(open(filename), ndim)
    end
end


function SVMLightFile(filename, ndim::Int = -1)
    SVMLightFile{ndim >= 0}(filename, ndim)
end


sparsevector(s::SVMLightFile{false}, indices, values) =
    sparsevec(indices, values)

sparsevector(s::SVMLightFile{true}, indices, values) =
    sparsevec(indices, values, s.ndim)


# read line from file stream until valid data obtained
# return nothing if reach eos
function read_next_data(s::SVMLightFile)
    file = s.file
    while !eof(file)
        line = readline(file)
        try
            ((indices, values), label) = line_to_data(line)
            vector = sparsevector(s, indices, values)
            return (vector, label)
        catch error
            if isa(error, NoDataException)
                # do nothing
                continue
            end
            throw(error)
        end
    end
    return nothing
end


# read one line
function Base.start(s::SVMLightFile)
    # Reread from the top of the file after counting valid lines
    # when List Comprehensions used
    seek(s.file, 0)
    read_next_data(s)
end


function Base.done(s::SVMLightFile, data)
    data === nothing
end


function Base.next(s::SVMLightFile, currentdata)
    nextdata = read_next_data(s)
    return (currentdata, nextdata)
end


#Base.eltype(::Type{SVMLightFile}) = String
#
#
# NOTE since parsing the whole file, this function would be slow
function Base.length(s::SVMLightFile)
    length = 0
    for data in s
        length += 1
    end
    return length
end
