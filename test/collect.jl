
@testset "collect result rows" begin
    driver = Cass.Driver(contact_points)
    rc = Cass.connect(driver)
    future = Cass.execute(driver, "SELECT  * FROM system.size_estimates")
    result = Cass.fetch(future)
    @test result.row_count > 0
    @test length(result.fields) > 0
    df = collect(result)
    println(df)
    Cass.free(result)
    Cass.free(future)
    Cass.free(driver)
end
