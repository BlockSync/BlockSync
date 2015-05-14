#BlockSync

[![Build Status](https://travis-ci.org/BlockSync/BlockSync.svg?branch=master)](https://travis-ci.org/BlockSync/BlockSync)
[![Coverage Status](https://coveralls.io/repos/BlockSync/BlockSync/badge.svg?branch=master)](https://coveralls.io/r/BlockSync/BlockSync?branch=master)

###What is BlockSync?
BlockSync is a library that is intended to make working with blocks easier, quicker to develop, and safer. BlockSync has the following ideals and goals:

* To make working with blocks, especially asyncronous blocks, easier.
* To ensure thread safety, but to not interfere with threads in any way.
* Tasks with concurrency limits must be followed perfectly.
* To maintain 100% code coverage.
* Should not cause dead locks.
* Should not waste time or CPU cycles in order to make the function work.
* Should not have race conditions.

BlockSync is a well tested (100% coverage), but is not mature. With time, usage, and feedback, it can become mature and battle-tested. I would like to challenge the community to find corner cases where BlockSync does not follow the goals mentioned above.

###PR Guidelines
* You must maintain 100% code coverage.
* Tests must cover all corner cases.
* Callbacks must always be called on the original thread.
* Invalid states should throw an exception.
* Description of what you've changed, and why is mandatory.

I highly encourage people to open pull requests and to try to break it-- the community is what makes projects great! :)

BlockSync was heavily inspired by [caolan/async](https://github.com/caolan/async). Eventually, BlockSync should implement all functionality of caolan/async, and extend it further.
