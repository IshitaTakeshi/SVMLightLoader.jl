# Loader of svmlight / liblinear format files

# Copyright (c) 2015 Ishita Takeshi
# License is MIT


module SVMLightLoader

export SVMLightFile, load_svmlight_file, line_to_data,
       InvalidFormatError, NoDataException


include("loader.jl")


type SVMLightFile
    file::IOStream
    data
    ElementType
    LabelType

    function SVMLightFile(filename, ElementType=Float64, LabelType=Int64)
        return new(open(filename), (), ElementType, LabelType)
    end
end

#status is not used. anything is ok to be set
Base.start(::SVMLightFile) = "#"


Base.next(s::SVMLightFile, status) = (s.data, status)


function Base.done(s::SVMLightFile, status)
    while !eof(s.file)
        line = readline(s.file)
        try
            s.data = line_to_data(line,
                                  ElementType=s.ElementType,
                                  LabelType=s.LabelType)
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
