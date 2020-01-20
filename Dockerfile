FROM debian:bullseye AS build

RUN apt -y update && apt -y install build-essential wget libpng-dev libtiff-dev libz-dev libwebp-dev libjpeg-dev libgif-dev pkg-config autoconf automake libtool libicu-dev libpango1.0-dev libcairo-dev

RUN wget -q http://www.leptonica.org/source/leptonica-1.79.0.tar.gz && tar zxf leptonica-1.79.0.tar.gz && cd leptonica-1.79.0 && ./configure --prefix=/opt/local && make -j 2 && make install && cd .. && rm -fr leptonica*

RUN wget -q https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz && tar xvf 4.1.1.tar.gz && cd tesseract-4.1.1 && ./autogen.sh && PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/local/lib/pkgconfig ./configure --prefix=/opt/local && make -j 2 && make install && cd .. && rm -fr 4.1.1.tar.gz && rm -fr tesseract-4*

FROM debian:bullseye-slim

COPY --from=build /opt /opt

RUN apt -y update && apt -y install libgomp1 libpng16-16 libjpeg62 libgif7 libtiff5 libwebpmux3

ADD https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata     /opt/local/share/tessdata
ADD https://github.com/tesseract-ocr/tessdata_best/raw/master/eng.traineddata /opt/local/share/tessdata

CMD /opt/local/bin/tesseract -v

