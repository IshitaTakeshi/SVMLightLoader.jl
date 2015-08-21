# Loader of svmlight / liblinear format files

# Copyright (c) 2015 Ishita Takeshi
# License is MIT


module SVMLightLoader

export SVMLightFile, load_svmlight_file


include("loader.jl")


type SVMLightFile
    file::IOStream
    line::String
    ElementType
    LabelType

    function SVMLightFile(filename, ElementType = Float64, LabelType = Int64)
        return new(open(filename), "#", ElementType, LabelType)
    end
end


Base.start(::SVMLightFile) = "#"


function Base.next(s::SVMLightFile, status)
    vector, label = line_to_sparse_vector(s.line, s.ElementType, s.LabelType)
    s.line = readline(s.file)
    return ((vector, label), status)
end


function Base.done(s::SVMLightFile, status)
    while !isdata(s.line)
        if eof(s.file)
            close(s.file)
            return true
        end

        s.line = readline(s.file)
    end

    return false
end


Base.eltype(::Type{SVMLightFile}) = String


end # module
