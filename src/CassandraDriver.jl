module Cass
const libcass = "libcassandra"
Libdl.dlopen(libcass)

const OK = Cint(0)

export OK, Driver, connect, free

type Driver
    cluster::Ptr{Void}
    session::Ptr{Void}
    connection::Ptr{Void}
    function Driver(contact_points::String)
        cluster = ccall((:cass_cluster_new, libcass), Ptr{Void},  (), )
        session = ccall((:cass_session_new, libcass), Ptr{Void},  (), )
        ccall( (:cass_cluster_set_contact_points, libcass), Void, (Ptr{Void}, Cstring),
                cluster, contact_points)
        new(cluster, session)
    end
end

mutable struct Statement
    qstr::String
    par::Vector{Any}
end

include("utils.jl")


function connect(drv::Driver)
    connect_future = ccall((:cass_session_connect, libcass), Ptr{Void},
            (Ptr{Void}, Ptr{Void}), drv.session, drv.cluster)

    rc = ccall((:cass_future_error_code, libcass), Int, (Ptr{Void},), connect_future)
    if rc == 0
        drv.connection = connect_future
    else
        error(error_desc(rc))
    end
    rc
end

function free(drv::Driver)
    ccall((:cass_future_free, libcass), Void, (Ptr{Void},), drv.connection)
    ccall((:cass_session_free, libcass), Void, (Ptr{Void},), drv.session)
    ccall((:cass_cluster_free, libcass), Void, (Ptr{Void},), drv.cluster)
end

end  # module Cass


module CassandraDriver

using Cass

end  # module CassandraDriver
