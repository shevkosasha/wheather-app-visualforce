public class WeatherWrapper{

	public Integer visibility{get;set;}
	public Clouds clouds{get;set;}
	public Wind wind{get;set;}
	public Integer dt{get;set;}
	public Main main{get;set;}
	public Sys sys{get;set;}
	public String base{get;set;}
	public Integer timezone{get;set;}
	public list<Weather> weather{get;set;}
	public Integer id{get;set;}
	public Coord coord{get;set;}
	public String name{get;set;}
	public Integer cod{get;set;}
	public class Wind{
		public Integer deg{get;set;}
		public Decimal speed{get;set;}
	}
	public class Weather{
		public String description{get;set;}
		public String main{get;set;}
		public String icon{get;set;}
		public Integer id{get;set;}
	}
	public class Sys{
		public Integer type{get;set;}
		public Integer sunrise{get;set;}
		public String country{get;set;}
		public Integer sunset{get;set;}
		public Integer id{get;set;}
	}
	public class Main{
		public Integer pressure{get;set;}
		public Decimal temp_min{get;set;}
		public Decimal temp_max{get;set;}
		public Decimal feels_like{get;set;}
		public Integer humidity{get;set;}
		public Decimal temp{get;set;}
	}
	public class Coord{
		public Decimal lat{get;set;}
		public Decimal lon{get;set;}
	}
	public class Clouds{
		public Integer all{get;set;}
	}
	public static WeatherWrapper parse(String json){ 
		return (WeatherWrapper) System.JSON.deserialize(json, WeatherWrapper.class);
	}
}