module Cass
const libcass = "libcassandra"
Libdl.dlopen(libcass)

import Base.Random.UUID
import DataFrames: DataFrame
import DataArrays: DataArray

const OK = Cint(0)
include("constants.jl")
const Fields = Array{Tuple{String, ValueType}}
abstract type Iterable end

include("utils.jl")
include("cluster.jl")
include("result.jl")
include("value.jl")
include("row.jl")
include("iterator.jl")
include("collect.jl")
include("future.jl")
include("session.jl")
include("statement.jl")


export OK, Driver, connect, free, execute

struct Driver
    cluster::Cluster
    session::Session
    function Driver(contact_points::String)
        cluster = Cluster(contact_points)
        session = Session()
        new(cluster, session)
    end
end

include("cluster_options.jl")

function connect(drv::Driver)
    connect_future = connect(drv.session, drv.cluster)
    wait(connect_future)

    rc = error_code(connect_future)
    if rc != OK
        error(error_desc(rc))
    end
    free(connect_future)
    rc
end

function free(drv::Driver)
    free(drv.session)
    free(drv.cluster)
end

function execute(d::Driver, s::Statement)
    future = ccall((:cass_session_execute, libcass), Ptr{Void},
            (Ptr{Void}, Ptr{Void}), d.session.ptr, s.ptr)
    free(s)
    Future_C(future)
end

function execute(d::Driver, query::String, opt::Tuple{Symbol, Any}...)
    stmt = Statement(query) |> build
    for pair in opt
        option(pair...)(stmt)
    end
    execute(d, stmt)
end

end  # module Cass


module CassandraDriver

using Cass

end  # module CassandraDriver
