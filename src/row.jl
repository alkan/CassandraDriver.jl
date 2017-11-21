struct Row <: Iterable
    values::DataArray{Any}
    fields::Fields
end

function Row(ptr::Ptr{Void}, fields::Fields)
    vals = DataArray(Array{Any}(length(fields)))
    for (i, field) in enumerate(fields)
        col = get_column(ptr, i - 1)
        isnull = ccall((:cass_value_is_null, libcass), Cint, (Ptr{Void},), col) == 1
        vals[i] = isnull ? NA : get_value(field[2], col)
    end
    Row(vals, fields)
end

export Row

get_column(ptr::Ptr{Void}, idx::Int) = ccall((:cass_row_get_column, libcass),
            Ptr{Void}, (Ptr{Void}, Cint), ptr, idx)
