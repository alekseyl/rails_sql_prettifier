# 6.0.6
* pg_adapter_with_nicesql setting will not be set to action for protected_env
* niceql version set to ~> 0.6 (fixed https://github.com/alekseyl/niceql/issues/16 !)

#6.0.5
* fixed issue [#20](https://github.com/alekseyl/niceql/issues/20)
* adding support for multiple ruby versions testing using docker-compose

# 6.0.4
* Now AR is a dependency not a development dependency

# 6.0.3
* Fixed issue with Niceql.configure not configuring anything + test covered

#6.0.2

* This a active record prior to 7.0 version and >= 6.1 compatible niceql integration 
  ar < 6.0 breaking change: 
  * StatementInvalid initialization has a breaking change: starting version 6 it has named param sql: for original query )
  
