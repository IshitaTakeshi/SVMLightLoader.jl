import SVMLightLoader: load_svmlight_file


url = "http://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/a1a"
filename = basename(url)

if !isfile(filename)
    import HTTPClient: get
    contents = get(url)
    f = open(filename, "w")
    write(f, contents.body.data)
    close(f)
end


# The code is from below:
# http://thirld.com/blog/2015/05/30/julia-profiling-cheat-sheet/
function benchmark(target, args...)
    # Any setup code goes here.

    # Run once, to force compilation.
    println("======================= First run:")
    @time target(args...)

    # Run a second time, with profiling.
    println("\n\n======================= Second run:")

    Profile.init()
    Profile.clear()
    Profile.clear_malloc_data()

    @profile @time target(args...)

    # Write profile results to profile.bin.
    f = open("trace.def", "w")
    Profile.print(f)
    close(f)
end


benchmark(load_svmlight_file, filename)
