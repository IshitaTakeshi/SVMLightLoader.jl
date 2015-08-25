# Copyright (c) 2015 Ishita Takeshi
# License is MIT

#replace multiple whitespaces with single whitespace
strip_line(line) = replace(strip(line), r"\s+", " ")

parsefloat(x) = parse(Float64, x)
parseint(x) = parse(Int64, x)


type InvalidFormatError <: Exception
    msg
    InvalidFormatError(msg="") = new(msg)
end

type NoDataException <: Exception end


isnumeric(s::String) = ismatch(r"[0-9]", s)
iscomment(line) = startswith(line, "#")


"""
Extract a sparse vector of `ndim` dimensions and its label
from the given string line.
If `ndim` is not passed, the vector dimension is automatically determined by
the contents of the given string line.
"""
function line_to_data(line, ndim=-1; ElementType=Float64, LabelType=Int64)
    convert_element(x) = convert(ElementType, x)
    convert_label(x) = convert(LabelType, x)

    line = strip_line(line)
    splitted = split(line, " ")

    if iscomment(line) || length(line) == 0
        #the line contains only a comment, newline or whitespaces
        throw(NoDataException())
    end

    try
        label = parsefloat(splitted[1])
    catch error
        throw(InvalidFormatError(error.msg))
    end

    if length(splitted) < 2 || startswith(splitted[2], "#")
        # no vector per line or the case such as line = "-1 #comment"
        if ndim > 0
            vector = spzeros(ndim, 1)
        else
            vector = spzeros(0, 1)
        end
        return vector, label
    end

    dict = Dict{Int64, Float64}()
    for element in splitted[2:end]
        if startswith(element, "#")
            # regard the remaining characters as a comment
            break
        end

        pair = split(element, ":")

        try
            index, value = parseint(pair[1]), parsefloat(pair[2])
            dict[index] = value
        catch error
            throw(InvalidFormatError(error.msg))
        end
    end

    if ndim > 0
        try
            vector = sparsevec(dict, ndim)
        catch error
            msg = "ndim is smaller than length(sparsevec)"
            throw(ArgumentError(msg))
        end
    else
        vector = sparsevec(dict)
    end

    vector = map(convert_element, vector)
    label = convert_label(label)

    return vector, label
end



function load_svmlight_file(filename, ndim=-1;
                            ElementType=Float64, LabelType=Int64)
    I = Int64[]
    J = Int64[]
    V = Int64[]
    y = Array(LabelType, 0)

    i = 1
    for line in eachline(open(filename))
        try
            vector, label = line_to_data(line, ndim,
                                         ElementType=ElementType,
                                         LabelType=LabelType)
            row, col, val = findnz(vector)
            I = vcat(I, row)
            J = vcat(J, col*i)
            V = vcat(V, val)

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
        X = sparse(I, J, V, ndim, i-1, Base.AddFun())
    end
    return X, y
end
