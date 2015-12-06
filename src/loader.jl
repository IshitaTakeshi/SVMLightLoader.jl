# Copyright (c) 2015 Ishita Takeshi
# License is MIT


# replace multiple whitespaces with single whitespace
strip_line(line) = replace(strip(line), r"\s+", " ")

parsefloat(x) = parse(Float64, x)
parseint(x) = parse(Int64, x)

isnumeric(s::AbstractString) = ismatch(r"[0-9]", s)
iscomment(line) = startswith(line, "#")


"""
Extract a sparse vector of `ndim` dimensions and its label
from the given string line.
If `ndim` is not passed, the vector dimension is automatically determined by
the contents of the given string line.
"""
function line_to_data(line)
    line = strip_line(line)
    splitted = split(line, " ")

    if iscomment(line) || length(line) == 0
        #the line contains only a comment, newline or whitespaces
        throw(NoDataException())
    end

    label = 0  # define label once here
    try
        label = parsefloat(splitted[1])
    catch error
        throw(InvalidFormatError(error.msg))
    end

    if length(splitted) < 2 || startswith(splitted[2], "#")
        # no vector per line or the case such as line = "-1 #comment"
        return (Int64[], Float64[]), label
    end

    indices = Int64[]
    values = Float64[]
    for element in splitted[2:end]
        if startswith(element, "#")
            # regard the remaining characters as a comment
            break
        end

        pair = split(element, ":")

        try
            index = parseint(pair[1])
            value = parsefloat(pair[2])
            push!(indices, index)
            push!(values, value)
        catch error
            throw(InvalidFormatError(error.msg))
        end
    end

    return ((indices, values), label)
end


function load_svmlight_file(filename, ndim = -1)
    I = Int64[]
    J = Int64[]
    V = Float64[]
    y = Array(Float64, 0)

    i = 1
    for line in eachline(open(filename))
        try
            ((indices, values), label) = line_to_data(line)
            append!(I, indices)
            append!(J, ones(length(indices))*i)
            append!(V, values)

            y = push!(y, label)

            i += 1
        catch error
            if isa(error, NoDataException)
                # do nothing
                continue
            end
            throw(error)
        end
    end

    if ndim < 0
        X = sparse(I, J, V)
    else
        X = sparse(I, J, V, ndim, i-1)
    end
    return X, y
end
