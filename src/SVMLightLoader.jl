# Loader of svmlight / liblinear format files

# Copyright (c) 2015 Ishita Takeshi
# License is MIT

module SVMLightLoader

export
    SVMLightFile,
    load_svmlight_file,
    InvalidFormatError,
    NoDataException

include("exception.jl")
include("loader.jl")
include("iterable.jl")

end # module
