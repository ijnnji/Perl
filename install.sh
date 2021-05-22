#!/bin/bash
cpanm \
-v \
install \
Starman \
Moose \
Data::Dumper \
Plack::Request \
Plack::Component \
DBI \
strict \
Data::Dumper \
Log::Log4perl \
Config::JSON Plack::Builder \
Plack::Middleware::CrossOrigin \
FindBin
