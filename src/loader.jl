# Copyright (c) 2015 Ishita Takeshi
# License is MIT


strip_line(line) = replace(strip(line), r"\s+", " ")
split_line(line) = split(line, " ")

parsefloat(x) = parse(Float64, x)
parseint(x) = parse(Int64, x)


function isnumeric(s::String)
    ismatch(r"[0-9]", s)
end


function isdata(line::String)
    line = strip_line(line)
    splitted = split_line(line)
    if length(splitted) < 2
        return false
    end

    return isnumeric(splitted[1])
end


function line_to_sparse_vector(line, ElementType, LabelType)
    assert(isdata(line))

    convert_element(x) = convert(ElementType, x)
    convert_label(x) = convert(LabelType, x)

    line = strip_line(line)
    splitted = split_line(line)

    label = parsefloat(splitted[1])

    dict = Dict{Int64, Float64}()
    for element in splitted[2:end]
        # regard the remaining characters as a comment
        if element == "#"
            break
        end

        pair = split(element, ":")

        index, value = parseint(pair[1]), parsefloat(pair[2])
        dict[index] = value
    end

    vector = sparsevec(dict)

    vector = map(convert_element, vector)
    label = convert_label(label)

    return vector, label
end



function load_svmlight_file(filename; ElementType=Float64, LabelType=Int64)
    X = Array(SparseMatrixCSC, 0)
    y = Array(LabelType, 0)

    open(filename) do file
        for line in eachline(file)
            if !isdata(line)
                continue
            end

            vector, label = line_to_sparse_vector(line, ElementType, LabelType)
            push!(X, vector)
            push!(y, label)
        end
    end

    return X, y
end
