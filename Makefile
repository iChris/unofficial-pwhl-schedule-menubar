APP_NAME = PWHLSchedule
BUNDLE_IDENTIFIER = com.chris-studio.PWHLSchedule
SOURCES = Sources/*.swift

all: build

build:
	@mkdir -p $(APP_NAME).app/Contents/MacOS
	@mkdir -p $(APP_NAME).app/Contents/Resources
	swiftc $(SOURCES) -o $(APP_NAME).app/Contents/MacOS/$(APP_NAME) -target arm64-apple-macosx13.0
	cp Info.plist $(APP_NAME).app/Contents/Info.plist

clean:
	rm -rf $(APP_NAME).app
