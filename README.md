SVMLightLoader
==============

## The Loader of svmlight / liblinear format files

### Usage


```
using SVMLightLoader

# load the whole file
vectors, labels = load_svmlight_file("test.txt")

# iterate the file line by line
for (vector, label) in SVMLightFile("test.txt")
    dosomething(vector, label)
end

# The type of the vector and its label can be specified by the arguments
# The next line shows that the element of the vector is Float64 and
# the label of the vector is Int64
for (vector, label) in SVMLightFile("test.txt", Float64, Int64)
    dosomething(vector, label)
end
```
