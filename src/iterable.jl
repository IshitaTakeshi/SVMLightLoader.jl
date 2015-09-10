# Loader of svmlight / liblinear format files

# Copyright (c) 2015 Ishita Takeshi
# License is MIT


include("exception.jl")
include("loader.jl")


# closure for generating sparsevector
function get_sparsevector(ndim)
    if ndim < 0
        sparsevector(indices, values) = sparsevec(indices, values)
    else
        sparsevector(indices, values) = sparsevec(indices, values, ndim)
    end
    return sparsevector
end


#TODO make this immutable
type SVMLightFile
    file::IOStream

    function SVMLightFile(filename, ndim=-1)
        global sparsevector
        sparsevector = get_sparsevector(ndim)
        return new(open(filename))
    end
end


# read line from file stream until valid data obtained
# return nothing if reach eos
function read_next_data(file)
    while !eof(file)
        line = readline(file)
        try
            ((indices, values), label) = line_to_data(line)
            vector = sparsevector(indices, values)
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
    read_next_data(s.file)
end


function Base.done(s::SVMLightFile, data)
    data === nothing
end


function Base.next(s::SVMLightFile, currentdata)
    nextdata = read_next_data(s.file)
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
