FROM pegi3s/docker:20.04
LABEL maintainer="hlfernandez"

# INSTALL COMPI
ADD image-files/compi.tar.gz /
ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

# PLACE HERE YOUR DEPENDENCIES (SOFTWARE NEEDED BY YOUR PIPELINE)

ADD resources/scripts /scripts

RUN chmod ugo+x /scripts/*
ENV PATH=/scripts/:${PATH}

COPY resources/working_dir/ /opt/working_dir/

ENV TERM=xterm-256color

# ADD PIPELINE
ARG IMAGE_NAME
ARG IMAGE_VERSION

ADD pipeline.xml /pipeline.xml
RUN mv /pipeline.xml /pipeline-$(echo ${IMAGE_NAME}${IMAGE_VERSION} | md5sum | awk '{print $1}').xml

ENTRYPOINT ["/entrypoint.sh"]
