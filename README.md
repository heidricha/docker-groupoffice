# docker-groupoffice
dockerized group-office collaboration suite.

needs a fully qualified domain name for the mail installation.

docker image build -t groupoffice .
docker run -d -p 80 -p 443 -p 25 -p 465 -p 587 --name groupoffice --hostname mail.domain.net groupoffice