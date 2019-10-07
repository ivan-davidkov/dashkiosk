FROM centos:7.6.1810

ENV DK_PORT="--port 8080"
ENV DK_ENVIRONMENT="--environment production"
ENV DK_BRANDING="--branding default"

RUN yum -y update && yum install -y epel-release git gifsicle gcc-c++ make optipng
RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash - && \
    rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg && \
    curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
    curl -sL https://libjpeg-turbo.org/pmwiki/uploads/Downloads/libjpeg-turbo.repo | tee /etc/yum.repos.d/libjpeg-turbo.repo

RUN yum -y update && yum -y install nodejs yarn libjpeg-turbo-utils avahi avahi-compat-libdns_sd avahi-compat-libdns_sd-devel

WORKDIR /dashkiosk
COPY . /dashkiosk/

ENV NPM_CONFIG_LOGLEVEL warn

RUN rm -rf node_modules build && \
    npm install -g bower grunt-cli && \
    npm install && \
    grunt && \
    cd dist && \
    npm install --production && \
    rm -rf ../node_modules ../build && \
    npm cache clean --force

RUN chmod +x /dashkiosk/entrypoint.sh

EXPOSE 8080

ENV NODE_ENV production
ENV port 8080
ENV db__options__storage /dashkiosk.sqlite

ENTRYPOINT [ "/dashkiosk/entrypoint.sh" ]
