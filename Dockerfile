FROM node:10

RUN npm install -g bower grunt-cli
RUN apt-get -qq update && apt-get install -qq gifsicle libjpeg-progs optipng libavahi-compat-libdnssd-dev

WORKDIR /dashkiosk

RUN curl https://codeload.github.com/vincentbernat/dashkiosk/tar.gz/v2.7.8 --output dashkiosk.tar.gz && \
    tar -xvf dashkiosk.tar.gz --strip-components=1

COPY . /dashkiosk/

ENV NPM_CONFIG_LOGLEVEL warn
RUN rm -rf node_modules build && \
    npm install && \
    grunt && \
    cd dist && \
    npm install --production && \
    rm -rf ../node_modules ../build && \
    npm cache clean --force

RUN chmod +x /dashkiosk/entrypoint.sh

# We use SQLite by default. If you want to keep the database between
# runs, don't forget to provide a volume for /database.
VOLUME /database

ENV NODE_ENV production
ENV port 8080
#ENV db__options__storage /database/dashkiosk.sqlite
ENV db__database db_dashkiosk
ENV db__username admin
ENV db__options__dialect mysql
ENV db__options__host mariadb.services

ENTRYPOINT [ "/dashkiosk/entrypoint.sh" ]
EXPOSE 8080
