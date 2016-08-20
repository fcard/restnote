FROM gcc:latest

RUN useradd -ms /bin/bash tester; \
    apt-get install -y wget;

USER tester

COPY . /home/tester/rst_notebook_compiler
WORKDIR /home/tester/rst_notebook_compiler

RUN ./deps.sh -y
CMD ./restnote.sh
