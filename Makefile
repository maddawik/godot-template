.PHONY: import test build

import:
	godot --headless --import

.godot:
	$(MAKE) import

test: | .godot
	godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test/unit -ginclude_subdirs -gexit

build: | .godot
	./scripts/export.sh
