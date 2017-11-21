"""
# Driver / Cluster options

| Option | Default | Comments |
|:-------|---------|:---------|
| :protocol_version | 4 | |
| :connect_timeout | 5000 | ms |
| :request_timeout | 12000 | ms |
| :resolve_timeout | 2000 | ms |
| :connection_heartbeat_interval | 30 | seconds |

"""
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

_set_request_timeout(d::Driver, ms::Int) = (
    ccall((:cass_cluster_set_request_timeout, libcass), Void,
            (Ptr{Void}, Cuint), d.cluster.ptr, ms);
    d)

_set_resolve_timeout(d::Driver, ms::Int) = (
    ccall((:cass_cluster_set_resolve_timeout, libcass), Void,
            (Ptr{Void}, Cuint), d.cluster.ptr, ms);
    d)

_set_connection_heartbeat_interval(d::Driver, sec::Int) = (
    ccall((:cass_cluster_set_connection_heartbeat_interval, libcass), Void,
            (Ptr{Void}, Cuint), d.cluster.ptr, sec);
    d)

_set_test_option(d::Driver, x::Signed) = 2x
