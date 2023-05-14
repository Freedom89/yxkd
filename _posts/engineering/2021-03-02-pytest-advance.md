---
title: Pytest Part 2 - Fixtures, Marking, Configs
date: 2021-03-02 0000:00:00 +0800
categories: [Knowledge, Engineering]
tags: [engineering, testing, pytest, python]   # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---

## Introduction

This is a further "advanced" section into [pytest](../pytest) 

We will covering a few more use cases & problems you might have encountered:

* How to set pytest configuration?
* How to share fixtures across scripts?
* What are more interesting things you can do with fixtures?
* Custom marking of tests

### Pre-req

I assume the following prerequisites: 

* Python
* Terminal (cli)

Good to have:

* [Makefile](../makefile)
* [Docker](../docker)

### Setup

The final code can be found in [same github repo](https://github.com/Freedom89/pytest-tutorial) under the folder `fixtures`. The vscode devcontainer is also provided!

* "requirements.txt"

    Note, we probably only need `pytest` over here but the remaining are useful in configuring your environment or running other tests like `mypy` or `flake8` if you are familiar with them. 

    ```text
    black
    flake8
    pytest
    pylint
    mypy
    pydantic
    jupyter
    ```

* "Dockerfile"

    The dockerifle has default entrypoint make
    
```dockerfile
FROM continuumio/miniconda3:4.8.2
RUN apt-get update - && \
    apt-get install -y build-essential && apt-get install -y make curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $HOME/my_project

COPY requirements.txt $HOME/my_project/

RUN pip install -r requirements.txt

COPY pytest.ini Makefile $HOME/my_project/

COPY tests $HOME/my_project/tests

ENTRYPOINT ["make"]
CMD ["run"]
```

## Structure

In a typical pytest structure, this is what you might have:

```bash
.
├── Dockerfile
├── Makefile
├── pytest.ini
├── requirements.txt
├── src
└── tests
```

But in this case we do not need `src` as the tests are self-sufficient.

## Conftests 

The first topic we are going to introduce is `conftest.py`. This file usually sits with each file directory. This file *must* be named `conftest.py`. 

To start, we first create a `conftest.py` under your `tests` directory:

```python
## tests/conftest.py
import pytest
import logging


@pytest.fixture()
def dummy_data():
    return dict(user_id=123, sales="apple", quantity=400, price=1.12)
```

Followed by a python script `tests/test_conf.py`

```python
import pytest
import logging

def test_calculate_sales_volume(dummy_data):
    logging.info("this is to demostrate that the logging does not print out")
    assert dummy_data.get("user_id") == 123
```

Followed by running `pytest tests/test_conf.py`

Output:

```bash
tests/test_conf.py.          [100%]

======== 1 passed in 0.05s ========
```

> Special note (from the official docs):
>
> You can have multiple nested directories/packages containing your tests, and each directory can have its own `conftest.py` with its own fixtures, adding on to the ones provided by the `conftest.py` files in parent directories.

## Configuration - pytest.ini

The first thing to notice that there was no logging output. By checking the [python docs](https://docs.pytest.org/en/6.2.x/logging.html) on how we can output the logs to console, we can run:

```bash
pytest tests/test_conf.py --log-cli-level=INFO
```

Output:

```bash
tests/test_conf.py::test_calculate_sales_volume
------------------ live log call ------------------
INFO     root:test_conf.py:6 this is to demostrate that the logging does not print out
PASSED                                      [100%]

================ 1 passed in 0.01s ================
```

### Logging

Instead of adding the `--log-cli-level` parameter, we can use configure our pytest with config file. There are multiple ways to configure our pytest, we will be using `pytest.ini`. 

We create a `pytest.ini` file

```ini
[pytest]
log_cli=true
log_level=INFO
```

and we can run the same command `pytest tests/test_conf.py` to observe the same output.

### Marking

Sometimes it might be hard to run selection of tests via regex or marking or file names, and probably better to do with [marking] instead. Here is a trivial example:

In `tests/test_conf.py` add:
```python
@pytest.mark.special
def test_special_marker(dummy_data):
    logging.info("special marker test")
    assert dummy_data.get("user_id") == 123
```

Because we are using special markers, we need to configure our `pytest.ini` to accept such a marker. (We will also add other markers we need in the future section)

```text
[pytest]
log_cli=true
log_level=INFO
markers=
	special: test at special level
	function: test at function level
	class_: test at class level
	module: test at a module level
	session: test at a session level
```

and we can trigger the tests with:

```bash
pytest -m special
```

output:

```bash
tests/test_conf.py::test_special_marker
------------------ live log call ------------------
INFO     root:test_conf.py:12 special marker test
PASSED                                      [100%]
```

## Setup and Teardown

When running pytests, sometimes you might want to [setup code and potentially tear down code](https://docs.pytest.org/en/6.2.x/fixture.html#teardown-cleanup-aka-fixture-finalization).

To do this with pytests, we can make use of the `yield` statement:

In `tests/conftest.py` add:

```python

@pytest.fixture()
def demo_yield():
    logging.info("setting up based on demo yield")
    dummy_func = lambda x: x ** 2  # noqa
    yield dummy_func
    logging.info("tearing down based on demo yield")

```

In `tests/test_conf.py` add:

```python

def test_yield(demo_yield):
    my_func = demo_yield  # yield the function
    assert my_func(10) == 100
    logging.info("this is to demostrate its still happening in this test function")
```

Run:

```bash
pytest -k test_yield
```

Output - notice the `setup` and `teardown` :

```bash
tests/test_conf.py::test_yield
----------------- live log setup ------------------
INFO     root:conftest.py:12 setting up based on demo yield
------------------ live log call ------------------
INFO     root:test_conf.py:19 this is to demostrate its still happening in this test function
PASSED                                      [100%]
---------------- live log teardown ----------------
INFO     root:conftest.py:15 tearing down based on demo yield
```


### Use cases

Here is an example of a database usecase (notice the `scope` parameter which we will cover in next section). 

```python
@pytest.fixture(scope='module')
def test_database():
    db.create_all()
    yield db  # testing happens here
    db.session.remove()
    db.drop_all()
```

## Scope 

By default, fixtures are loaded at a functional level. To demostrate this:

In `tests/conftests.py` add:

```python
@pytest.fixture()
def function_fixture():
    logging.info("function trigger")
    return True
```

Create a new script `tests/test_function.py`

```python
import pytest

@pytest.mark.function
def test_one(function_fixture):
    assert function_fixture

@pytest.mark.function
def test_two(function_fixture):
    assert function_fixture
```

and we run it with:

```bash
pytest -m function
```

Output:

```bash
tests/test_function.py::test_one
----------------- live log setup ------------------
INFO     root:conftest.py:20 function trigger
PASSED                                      [ 50%]
tests/test_function.py::test_two
----------------- live log setup ------------------
INFO     root:conftest.py:20 function trigger
PASSED                                      [100%]
```

As we can see, this means that for each tests (which is a test function) will cause the fixture to be loaded again.

In certain cases, you might not want this behaviour, such as a connection with a database you do not want to trigger multiple connections for each tests. 

There are 5 different scopes when it comes to fixtures:

| Scope    | Description                                                              |
| :------- | :----------------------------------------------------------------------- |
| function | default scope - runs at every function level                             |
| class    | runs at every class level                                                |
| module   | runs at every module level (note, a module is "sort of" like a script)   |
| package  | runs at every package level, a package is a collection of modules        |
| session  | runs at the python session (which usually consists of multiple packages) |

### More examples

Examples on each of the other scopes:

We add each of the new scopes in `tests/conftests.py`:

```python

@pytest.fixture(scope="class")
def class_fixture():
    logging.info("class trigger")
    return True


@pytest.fixture(scope="module")
def module_fixture():
    logging.info("module trigger")
    return True


@pytest.fixture(scope="session")
def session_fixture():
    logging.info("session trigger")
    return True
```

And to demostrate each of them:

* "Class"

    Create a script `tests/test_class.py`

    Note - the `class_` is due to `class` being a reserved keyword in pytest.

    ```python
    import pytest


    @pytest.mark.class_
    @pytest.mark.usefixtures("class_fixture")
    class TestMyFixtures:
        def test_one(self):
            assert self

        def test_two(self):
            assert self


    @pytest.mark.class_
    @pytest.mark.usefixtures("class_fixture")
    class TestMyFixturesAgain:
        def test_three(self):
            assert self

        def test_four(self):
            assert self
    ```

    Run with `pytest -m class_`

    Output:

    ```bash
    tests/test_class.py::TestMyFixtures::test_one
    ----------------- live log setup ------------------
    INFO     root:conftest.py:26 class trigger
    PASSED                                      [ 25%]
    tests/test_class.py::TestMyFixtures::test_two PASSED [ 50%]
    tests/test_class.py::TestMyFixturesAgain::test_three
    ----------------- live log setup ------------------
    INFO     root:conftest.py:26 class trigger
    PASSED                                      [ 75%]
    tests/test_class.py::TestMyFixturesAgain::test_four PASSED [100%]
    ```

* "Module"

    To demostrate a module tests we need to create two scripts, 

    Create a script `tests/test_module.py`

    
    ```python
    import pytest


    @pytest.mark.module
    def test_one(module_fixture):
        assert module_fixture


    @pytest.mark.module
    def test_two(module_fixture):
        assert module_fixture

    ```

    Create a duplicate `tests/test_module2.py`

    ```python
    import pytest


    @pytest.mark.module
    def test_three(module_fixture):
        assert module_fixture


    @pytest.mark.module
    def test_four(module_fixture):
        assert module_fixture
    ```

    Run with `pytest -m module`:
    
    ```bash
    ----------------- live log setup ------------------
    INFO     root:conftest.py:32 module trigger
    PASSED                                      [ 25%]
    tests/test_module.py::test_two PASSED       [ 50%]
    tests/test_module2.py::test_three
    ----------------- live log setup ------------------
    INFO     root:conftest.py:32 module trigger
    PASSED                                      [ 75%]
    tests/test_module2.py::test_four PASSED     [100%]
    ```

* Session
    
    And we do the same for sessions:

    In `tests/test_session.py`:
    ```python
    import pytest


    @pytest.mark.session
    def test_one(session_fixture):
        assert session_fixture


    @pytest.mark.session
    def test_two(session_fixture):
        assert session_fixture

    ```

    In `tests/test_session2.py`:
    ```python
    import pytest


    @pytest.mark.session
    def test_three(session_fixture):
        assert session_fixture


    @pytest.mark.session
    def test_four(session_fixture):
        assert session_fixture
    ```

    Run with `pytest -m session`

    Output:

    ```bash
    tests/test_session.py::test_one
    ----------------- live log setup ------------------
    INFO     root:conftest.py:38 session trigger
    PASSED                                      [ 25%]
    tests/test_session.py::test_two PASSED      [ 50%]
    tests/test_session2.py::test_three PASSED   [ 75%]
    tests/test_session2.py::test_four PASSED    [100%]
    ```

Notice that:

* Fixture with scope `class` are triggered for each `TestClass`
* Fixture with scope `modules` are triggered twice, for each script `test_module` and `test_module2`
* Fixture with scope `sessions` is triggered once only, despite having two modules.

### Adding Autouse

Autouse is when you want to trigger a fixture despite circumstances. This is useful when you know your multiple of your tests uses a particular fixture. 

But first, lets observe the behaviour of what it does:

If we go to `tests/conftests.py` and edit the function trigger:

```python
## @pytest.fixture()
@pytest.fixture(autouse=True)
def function_fixture():
    logging.info("function trigger")
    return True
```

and run `pytest -m session`

```bash
tests/test_session.py::test_one
--------------------- live log setup ---------------------
INFO     root:conftest.py:39 session trigger
INFO     root:conftest.py:21 function trigger
PASSED                                             [ 25%]
tests/test_session.py::test_two
--------------------- live log setup ---------------------
INFO     root:conftest.py:21 function trigger
PASSED                                             [ 50%]
tests/test_session2.py::test_three
--------------------- live log setup ---------------------
INFO     root:conftest.py:21 function trigger
PASSED                                             [ 75%]
tests/test_session2.py::test_four
--------------------- live log setup ---------------------
INFO     root:conftest.py:21 function trigger
PASSED                                             [100%]
```

The session fixture is triggered once, while the function fixture is triggered four times, despite not being used.


### Autouse usecases

Why or when is `autouse` useful then?

Quoting from the [Real Python](https://realpython.com/pytest-python-testing#fixtures-managing-state-and-dependencies):

> Another interesting use case for fixtures is in guarding access to resources. Imagine that you’ve written a test suite for code that deals with API calls. You want to ensure that the test suite doesn’t make any real network calls, even if a test accidentally executes the real network call code. pytest provides a monkeypatch fixture to replace values and behaviors, which you can use to great effect:

```python
import pytest
import requests

@pytest.fixture(autouse=True)
def disable_network_calls(monkeypatch):
    def stunted_get():
        raise RuntimeError("Network access not allowed during testing!")
    monkeypatch.setattr(requests, "get", lambda *args, **kwargs: stunted_get()
```


## Order of scopes

Now, if you are going to use the `scope` parameter, it is important to know the order of scopes is being executed. Generally it follows from the highest order to the lowest:

$$Session \rightarrow Package \rightarrow Module \rightarrow Class \rightarrow Function $$

To illustrate, create a file `tests/test_all.py`

```python
import pytest
import logging


@pytest.fixture(scope="function")
def function():
    logging.info("scope: function")


@pytest.fixture(scope="class")
def class_():
    logging.info("scope: class")


@pytest.fixture(scope="module")
def module():
    logging.info("scope: module")


@pytest.fixture(scope="package")
def package():
    logging.info("scope: package")


@pytest.fixture(scope="session")
def session():
    logging.info("scope: session")


def test_order(module, class_, session, function, package):
    assert True
```

and run with `pytest tests/test_all.py`:

```bash
tests/test_all.py::test_order
--------------------- live log setup ---------------------
INFO     root:test_all.py:27 scope: session
INFO     root:test_all.py:22 scope: package
INFO     root:test_all.py:17 scope: module
INFO     root:test_all.py:12 scope: class
INFO     root:conftest.py:21 function trigger
INFO     root:test_all.py:7 scope: function
PASSED                                             [100%]
```

If we add `autouse` fixture for each of the scopes, it will still obey the scope ordering: 

```bash
tests/test_all_autouse.py::test_order
------------------------ live log setup ------------------------
INFO     root:test_all_autouse.py:47 scope: session autouse
INFO     root:test_all_autouse.py:52 scope: session
INFO     root:test_all_autouse.py:37 scope: package autouse
INFO     root:test_all_autouse.py:42 scope: package
INFO     root:test_all_autouse.py:27 scope: module autouse
INFO     root:test_all_autouse.py:32 scope: module
INFO     root:test_all_autouse.py:17 scope: class autouse
INFO     root:test_all_autouse.py:22 scope: class
INFO     root:test_all_autouse.py:7 scope: function autouse
INFO     root:test_all_autouse.py:12 scope: function
PASSED                                                   [100%]
```

## References 

* Conftests
    * [Official docs - sharing fixtures across files](https://docs.pytest.org/en/6.2.x/fixture.html#conftest-py-sharing-fixtures-across-multiple-files)
* Marking
    * [Official docs - custom markers on pytest](https://docs.pytest.org/en/6.2.x/example/markers.html)
* Configuration
    * [Official docs - Configure your pytest env](https://docs.pytest.org/en/6.2.x/customize.html)
    * [Official docs - pytest logging](https://docs.pytest.org/en/6.2.x/logging.html)
    * [Stackoverflow - Configure pytest logging](https://stackoverflow.com/questions/4673373/logging-within-pytest-tests)
    * [Realpython - marking tests](https://realpython.com/pytest-python-testing/#marks-categorizing-tests)
* Fixtures with yield
    * [Official docs - Yield fixtures](https://docs.pytest.org/en/6.2.x/fixture.html#teardown-cleanup-aka-fixture-finalization)
    * [Stackoverflow- - How to setup and teardown a databas with pytest](https://stackoverflow.com/questions/45703591/how-to-send-post-data-to-flask-using-pytest-flask)
    * [Using pytest fixtures with testing flask app](https://testdriven.io/blog/flask-pytest/#fixtures)
* Scope & Autouse
    * [Understand fixture scopes](https://betterprogramming.pub/understand-5-scopes-of-pytest-fixtures-1b607b5c19ed)
    * [Realpython - Fixtures at scale](https://realpython.com/pytest-python-testing/#fixtures-managing-state-and-dependencies)
