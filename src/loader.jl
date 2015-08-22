# Copyright (c) 2015 Ishita Takeshi
# License is MIT

#replace multiple whitespaces with single whitespace
strip_line(line) = replace(strip(line), r"\s+", " ")

parsefloat(x) = parse(Float64, x)
parseint(x) = parse(Int64, x)


type InvalidFormatError <: Exception end
type NoDataException <: Exception end


isnumeric(s::String) = ismatch(r"[0-9]", s)
iscomment(line) = startswith(line, "#")


function line_to_data(line; ElementType=Float64, LabelType=Int64)
    convert_element(x) = convert(ElementType, x)
    convert_label(x) = convert(LabelType, x)

    line = strip_line(line)
    splitted = split(line, " ")

    if iscomment(line) || length(line) == 0
        throw(NoDataException())
    end

    if length(splitted) < 2
        # no vector per line
        throw(InvalidFormatError())
    end

    if startswith(splitted[2], "#")
        #case such as line = "-1 #comment"
        throw(InvalidFormatError())
    end

    label = parsefloat(splitted[1])

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
        catch
            throw(InvalidFormatError())
        end
    end

    vector = sparsevec(dict)

    vector = map(convert_element, vector)
    label = convert_label(label)

    return vector, label
end



function load_svmlight_file(filename; ElementType=Float64, LabelType=Int64)
    X = Array(SparseMatrixCSC, 0)
    y = Array(LabelType, 0)

    for line in eachline(open(filename))
        try
            vector, label = line_to_data(line, ElementType, LabelType)
            push!(X, vector)
            push!(y, label)
        catch
        end
    end

    return X, y
end
