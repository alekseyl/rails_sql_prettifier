# 5.0.5
* pg_adapter_with_nicesql setting will not be set to action for protected_env
* niceql version set to ~> 0.6 (fixed https://github.com/alekseyl/niceql/issues/16 !)

#5.0.4
* fixed issue [#20](https://github.com/alekseyl/niceql/issues/20)
* adding support for multiple ruby versions testing using docker-compose

# 5.0.3
* active record versioning is properly aligned now

# 5.0.2
* Fixed issue with Niceql.configure not configuring anything + test covered

# 5.0.0

* This a active record prior to 6.0 version compatible niceql integration 
  ( main difference is StatementInvalid initialization, starting version 6 it has named param sql: for original query ) 