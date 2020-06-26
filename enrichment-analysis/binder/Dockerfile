FROM rocker/binder:3.6.3

USER root

# install dependencies
RUN install2.r statmod \
  && Rscript -e 'BiocManager::install("edgeR", update=FALSE)' \
  && rm -rf /tmp/downloaded_files

# copy files
COPY --chown=rstudio:rstudio ./differential-expression-analysis/data ${HOME}/data/
COPY --chown=rstudio:rstudio ./enrichment-analysis/data ${HOME}/data/
COPY --chown=rstudio:rstudio ./enrichment-analysis/index.Rmd ${HOME}

USER rstudio
