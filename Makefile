.PHONY: setup tiles tiles-L1 clean-tiles test clean

setup:
	pip install -r pipeline/requirements.txt
	@echo "Setup complete. Run 'make tiles' to generate map tiles."

tiles:
	python3 pipeline/render_tiles.py --config pipeline/config.yaml --level all

tiles-L1:
	python3 pipeline/render_tiles.py --config pipeline/config.yaml --level L1

clean-tiles:
	rm -rf pipeline/output/
	@echo "Tiles cleaned."

test:
	cd WhereOnEarth && xcodebuild test \
		-scheme WhereOnEarth \
		-destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
		-resultBundlePath ../TestResults.xcresult \
		2>&1 | tail -20

clean: clean-tiles
	rm -rf TestResults.xcresult
