FROM fuzzers/afl:2.52 as builder

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev libjpeg-dev libpng-dev
ADD . /dcmtk
WORKDIR /dcmtk
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ .
RUN make
RUN wget http://medistim.com/wp-content/uploads/2016/07/ttfm.dcm
RUN wget https://github.com/SaravananSubramanian/dicom/blob/master/DICOM%20Basics%20-%20Making%20Sense%20of%20the%20DICOM%20File/IM-0001-0001.dcm
RUN wget https://github.com/dangom/sample-dicom/blob/master/MR000000.dcm

FROM fuzzers/afl:2.52 
COPY --from=builder /dcmtk/bin/dcmdump /
COPY --from=builder /dcmtk/*.dcm /testsuite/

ENTRYPOINT ["afl-fuzz", "-i", "/testsuite", "-o", "/dcmtkOut"]
CMD  ["/dcmdump", "@@"]
