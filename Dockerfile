ARG ELIXIR_VERSION=1.13.0
ARG ERLANG_VERSION=24.1.6
ARG HEXPM_BOB_OS=debian
ARG HEXPM_BOB_OS_VERSION=bullseye-20210902-slim

FROM hexpm/elixir:$ELIXIR_VERSION-erlang-$ERLANG_VERSION-$HEXPM_BOB_OS-$HEXPM_BOB_OS_VERSION

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# Only copy the final release from the build stage
COPY --chown=nobody:root _build/prod/rel/athena ./

USER nobody

CMD ["/app/bin/server"]

# Appended by flyctl
ENV ECTO_IPV6 true
ENV ERL_AFLAGS "-proto_dist inet6_tcp"