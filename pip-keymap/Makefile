APP      = PiPKeymap
SRC      = PiPKeymap.swift
HTML     = pip-keymap.html

.PHONY: build run clean

build: $(APP)

$(APP): $(SRC)
	swiftc $(SRC) -framework WebKit -framework Cocoa -o $(APP)

run: build
	@echo "==> Launching PiP Keymap (Ctrl+Shift+K to toggle, Ctrl+Shift+[/] to cycle layers)"
	./$(APP) &

clean:
	rm -f $(APP)
