.PHONY: lint lint-fix format format-check build test test-ci periphery screenshots

lint:
	swiftlint lint yours/ YoursWidgets/

lint-fix:
	swiftlint lint --fix yours/ YoursWidgets/

format:
	swiftformat yours/ YoursWidgets/

format-check:
	swiftformat --lint yours/ YoursWidgets/

build:
	xcodebuild -scheme yours -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

test:
	@rm -rf .build/tests.xcresult
	@xcodebuild test -scheme yours \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
		-only-testing:yoursTests \
		-resultBundlePath .build/tests.xcresult 2>&1 | xcbeautify --quiet
	@xcrun xcresulttool get test-results summary --path .build/tests.xcresult --compact \
		| jq -r '"", "  \(.result) — \(.passedTests) passed, \(.failedTests) failed, \(.skippedTests) skipped (\(.totalTestCount) total)", (if (.testFailures | length) > 0 then "  Failures:", (.testFailures[] | "    ✗ \(.testName): \(.failureText)") else empty end), ""'

test-ci:
	xcodebuild test -scheme yours \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
		-only-testing:yoursTests 2>&1 | xcbeautify --renderer github-actions

periphery:
	periphery scan

screenshots:
	cd fastlane && bundle exec fastlane ios screenshots
