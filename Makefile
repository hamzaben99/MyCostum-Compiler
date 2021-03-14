SRC_DIR=./src
TST_DIR=./tst

all: build

build:
	cd $(SRC_DIR) && make
	mv $(SRC_DIR)/lang ./myc
	
test:
	./compile.sh $(TST_DIR)/test.myc

clean: 
	cd $(SRC_DIR) && make clean
	cd $(TST_DIR) && rm -rf test.? test
	rm -rf myc