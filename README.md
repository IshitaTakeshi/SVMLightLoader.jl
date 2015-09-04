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
println(size(vectors, 1))  # 20

# iterate the file line by line
for (vector, label) in SVMLightFile("test.txt")
    dosomething(vector, label)
end

for (vector, label) in SVMLightFile("test.txt", ndim)
    dosomething(vector, label)
end
```
