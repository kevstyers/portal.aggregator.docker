FROM rocker/r-ver:3.6.3

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget \
    git
    



# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    chown shiny:shiny /var/lib/shiny-server

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838


RUN git clone https://github.com/kevstyers/NeonPortalAggregator.git /srv/shiny-server/NeonPortalAggregator

# Run package install

RUN apt-get install libssl-dev -y
RUN apt-get install libssl-dev -y

RUN R -e "source('/srv/shiny-server/NeonPortalAggregator/src/installAllPackages.R')"

RUN apt-get install -y xdg-utils

CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/NeonPortalAggregator/', host = '0.0.0.0', port = 3838)"]

# COPY shiny-server.sh /usr/bin/shiny-server.sh

# CMD ["/usr/bin/shiny-server.sh"]
