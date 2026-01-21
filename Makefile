SRC := src
BUILD := build
DIST := dist


.PHONY: all compile zip dist clean run

all: dist

# Compile Turbo Pascal source files
compile:
	dosemu -quiet $(SRC)/build.bat -dumb
	@mkdir -p $(BUILD)
	@find $(SRC) -name '*.exe' -exec mv {} $(BUILD) \;
	@find $(SRC) -name '*.exe' -delete
	@find $(SRC) -name '*.tpu' -delete

	# Copy data files
	@if [ -d "$(SRC)/data" ]; then \
		mkdir -p $(BUILD)/data; \
		cp -r $(SRC)/data/* $(BUILD)/data/; 2>/dev/null || true; \
	fi

# Zip the build directory 
zip: compile 
	@mkdir $(DIST)
	cd $(BUILD) && zip -r ../$(DIST)/build.zip .

dist: zip

run: compile
	dosbox-x -fastlaunch -nolog -exit $(BUILD)/runme.exe	


clean:
	@rm -rf $(BUILD) $(DIST)

