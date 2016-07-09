FROM alpine

RUN apk add --no-cache build-base libffi-dev ruby ruby-dev ruby-json \
	&& gem install redcarpet jekyll jekyll-tagging jekyll-paginate --no-document \
	&& apk del --no-cache build-base libffi-dev ruby-dev

VOLUME ["/src"]

EXPOSE 4000

CMD jekyll serve -s /src -d /src/_site --host 0.0.0.0 --incremental --watch