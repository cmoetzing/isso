# First, compile JS stuff
FROM node:dubnium-buster
WORKDIR /src/
COPY . .
RUN npm install -g requirejs uglify-js jade bower \
 && make init js

# Second, create virtualenv
FROM python:3.8-buster
WORKDIR /src/
COPY --from=0 /src .
RUN python3 -m venv /isso \
 && . /isso/bin/activate \
 && pip3 install --no-cache-dir --upgrade pip \
 && pip3 install --no-cache-dir cffi flask \
 && python setup.py install \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Third, create final repository
FROM python:3.8-slim-buster
WORKDIR /isso/
COPY --from=1 /isso .

# Configuration
VOLUME /db /config /logs
EXPOSE 8080
CMD ["/isso/bin/isso", "-c", "/config/isso.cfg"]
