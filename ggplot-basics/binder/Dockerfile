FROM rocker/binder:3.6.3

ARG NB_USER

USER root
RUN Rscript -e 'install.packages("dslabs", version="0.7.3")' \
  && rm -rf /tmp/downloaded_packages
USER ${NB_USER}

COPY --chown=${NB_USER} ./ggplot-basics/ ${HOME}
