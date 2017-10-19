function option(opt, params...)
    fn_str = "_set_" * string(opt)
    fn = Symbol(fn_str)
    return (d::Union{Driver,Statement}) ->  @eval $(fn)($d, $params...)
end

_set_protocol_version(d::Driver, version::Signed) = (
    ccall((:cass_cluster_set_protocol_version, libcass), Cint,
            (Ptr{Void}, Cint), d.cluster.ptr, version);
    d)

_set_connect_timeout(d::Driver, ms::Cuint) = (
    ccall((:cass_cluster_set_connect_timeout, libcass), Void,
            (Ptr{Void}, Cuint), d.cluster.ptr, ms);
    d)

_set_request_timeout(d::Driver, ms::Unsigned) = (
    ccall((:cass_cluster_set_request_timeout, libcass), Void,
            (Ptr{Void}, Cuint), d.cluster.ptr, ms);
    d)

_set_resolve_timeout(d::Driver, ms::Cuint) = (
    ccall((:cass_cluster_set_resolve_timeout, libcass), Void,
            (Ptr{Void}, Cuint), d.cluster.ptr, ms);
    d)

_set_test_option(d::Driver, x::Signed) = 2x
