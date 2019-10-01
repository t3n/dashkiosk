FROM node:10-alpine AS build

RUN apk add --no-cache \
        python \
        make \
        g++ \
        alpine-sdk \
        gifsicle libjpeg-turbo-dev optipng avahi avahi-dev avahi-compat-libdns_sd git autoconf automake nasm && \
        npm install -g grunt

WORKDIR /dashkiosk

RUN curl https://codeload.github.com/vincentbernat/dashkiosk/tar.gz/v2.7.8 --output dashkiosk.tar.gz && \
    tar -xvf dashkiosk.tar.gz --strip-components=1

WORKDIR /dashkiosk

RUN rm -rf node_modules build && \
    npm install && \
    grunt && \
    cd dist && \
    npm install --production && \
    rm -rf ../node_modules ../build && \
    npm cache clean --force

FROM node:10-alpine as release

COPY --from=build /dashkiosk /dashkiosk

# We use SQLite by default. If you want to keep the database between
# runs, don't forget to provide a volume for /database.
VOLUME /database

ENV NODE_ENV production
ENV port 8080
ENV db__options__storage /database/dashkiosk.sqlite
#ENV db__database db_dashkiosk
#ENV db__username admin
#ENV db__options__dialect mysql
#ENV db__options__host mariadb.services

ENTRYPOINT [ "node" ,"/dashkiosk/dist/server.js" ]
EXPOSE 8080
