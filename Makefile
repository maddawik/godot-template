.PHONY: test

test:
	godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test/unit -ginclude_subdirs -gexit
