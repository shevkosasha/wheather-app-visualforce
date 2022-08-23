@IsTest
public class WeatherControllerTest {

    private final static String TEST_CITY = 'London';
    private final static String TEST_COUNTRY = 'GB';
    private final static String GET_WEATHER_TEST_RESOURCE = 'getWeatherTest';
    private final static String GET_FORECAST_TEST_RESOURCE = 'getForecastTest';
    private final static String PAGE_URL = 'https://routine5-dev-ed.my.salesforce.com/apex/WeatherInfo';

    @IsTest
    public static void testLocationClass() {
        WeatherController controller = getWeatherController(WeatherController.CURRENT_WEATHER);
        controller.location = new WeatherController.Location(controller.city, TEST_COUNTRY);
        System.assert(controller.location.city.equals(TEST_CITY));
        System.assert(controller.location.country.equals(TEST_COUNTRY));
    }

    @IsTest
    static void testGetItems(){
        List<SelectOption> options =  new WeatherController().getItems();
        System.assert(options.size() == 2);
        for (SelectOption option : options) {
            System.assert(option.getValue() == WeatherController.CURRENT_WEATHER || option.getValue() == WeatherController.FORECAST);
            System.assert(option.getLabel() == WeatherController.CURRENT_WEATHER_LABEL || option.getLabel() == WeatherController.FORECAST_LABEL);
        }
    }

    @IsTest
    static void testGetWhere(){
        WeatherController controller = getWeatherController(WeatherController.CURRENT_WEATHER);
        String actual = controller.constructEndpoint();
        String expected = OpenWeatherSetting__mdt.getInstance(WeatherController.MDT_INSTANCE).URL__c;
        expected += controller.requestMode + '?q=' + controller.city + '&units=metric&appid=';
        expected += OpenWeatherSetting__mdt.getInstance(WeatherController.MDT_INSTANCE).Api_key__c;
        System.assert(actual.equals(expected));
    }

    @isTest 
    static void testDoRequest() {
        WeatherController controller = getWeatherController(WeatherController.CURRENT_WEATHER);
        StaticResourceCalloutMock mock = getTestMock(GET_WEATHER_TEST_RESOURCE, 200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res = controller.doRequest(controller.requestMode);
        System.assert(res.getBody().contains(TEST_CITY));
        System.assert(res.getBody().contains(TEST_COUNTRY));
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', res.getHeader('Content-Type'));   
    }

    @IsTest
    static void testGetWeatherInfo(){
        WeatherController controller = getWeatherController(WeatherController.CURRENT_WEATHER);
        System.assert(controller.getWeatherItems().isEmpty());
        StaticResourceCalloutMock mock = getTestMock(GET_WEATHER_TEST_RESOURCE, 200);
        Test.setMock(HttpCalloutMock.class, mock);
        controller.getWeatherInfo(controller.doRequest(controller.requestMode));
        System.assert(!controller.getWeatherItems().isEmpty());
        System.assert(controller.getWeatherItems().size() == 1);
    }

    @IsTest
    static void testGetForecastInfo(){
        WeatherController controller = getWeatherController(WeatherController.FORECAST);
        System.assert(controller.getWeatherItems().isEmpty());
        StaticResourceCalloutMock mock = getTestMock(GET_FORECAST_TEST_RESOURCE, 200);
        Test.setMock(HttpCalloutMock.class, mock);
        controller.getWeatherInfo(controller.doRequest(controller.requestMode));
        System.assert(!controller.getWeatherItems().isEmpty());
        System.assert(controller.getWeatherItems().size() > 1);
    }

    @IsTest
    static void testGetWeatherNegative(){
        PageReference pageRef = new PageReference(PAGE_URL);
        Test.setCurrentPage(pageRef);
        WeatherController controller = getWeatherController(WeatherController.FORECAST);
        System.assert(controller.getWeatherItems().isEmpty());
        StaticResourceCalloutMock mock = getTestMock(GET_WEATHER_TEST_RESOURCE, 401);
        Test.setMock(HttpCalloutMock.class, mock);
        controller.getWeatherInfo(controller.doRequest(controller.requestMode));
        System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
        System.assert(controller.getWeatherItems().isEmpty());
    }

    private static WeatherController getWeatherController(String requestOption){
        WeatherController controller = new WeatherController();
        controller.city = TEST_CITY;
        controller.requestMode =  requestOption;
        return controller;
    }

    private static StaticResourceCalloutMock getTestMock(String resource, Integer statusCode){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(resource);
        mock.setStatusCode(statusCode);
        mock.setHeader('Content-Type', 'application/json');
        return mock;
    }
}
