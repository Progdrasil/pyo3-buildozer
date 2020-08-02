# Dockerfile for providing buildozer
#
# majority taken from https://github.com/kivy/buildozer/blob/master/Dockerfile

FROM kivy/buildozer

ENV ANDROID_HOME="${HOME_DIR}/android"
USER root
# The next line are taken from https://github.com/sameersbn/docker-postgresql/blob/master/Dockerfile
# RUN apt-get update \
#  && DEBIAN_FRONTEND=noninteractive apt-get install -y wget gnupg software-properties-common \
#  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
#  && echo 'deb http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main' >> /etc/apt/sources.list

# system requirements to build most of the recipes
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt install -qq --yes \
    wget \
    curl \
    acl \
    lld \
    locales \
    libssl-dev \
    libpq-dev \
    postgresql \
    postgresql-client \
    postgresql-contrib \
    # postgresql-server-dev-10.12 \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_MESSAGES=POSIX \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales


# RUN rm $(which python3) && cp $(which python3.7) /usr/bin/python3

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${HOME_DIR}/.cargo/bin

RUN chown ${USER}:${USER} -R ${HOME_DIR}

USER ${USER}

# install rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal

RUN rustup target add arm-linux-androideabi && \
    rustup target add aarch64-linux-android && \
    rustup target add armv7-linux-androideabi && \
    cargo install cargo-ndk

# Setup sdk (taken from https://github.com/bitrise-io/android/blob/master/Dockerfile)
RUN  wget -q http://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O ${HOME_DIR}/android-sdk-tools.zip \
    && unzip -q ${HOME_DIR}/android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm ${HOME_DIR}/android-sdk-tools.zip

RUN yes Y | sdkmanager --sdk_root=${ANDROID_HOME} --licenses
RUN yes Y | sdkmanager --sdk_root=${ANDROID_HOME} --install "build-tools;30.0.0"
RUN yes Y | sdkmanager --sdk_root=${ANDROID_HOME} --install "platform-tools"
RUN yes Y | sdkmanager --sdk_root=${ANDROID_HOME} --install "platforms;android-26"
RUN yes Y | sdkmanager --sdk_root=${ANDROID_HOME} --install "ndk;21.1.6352462"
    #/platform-tools

# Get apache ant
RUN wget -q http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.4-bin.tar.gz -O ${HOME_DIR}/apache-ant.tar.gz \
    && tar xzf ${HOME_DIR}/apache-ant.tar.gz -C ${ANDROID_HOME} \
    && rm ${HOME_DIR}/apache-ant.tar.gz

# RUN cp -r ${ANDROID_HOME}/tools ${ANDROID_HOME}/platform-tools
# output all versions for debug purposes
RUN ls ${ANDROID_HOME} \
    && psql --version \
    && python3 --version
