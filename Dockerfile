# nodejs-fedora33
FROM ghcr.io/alexanderniebuhr/s2i-base:fedora-33

EXPOSE 8080

ENV NODEJS_VERSION=14 \
  NPM_RUN=start

ENV SUMMARY="Platform for building and running Node.js $NODEJS_VERSION applications" \
  DESCRIPTION="Node.js $NODEJS_VERSION available as container is a base platform for \
  building and running various Node.js $NODEJS_VERSION applications and frameworks. \
  Node.js is a platform built on Chrome's JavaScript runtime for easily building \
  fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model \
  that makes it lightweight and efficient, perfect for data-intensive real-time applications \
  that run across distributed devices."

LABEL summary="$SUMMARY" \
  description="$DESCRIPTION" \
  io.k8s.description="$DESCRIPTION" \
  io.k8s.display-name="Node.js $NODEJS_VERSION" \
  io.openshift.expose-services="8080:http" \
  io.openshift.tags="builder,$NAME,$NAME$NODEJS_VERSION" \
  io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
  io.s2i.scripts-url="image:///usr/libexec/s2i" \
  name="$FGC/$NAME" \
  version="$NODEJS_VERSION" \
  maintainer="Alexander Niebuhr <45965090+alexanderniebuhr@users.noreply.github.com>" \
  help="For more information visit https://github.com/alexanderniebuhr/s2i-nodejs"

RUN yum -y module enable nodejs:$NODEJS_VERSION && \
  yum install -y make gcc gcc-c++ libatomic_ops nodejs nodejs-nodemon npm nss_wrapper git && \
  rpm -V make gcc gcc-c++ libatomic_ops nodejs nodejs-nodemon npm nss_wrapper && \
  yum -y clean all

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Copy extra files to the image, including help file.
COPY ./scripts/ /

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:0 ${APP_ROOT} && chmod -R ug+rwx ${APP_ROOT} && \
  rpm-file-permissions

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage