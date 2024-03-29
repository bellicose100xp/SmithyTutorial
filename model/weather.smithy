// Weather is a Service shape that is defined inside of a namespace
$version: "2"
namespace example.weather

use aws.protocols#restJson1

/// Provides weather forecasts.
/// Triple slash comments attach documentation to shapes
@paginated(inputToken: "nextToken", outputToken: "nextToken", pageSize: "pageSize")
@restJson1
service Weather {
    version: "2006-03-01"
    resources: [City]
    operations: [GetCurrentTime]
}

resource City {
    identifiers: { cityId: CityId } // url param
    read: GetCity  // url param is needed for reading a specific city
    list: ListCities  // url param is not needed for listing all cities
    resources: [Forecast] // is it nested resource
}

// Since each city has one forcast, we don't need forecast specific identifier
resource Forecast {
    identifiers: { cityId: CityId }  // nested identifiers must at least have identifiers of their parent
    read: GetForecast
}

// "pattern" is a trait
@pattern("^[A-Za-z0-9 ]+$")
string CityId


@readonly
@http(code: 200, method: "GET", uri: "/cities/{cityId}")
operation GetCity {
    input: GetCityInput
    output: GetCityOutput
    errors: [NoSuchResource]
}

@input
structure GetCityInput {
    // "cityId" provides the identifier for the resource and
    // has to be marked as required.
    @required
    @httpLabel
    cityId: CityId  // user needs to pass this as url param
}

@output
structure GetCityOutput {
    @required
    name: String

    @required
    coordinates: CityCoordinates
}

structure CityCoordinates {
    @required
    latitude: Float

    @required
    longitude: Float
}

@error("client")
structure NoSuchResource {
    @required
    resourceType: String
}

@paginated(items: "items")
@readonly
@http(code: 200, method: "GET", uri: "/cities")
operation ListCities {
    input: ListCitiesInput
    output: ListCitiesOutput
}

@input
structure ListCitiesInput {
    @httpQuery("nextToken")
    nextToken: String
    @httpQuery("pageSize")
    pageSize: Integer
}

@output
structure ListCitiesOutput {
    nextToken: String

    @required
    items: CitySummaries

}

list CitySummaries {
    member: CitySummary
}

@references([{resource: City}])
structure CitySummary {
    @required
    cityId: CityId

    @required
    name: String
}

@readonly
@http(code: 200, method: "GET", uri: "/forecast/{cityId}")
operation GetForecast {
    input: GetForecastInput
    output: GetForecastOutput
}

@input
structure GetForecastInput {
    @required
    @httpLabel  // refers to path parameter
    cityId: CityId
}

@output
structure GetForecastOutput {
    chanceOfRain: Float
}

@readonly
@http(code: 200, method: "GET", uri: "/currentTime")
operation GetCurrentTime {
    input: GetCurrentTimeInput
    output: GetCurrentTimeOutput
}

@input
structure GetCurrentTimeInput {}

@output
structure GetCurrentTimeOutput {
    @required
    time: Timestamp
}



