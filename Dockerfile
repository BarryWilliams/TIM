FROM ruby:3.2.2

RUN gem install puma:6.3.1 rack:3.0.8 sinatra:3.1.0
RUN groupadd app
RUN useradd -g app -m app
USER app:app
WORKDIR /app
EXPOSE 4567/tcp

COPY ./app .

ENTRYPOINT ["ruby", "app.rb"]