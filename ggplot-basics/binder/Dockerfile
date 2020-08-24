FROM rocker/binder:3.6.3

ARG NB_USER

USER root
RUN install2.r dslabs \
  && rm -rf /tmp/downloaded_packages
USER ${NB_USER}

COPY --chown=${NB_USER} ./ggplot-basics/ ${HOME}
