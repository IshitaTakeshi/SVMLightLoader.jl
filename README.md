SVMLightLoader
==============

## The Loader of svmlight / liblinear format files

### Usage


```
using SVMLightLoader


# load the whole file
vectors, labels = load_svmlight_file("test.txt")

# the vector dimension can be specified
ndim = 20
vectors, labels = load_svmlight_file("test.txt", ndim)
println(size(vectors[1]))  # (20,1)


# iterate the file line by line
for (vector, label) in SVMLightFile("test.txt")
    dosomething(vector, label)
end

# The type of the vector and its label can be specified by the arguments
# The next line shows that the element of the vector is Float64 and
# the label of the vector is Int64

SVMLightFile("test.txt", ndim, ElementType=Float64, LabelType=Int64)

iter = SVMLightFile("test.txt", ndim, ElementType=Float64, LabelType=Float64)
for (vector, label) in iter
    dosomething(vector, label)
end
```
