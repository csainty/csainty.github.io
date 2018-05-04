FROM alpine

RUN apk add --no-cache build-base libffi-dev ruby ruby-dev ruby-json zlib-dev \
  && gem install sass redcarpet jekyll jekyll-tagging jekyll-paginate jekyll-sitemap jekyll-assets jekyll-seo-tag --no-document \
  && apk del --no-cache build-base libffi-dev ruby-dev zlib-dev

VOLUME ["/src"]

EXPOSE 4000

CMD jekyll serve -s /src -d /src/_site --host 0.0.0.0 --watch
