# portal.aggregator.docker
Repo for a shiny docker app

## Starting off
(assumes you already have ShinyProxy/Docker installed)

Clone repo to linux system

`sudo git clone https://github.com/kevstyers/portal.aggregator.docker.git`

Once cloned, its time to run the docker file 

`cd portal.aggregator.docker/`  
`sudo docker build --tag portal.aggregator:1.0 .`

now lets run it to make sure its running on the right ports and everything is built correctly
`sudo docker run portal.aggregator:1.0`

```
Listening on http://0.0.0.0:3838
```

perfect!

now lets make sure the `application.yml` is configured correctly  
you have to right this file. it is not natively made when you install ShinyProxy.

`cd ~/ShinyProxy/target`  
`sudo touch application.yml`  
`sudo nano application.yml`  

copy and paste (uh oh) this into the nano  
The ports have to be open, with AWS this is simple and easy to google

fill in the { } field with your info

```
proxy:
  title: ShinyProxy Server using Docker!
  # logo-url: 
  url: http://{host ip}:{port}/
  landing-page: /
  heartbeat-rate: 10000
  heartbeat-timeout: 60000
  port: 3975
  authentication: none

  # Docker configuration
  docker:
    # cert-path: /home/none
    url: http://localhost:2375 # always this this is where docker look
    port-range-start: 20000
  specs:
  - id: NeonPortalAggregator
    display-name: Neon Portal Aggregator
    description: Application which demonstrates the basics of a Shiny app
    container-image: pleasework:1.0
  - id: portal.agg
    display-name: Neon Portal Aggregator
    description: Application which demonstrates the basics of a Shiny app
    container-image: pleasework:1.0


logging:
  file:
    shinyproxy.log
```



now cd to where the java install of ShinyProxy is located
`cd ~/ShinyProxy/target/`  

run ShinyProxy  
`sudo java -jar shinyproxy-2.3.0.jar`  

