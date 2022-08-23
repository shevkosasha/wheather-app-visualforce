public class WeatherController {
    private final static String HTTP_GET = 'GET';
    @TestVisible private final static String CURRENT_WEATHER = 'weather';    
    @TestVisible private final static String FORECAST = 'forecast';
    @TestVisible private final static String CURRENT_WEATHER_LABEL = 'Current weather';
    @TestVisible private final static String FORECAST_LABEL = 'Forecast 5 days';
    @TestVisible private final static String MDT_INSTANCE = 'OpenWeather'; 
    @TestVisible private WeatherItem[] weatherItems = new List<WeatherItem>();  
    public String city{get;set;} 
    public String requestMode {get;set;}
    public Location location {get; set;}     

    public WeatherController() {}

    public PageReference showMeWeather(){
        getWeatherInfo(doRequest(requestMode));
        return null;
    }   

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(CURRENT_WEATHER, CURRENT_WEATHER_LABEL)); 
        options.add(new SelectOption(FORECAST, FORECAST_LABEL)); 
        return options; 
    }

    public WeatherItem[] getWeatherItems() {
        return weatherItems;
    }

    @TestVisible
    private HttpResponse doRequest(String requestMode){        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setMethod(HTTP_GET);
        request.setEndpoint(constructEndpoint());
        response = http.send(request);
        return response;
    }

    @TestVisible
    private String constructEndpoint(){
        String endpoint = OpenWeatherSetting__mdt.getInstance(MDT_INSTANCE).URL__c;
        endpoint += requestMode + '?q=' +city + '&units=metric&appid=';
        endpoint += OpenWeatherSetting__mdt.getInstance(MDT_INSTANCE).Api_key__c;
        return endpoint;
    }

    @TestVisible
    private void getWeatherInfo(HttpResponse response){
        if (response.getStatusCode() == 200) {
            weatherItems.clear();
            if (requestMode.equals(CURRENT_WEATHER)) {
                WeatherWrapper weatherObj = WeatherWrapper.parse(response.getBody()); 
                location = new Location(weatherObj.name,weatherObj.sys.country);
                weatherItems.add(new WeatherItem(weatherObj));
            } else if (requestMode.equals(FORECAST)) {  
                ForecastWrapper forecastObj = ForecastWrapper.parse(response.getBody()); 
                WeatherItem forecastList = new WeatherItem(forecastObj.forecastList);
                location = new Location(forecastObj.city.name,forecastObj.city.country);
                for (Integer i = 0; i < forecastObj.forecastList.size(); i = i + 8 ) { 
                    weatherItems.add(new WeatherItem(forecastObj.forecastList[i]));
                }            
            }
        } else {
            location = null;
            weatherItems.clear();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in reading data: ' + response.getStatus()));
        }
    }
    
    @TestVisible
    private class Location{        
        public String city {get;set;}
        public String country {get;set;}
        public Location (String city, String country) {
            this.city = city;
            this.country = country;
        }
    }

    @TestVisible
    private class WeatherItem{
        private String IMG_URL = OpenWeatherSetting__mdt.getInstance(MDT_INSTANCE).IMG_URL__c;
        public String temp {get;set;}
        public String imgSrc {get;set;}
        public String feelsLike {get;set;}
        public String description {get;set;}
        public String humidity {get;set;} 
        public String wind {get;set;}
        public String day {get; set;}
        public String formattedDate {get; set;}

        public WeatherItem (Object obj){
            processData(obj);
        }

        private void processData(Object obj){
            WeatherWrapper weatherObj;
            ForecastWrapper.ForecastList forecastListItem;
            if (obj instanceof WeatherWrapper){
                weatherObj = (WeatherWrapper) obj;
                day = CURRENT_WEATHER_LABEL;
                temp = String.valueOf(weatherObj.main.temp);
                feelsLike = String.valueOf(weatherObj.main.feels_like);
                description = String.valueOf(weatherObj.weather[0].description);
                humidity = String.valueOf(weatherObj.main.humidity);
                wind = String.valueOf(weatherObj.wind.speed);
                imgSrc = IMG_URL + String.valueOf(weatherObj.weather[0].icon) + '.png';
            } else if (obj instanceof ForecastWrapper.ForecastList) {
                forecastListItem = (ForecastWrapper.ForecastList) obj;
                Datetime dt = Datetime.valueOf(forecastListItem.dt_txt); 
                formattedDate = String.valueOf(dt.date()) + ' at ' + String.valueOf(dt.format('h a'));
                day = String.valueOf(dt.format('EEEE'));
                temp = String.valueOf(forecastListItem.main.temp);
                feelsLike = String.valueOf(forecastListItem.main.feels_like);
                description = String.valueOf(forecastListItem.weather[0].description);
                humidity = String.valueOf(forecastListItem.main.humidity);
                wind = String.valueOf(forecastListItem.wind.speed);
                imgSrc = IMG_URL + String.valueOf(forecastListItem.weather[0].icon) + '.png';
            }            
        }
    }
}
