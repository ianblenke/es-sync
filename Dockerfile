FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y curl jq

ADD es-sync.sh /es-sync.sh

CMD /es-sync.sh
