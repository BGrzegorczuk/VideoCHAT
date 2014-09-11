This is a code I had started writting some time ago, but then I left it due to lack of time :) The code is not finished and should be treated as an example code.


VideoCHAT
=========

Simple WebRTC VideoCHAT application on Express.js using GruntJS and Web Workers. The main idea behind that project was to allow users to communicate in a real-time manner using video & audio connection. What's more, I wanted users to be able to exchange files peer2peer. Project was written using TDD.


How to run:
-----------

1) npm install
2) grunt build

3) To run video chat successfully, one must set proper IP address assigned by the router - it CANNOT be localhost or 0.0.0.0! Application has to be started in the browser using that address, ex. http://192.168.1.21:3000


To run tests:
-------------
open /tests/test-runner.html file in the browser.


Suggestions:
------------

Bower package manager should be introduced to handle vendor libraries in a more proper way.It should cowork with Grunt.