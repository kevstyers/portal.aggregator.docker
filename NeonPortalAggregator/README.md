# NeonPortalAggregator
A `fst` ETL Pipeline for performing basic analysis on NEON Data

Hosted on [AWS EC2 t2.medium](http://3.133.127.20:3838/NeonPortalAggregator/)!

The NeonPortalAggregator's (name subject to change as always) primary purpose is to build an ETL pipeline for basic IS data for post publication analysis and visualization.

All applicable 30 minute data (think basic metereological sensors) are downloaded and stored in fst files for easy transformations later in the pipeline. Data is collected in bulk, but can be scoped to perform a monthly DP pull (based upon data availability) to be merged with the primary dataset (baby steps...). 

The data will then be transformed (dp by dp) and then loaded into a shiny app/ rmarkdown report.

I'd like to see this repo expand to include more NEON data but for now I'm just going to focus on the basic TIS streams. Ideally this project makes neon data more accessible and inspires more advanced analysis.
