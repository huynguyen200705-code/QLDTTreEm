using Microsoft.AspNetCore.Mvc;

namespace _0859_NguyenQuocHuy_WebAPI.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] WeatherSummaries =
    [
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    ];

    [HttpGet(Name = "GetWeatherForecast")]
    public ActionResult<IEnumerable<WeatherForecast>> GetForecast()
    {
        var forecastData = Enumerable.Range(1, 5).Select(offset => new WeatherForecast
        {
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(offset)),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = WeatherSummaries[Random.Shared.Next(WeatherSummaries.Length)]
        });

        return Ok(forecastData);
    }
}

