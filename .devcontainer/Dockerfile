FROM mcr.microsoft.com/devcontainers/base:bookworm

RUN apt-get update

# Erlang Requirements
RUN apt-get install \
  -y \
  build-essential autoconf m4 libncurses-dev libwxgtk3.2-dev \
  libwxgtk-webview3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev \
  libssh-dev unixodbc-dev xsltproc fop libxml2-utils openjdk-17-jdk

# Elixir Requirements
RUN apt-get install \
  -y \
  inotify-tools

# ASDF
RUN apt-get update && \
  apt-get install curl git

USER vscode
RUN git clone \
  https://github.com/asdf-vm/asdf.git \
  ~/.asdf \
  --branch v0.14.0 && \
  export ASDF_DIR="$HOME/.asdf" && \
  . "$HOME/.asdf/asdf.sh" && \
  echo ". \"$HOME/.asdf/asdf.sh\"" >> ~/.bashrc && \
  echo ". \"$HOME/.asdf/completions/asdf.bash\"" >> ~/.bashrc && \
  echo ". \"$HOME/.asdf/asdf.sh\"" >> ~/.zshrc && \
  sed  -i 's/plugins=(git)/plugins=(git asdf)/g' ~/.zshrc && \
  asdf plugin add elixir && \
  asdf plugin add erlang
USER root
COPY ./asdf-post-create.sh /asdf-post-create.sh
