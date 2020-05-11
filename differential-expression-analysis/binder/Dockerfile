FROM rocker/binder:3.6.2

ARG NB_USER
ARG NB_UID

USER root

# install dependencies
RUN install2.r statmod \
  && Rscript -e 'BiocManager::install("edgeR", update=FALSE)' \
  && rm -rf /tmp/downloaded_files

# copy files
COPY ./differential-expression-analysis/ ${HOME}

RUN chown -R ${NB_USER} ${HOME}

USER ${NB_USER}
