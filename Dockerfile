FROM ubuntu:16.04

WORKDIR /home/root/fuzz

ENV DEBIAN_FRONTEND=noninteractive
ENV LLVM_CONFIG=llvm-config-3.8
ENV GOPATH=/home/root/go

RUN apt-get update && apt-get install -y wget \
    build-essential git clang-3.8 golang-go python-setuptools cython libini-config-dev \
    lcov gnuplot graphviz doxygen libglib2.0-dev automake sudo texinfo libtool-bin bison \
    gdb python-pip screen vim netcat man

WORKDIR /home/root/fuzz/install
RUN if [ -z "$(ls -A /home/root/fuzz/install)" ] ; then \
    wget http://lcamtuf.coredump.cx/afl/releases/afl-2.52b.tgz \
    && tar -xf afl-2.52b.tgz && rm afl-2.52b.tgz && \
    git clone --depth 1 https://github.com/carolemieux/afl-rb && \
    git clone --depth 1 https://github.com/mboehme/aflfast && \
    git clone --depth 1 https://github.com/reflare/afl-monitor && \
    git clone --depth 1 https://github.com/jdbirdwell/afl && mv afl afl-network && \
    git clone --depth 1 https://github.com/mboehme/pythia && \
    git clone --depth 1 https://gitlab.com/laf-intel/laf-llvm-pass && \
    git clone --depth 1 https://github.com/jfoote/exploitable && \
    git clone --depth 1 https://github.com/jwilk/python-afl && \
    git clone --depth 1 https://github.com/zardus/preeny && \
    git clone --depth 1 https://github.com/Battelle/afl-unicorn && \
    git clone --depth 1 https://github.com/radare/radare2; \
    fi

#build afl
RUN ln -s /usr/bin/clang-3.8 /usr/bin/clang
RUN ln -s /usr/bin/clang++-3.8 /usr/bin/clang++
RUN cd afl-2.52b && make -j4 && cd qemu_mode && ./build_qemu_support.sh \
    && cd ../llvm_mode && make && cd ../ && make install
RUN cp -r afl-2.52b afl-llvm-passes

#build afl-rb
RUN cd afl-rb && make -j4

#build afl-fast
RUN cd aflfast && make -j4

#build afl-network
RUN cd afl-network && make -j4

#build pythia
RUN cd pythia && make -j4

#build afl-llvm-passes
RUN cp laf-llvm-pass/src/*.so.cc afl-llvm-passes/llvm_mode/
RUN cp laf-llvm-pass/src/afl.patch afl-llvm-passes/llvm_mode
RUN cd afl-llvm-passes/llvm_mode && patch < afl.patch
RUN cd afl-llvm-passes/llvm_mode && make

#build exploitable and crashwalk
RUN cd exploitable && python setup.py install
RUN echo "source /usr/local/lib/python2.7/dist-packages/exploitable-1.32-py2.7.egg/exploitable/exploitable.py" >> /home/root/fuzz/.gdbinit
RUN go get -u github.com/bnagy/crashwalk/cmd/...

#build python-afl
RUN cd python-afl && python setup.py install

#build preeny
RUN cd preeny && make -j4

#build afl-unicorn
RUN cd afl-unicorn && make -j4
RUN cd afl-unicorn/unicorn_mode && sudo ./build_unicorn_support.sh

#build arm-gdb
RUN wget http://ftp.gnu.org/gnu/gdb/gdb-8.0.1.tar.gz
RUN tar xzvf gdb-8.0.1.tar.gz && rm gdb-8.0.1.tar.gz
RUN mkdir arm-gdb && cd arm-gdb && ../gdb-8.0.1/configure --target=arm-none-eabi \
    --enable-interwork --enable-multilib --with-python && make -j4 && make install
RUN ln -s /home/root/fuzz/install/arm-gdb/gdb/gdb /usr/bin/arm-gdb

#build radare
RUN ./radare2/sys/install.sh

#install gef
RUN wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh
RUN echo "add-auto-load-safe-path /home/root/fuzz/.gdbinit" >> /root/.gdbinit

#install driller
RUN cp -r afl-2.52b driller
WORKDIR /home/root/fuzz/install/driller
RUN pip install git+https://github.com/angr/cle
RUN pip install git+https://github.com/angr/angr
RUN pip install git+https://github.com/angr/tracer
RUN pip install git+https://github.com/shellphish/driller

WORKDIR /home/root/fuzz

CMD ["/bin/bash"]
