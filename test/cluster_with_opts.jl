include("../src/CassandraDriver.jl")

d = Cass.Driver("") |> Cass.option(:protocol_version, 4) |>
        Cass.option(:connection_heartbeat_interval, 0)

m = Cass.option(:test_option, 12)(d)
println(m)
#Cass.@set_option(:test_option, 12)(c)
