
# lazy

Hackable Coding Assistant

## Features

* Single point to run all your code analysis
* Comes with a set of built-in code analysis engines
* Gives you tools to create your own engines and shared them with others

## Installation

* Install Docker
* Run `curl ... | sh` - this will setup `lazy` and start it as daemon
* Install `lazy` package for your editor of choice

## Supported editors

### Atom

* [linter-lazy](https://atom.io/packages/linter-lazy) for Atom's [Linter](https://atom.io/packages/linter)

## Engines

Engines are Docker containers running an HTTP server which follows the API specification. Reference implementation of such server for NodeJS can be found in [lazy-engine-reference-node](https://github.com/SoftwareMarbles/lazy-engine-reference-node) repository.

### Labels

Docker image of each engine must have the following labels defined at the build time:

* `io.lazyass.lazy.engine.languages`: a string with comma-separated languages that the engine supports (e.g. `C, C++, Objective-C, Objective-C++`)

For our official engines we set this in Dockerfile. For example, in [lazy-emcc-engine](https://github.com/SoftwareMarbles/lazy-emcc-engine) we have:

```
LABEL "io.lazyass.lazy.engine.languages"="C, C++, Objective-C, Objective-C++"
```

### Graceful termination

Engines should shut down gracefully when stopped by Docker. In our official engines we use `SIGTERM` signal for this. In Dockerfile we specify the following:

```
STOPSIGNAL SIGTERM
```

And in the engine code we then monitor for `SIGTERM` signal and try to gracefully shut down. If for whatever reason you don't want to use `SIGTERM`, you can use something else as lazy relies on Docker to send the signal so whatever you define in `STOPSIGNAL` will be sent.

### Conventions

Currently lazy creates a private volume for all engines to access and this volume is mounted as `/lazy` inside of engines. At this moment this isn't configurable.

### Helper containers

lazy binds Docker socket to all engines it is running so all engines have full access to Docker daemon on the process. This is clearly a security concern but considering that lazy on its own is meant to be run only locally and that all engines running on it are fully controlled by the user, this lessens the concerns.

To create helper containers (which we often do in our official engines), you can use [@lazyass/engine-helpers](https://github.com/SoftwareMarbles/lazy-engine-helpers) Node module.

## lazy.yaml

On start lazy loads engine configurations and runs them. The engine configuration is, by default, set in `lazy.yaml` file found in the lazy's root directory. Here's an example:

```
version: 1
# id: default # optional
repository_auth: # optional, only needed if your engines are in a private Docker repository
    username: <your-user-name>
    password: <your-password>
    email: <your-email>
engines: # each of these engines can be left out and other custom or official engines may be added
    eslint:
        image: ierceg/lazy-eslint-engine:latest
    stylelint:
        image: ierceg/lazy-stylelint-engine:latest
    tidy-html:
        image: ierceg/lazy-tidy-html-engine:latest
    emcc:
        image: ierceg/lazy-emcc-engine:latest
    php-l:
        image: ierceg/lazy-php-l-engine:latest
    pmd-java:
        image: ierceg/lazy-pmd-java-engine:latest
```

To allow easier hacking lazy can run engines mounted from local host filesystem. For example if we wanted to hack on `lazy-eslint-engine`:

```
version: 1
id: hacking
engines:
    eslint:
        image: ierceg/node-dev:6.9.1
        command: nodemon -V -d 1 -L -w node /app/index.js
        working_dir: /app
        volumes:
            - "/<your path to lazy-eslint-engine source code>:/app"
        labels:
            "io.lazyass.lazy.engine.languages": "JavaScript"
```

If you furthermore run lazy with `./lazy-dev` then both lazy and the engine above will be restarted on their respective source code changes.

## Tests

At this moment most of our tests are of integration variety - we run a full lazy service and then send requests to it. You can run them with `make test`. Coverage is not great, to say the least so please feel free to jump in.
