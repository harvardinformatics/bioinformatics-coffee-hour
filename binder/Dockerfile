FROM rocker/binder:3.6.2

ARG NB_USER
ARG NB_UID

USER root
COPY ./tidyverse/ ${HOME}

RUN chown -R ${NB_USER} ${HOME}

USER ${NB_USER}
