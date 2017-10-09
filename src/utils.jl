struct Response
    code::Int
    message::AbstractString
end

function future_error_check(ptr::Ptr{Void})
    rc = ccall((:cass_future_error_code, libcass), UInt32, (Ptr{Void},), ptr)
    rc == OK && return Response(OK, "")

    ptr_val = Ref{Cstring}()
    len = Ref{Csize_t}(0)
    ccall((:cass_future_error_message, libcass), Void,
            (Ptr{Void}, Ptr{Cstring}, Ptr{Csize_t}), ptr, ptr_val, len)
    msg = dec(rc) * ": " * unsafe_string(pointer(ptr_val.x))
    Response(rc, msg)
end
