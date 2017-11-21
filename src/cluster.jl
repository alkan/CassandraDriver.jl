struct Cluster
    ptr::Ptr{Void}
    function Cluster()
        new( ccall((:cass_cluster_new, libcass), Ptr{Void},  (), ) )
    end

    function Cluster(contact_points::String, port::Int)
        cluster = Cluster()
        _set_contact_points(cluster, contact_points)
        _set_port(cluster, port)
        cluster
    end
end

export Cluster, free
_set_contact_points(c::Cluster, contact_points::AbstractString) = ccall(
        (:cass_cluster_set_contact_points, libcass), Void, (Ptr{Void}, Cstring),
                c.ptr, contact_points)

_set_port(c::Cluster, port::Int) = ccall(
        (:cass_cluster_set_port, libcass), Void, (Ptr{Void}, Cint), c.ptr, port)

free(c::Cluster) = ccall((:cass_cluster_free, libcass), Void, (Ptr{Void},), c.ptr)
