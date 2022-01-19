# 6.1.4
* fixed issue [#20](https://github.com/alekseyl/niceql/issues/20)
* adding support for multiple ruby versions testing using docker-compose

# 6.1.3
* Now AR is a dependency not a development dependency 

# 6.1.0

* This a active record prior to 7.0 version and >= 6.1 compatible niceql integration 
  ar < 6.0 breaking change: 
  * StatementInvalid initialization ahs a breaking change: starting version 6 it has named param sql: for original query )
  
  ar <= 6.1: 
  * Starting from 6.1 connection_db_config method replaced connection_config which was a hash