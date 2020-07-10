FROM elixir:1.9
COPY . .
RUN rm -rf _build deps
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
EXPOSE 4000
CMD mix run --no-halt
