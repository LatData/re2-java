#
# Inspired by https://github.com/xerial/snappy-java/blob/develop/Makefile .
#

OBJ=obj
MVN=mvn
NATIVES-TARGET=src/main/resources/NATIVE/$(shell bin/os-arch.sh)/$(shell bin/os-name.sh)

all: build
build: $(OBJ)/libre2-java.so class

.re2.download.stamp:
	git clone https://github.com/google/re2.git
	touch .re2.download.stamp

.re2.compile.stamp: .re2.download.stamp
	cd re2 && make
	touch .re2.compile.stamp

$(OBJ)/RE2.o: .re2.download.stamp $(addprefix src/main/java/com/logentries/re2/, RE2.cpp RE2.h)
	mkdir -p $(OBJ)
	$(CXX) -std=gnu++11 -O3 -g -fPIC -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/linux -Ire2 -c src/main/java/com/logentries/re2/RE2.cpp -o $(OBJ)/RE2.o

$(OBJ)/libre2-java.so: $(OBJ)/RE2.o .re2.compile.stamp
	$(CXX) -shared -Wl,-soname,libre2-java.so -o $(OBJ)/libre2-java.so $(OBJ)/RE2.o -Lre2/obj/so -lre2 -lpthread
	strip $(OBJ)/*

class: build-class

build-class: target/libre2-java-1.0-SNAPSHOT.jar

target/libre2-java-1.0-SNAPSHOT.jar: add-so
	$(MVN) package -Dmaven.test.skip=true

add-so: .re2.compile.stamp $(OBJ)/libre2-java.so
	mkdir -p $(NATIVES-TARGET)
	cp $(OBJ)/libre2-java.so re2/obj/so/libre2.so $(NATIVES-TARGET)

lib: add-so

clean:
	rm -fr re2
	rm -fr obj
	rm -fr target
	rm -fr src/main/resources/NATIVE
	rm -f .*.stamp

install:
	mvn install:install-file -Dfile=target/libre2-java-1.2.5.jar

