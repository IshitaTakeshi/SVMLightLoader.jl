# Loader of svmlight / liblinear format files

# Copyright (c) 2015 Ishita Takeshi
# License is MIT


module SVMLightLoader

export SVMLightFile, load_svmlight_file, InvalidFormatError, NoDataException


include("loader.jl")


type SVMLightFile
    file::IOStream
    ndim::Int64
    data

    function SVMLightFile(filename, ndim=-1)
        return new(open(filename), ndim, ())
    end
end

#status is not used. anything is ok to be set
Base.start(::SVMLightFile) = "#"


Base.next(s::SVMLightFile, status) = (s.data, status)


function Base.done(s::SVMLightFile, status)
    while !eof(s.file)
        line = readline(s.file)
        try
            ((indices, values), label) = line_to_data(line)

            if s.ndim < 0
                vector = sparsevec(indices, values)
            else
                vector = sparsevec(indices, values, s.ndim, Base.AddFun())
            end

            s.data = (vector, label)

            return false
        catch error
            if isa(error, NoDataException)
                # do nothing
                continue
            end
            throw(error)
        end
    end
    return true
end


Base.eltype(::Type{SVMLightFile}) = String


# NOTE since parsing the whole file, this function is slow
function Base.length(s::SVMLightFile)
    length = 0
    for data in s
        length += 1
    end
    return length
end

end # module
