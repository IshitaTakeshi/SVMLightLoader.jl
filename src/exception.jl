type InvalidFormatError <: Exception
    msg
    InvalidFormatError(msg = "") = new(msg)
end

type NoDataException <: Exception end
