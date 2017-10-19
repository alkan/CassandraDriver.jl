export Statement, reset_parameters, set_keyspace


mutable struct Statement
    qstr::String
    params::Vector{Any}
    keyspace::String
    consistency::Consistency
    ptr::Ptr{Void}
    function Statement(s::String)
        new(s, Vector{Any}(), "", CONSISTENCY_LOCAL_ONE)
    end
end

function reset_parameters(stmt::Statement)
    stmt.params = Vector{Any}()
end

function set_keyspace(stmt::Statement, keyspace)
    stmt.keyspace = keyspace
end

function set_consistency(stmt::Statement, c::Consistency)
    stmt.consistency = c
end

# Public bind methods
function bind()
    (stmt::Statement) -> (push!(stmt.params, nothing); stmt)
end

function _set_param(value)
    (stmt::Statement) -> (push!(stmt.params, value); stmt)
end

bind(value::Int8) = _set_param(value)
bind(value::Int16) = _set_param(value)
bind(value::Int32) = _set_param(value)
bind(value::UInt32) = _set_param(value)
bind(value::Int64) = _set_param(value)
bind(value::Float32) = _set_param(value)
bind(value::Float64) = _set_param(value)
bind(value::Bool) = _set_param(value)
bind(value::String) = _set_param(value)
bind(value::Array{UInt8}) = _set_param(value)
#bind(value::UUID) = _set_param(value)

function build(stmt::Statement)
    stmt.ptr = ccall((:cass_statement_new, libcass), Ptr{Void}, (Cstring, Cint),
                stmt.qstr, length(stmt.params))
    for (i, param) in enumerate(stmt.params)
        _bind(stmt.ptr, i-1, param)
    end
    stmt
end

function free(stmt::Statement)
    stmt isa Ptr && ccall((:cass_statement_free, libcass), Void, (Ptr{Void},), stmt)
    empty!(stmt.params)
end

# Internal bind mappings
function _bind(stmt::Ptr{Void}, idx::Int, nothing)
    ccall((:cass_statement_bind_null, libcass), Cint, (Ptr{Void}, Cint), stmt, idx)
end
function _bind(stmt::Ptr{Void}, idx::Int, val::Int8)
    ccall((:cass_statement_bind_int8, libcass), Cint, (Ptr{Void}, Cint, Int8), stmt, idx, val)
end
function _bind(stmt::Ptr{Void}, idx::Int, val::Int16)
    ccall((:cass_statement_bind_int16, libcass), Cint, (Ptr{Void}, Cint, Int16), stmt, idx, val)
end
function _bind(stmt::Ptr{Void}, idx::Int, val::Int32)
    ccall((:cass_statement_bind_int32, libcass), Cint, (Ptr{Void}, Cint, Int32), stmt, idx, val)
end
function _bind(stmt::Ptr{Void}, idx::Int, val::UInt32)
    ccall((:cass_statement_bind_uint32, libcass), Cint, (Ptr{Void}, Cint, UInt32), stmt, idx, val)
end
function _bind(stmt::Ptr{Void}, idx::Int, val::Int64)
    ccall((:cass_statement_bind_int64, libcass), Cint, (Ptr{Void}, Cint, Int64), stmt, idx, val)
end
function _bind(stmt::Ptr{Void}, idx::Int, val::Float32)
    ccall((:cass_statement_bind_float, libcass), Cint, (Ptr{Void}, Cint, Float32), stmt, idx, val)
end
function _bind(stmt::Ptr{Void}, idx::Int, val::Float64)
    ccall((:cass_statement_bind_double, libcass), Cint, (Ptr{Void}, Cint, Float64), stmt, idx, val)
end
function _bind(stmt::Ptr{Void}, idx::Int, val::Bool)
    ccall((:cass_statement_bind_bool, libcass), Cint, (Ptr{Void}, Cint, Cint), stmt, idx, Cint(val))
end
function _bind(stmt::Ptr{Void}, idx::Int, val::String)
    ccall((:cass_statement_bind_string, libcass), Cint, (Ptr{Void}, Cint, Cstring), stmt, idx, val)
end

_set_request_timeout(s::Statement, ms::Integer) = (
    ccall((:cass_statement_set_request_timeout, libcass), Cint,
            (Ptr{Void}, Cuint), s.ptr, ms);
    s)
