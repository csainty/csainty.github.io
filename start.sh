rm -rf _site/
docker pull csainty/blog
docker run --rm -it -p 4000:4000 -v $(pwd):/src csainty/blog
