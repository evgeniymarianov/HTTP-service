FROM ruby:2.6

COPY . /http_service

WORKDIR /http_service

EXPOSE 5678

CMD ["ruby","http_service.rb"]

