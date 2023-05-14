---
title: Pytest Part 3 - Mocking
date: 2021-03-02 0000:00:00 +0800
categories: [Knowledge, Engineering]
tags: [engineering, testing, pytest, python]     # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---
# Introduction

When you are writing data applications or products, chances are:

* You might have a long complex feature engineering process or an expensive compute function,
* You might have external dependencies (fetching data or databases),
* You might trigger an event to an external service. 

In either of the above case, in order to test your code, you probably need to `mock` it! 

This will cover specifically on how to [mock](https://docs.python.org/3/library/unittest.mock.html) with pytest. 


# Pre-req

I assume the following prerequisites: 

* Python
* Terminal (cli)
* [Familiarity with pytest](../pytest)
    * Specifically you understand the section on [mocker](../pytest#mocking)

# Setup

This is the packages you need:

```txxt
pytest
pytest-mock
```

# Mock Object

When you install [pytest-mock](https://pypi.org/project/pytest-mock/), the `mock` object is made available for convenince. 

For the next few examples, we will be using `unittest.mock` to demostrate/explain what is the `mock` object about. 

> Unittest has been built into the Python standard library since version 2.1. You'll probably see it in commercial Python applications and open-source projects.

# Requests

Lets make a http get requests as follows with the [requests package](https://pypi.org/project/requests/):

```python
import requests

my_requests = requests
my_response = my_requests.get("http://www.google.com")
my_response.status_code
my_response.url

"""
200
'http://www.google.com/'
"""
```

# Intro to Mock

To better understnad the `Mock` object, lets change the above example instead:

```python
from unittest.mock import Mock

my_requests = Mock()
my_response = my_requests.get("http://www.google.com")
my_response.status_code
my_response.url

"""
<Mock name='mock.get().status_code' id='140261037785552'>
<Mock name='mock.get().url' id='140261037755920'>
"""

```

That is weird! It returns a mock object, let's investigate further: 

```python
type(my_response)

"""
unittest.mock.Mock
"""
```

## Mock Methods

What about the methods you can call on it?

```python
dir(my_requests)

"""
['assert_any_call',
 'assert_called',
 'assert_called_once',
 'assert_called_once_with',
 'assert_called_with',
 'assert_has_calls',
 'assert_not_called',
 'attach_mock',
 'call_args',
 'call_args_list',
 'call_count',
 'called',
 'configure_mock',
 'method_calls',
 'mock_add_spec',
 'mock_calls',
 'reset_mock',
 'return_value',
 'side_effect']
 """
```

Wow! Seems like alot to digest! :sob:

Fear not, we'll go through some of them in the sessions and quickly see how they are valid or be used for testing! 

# Assert(s) 

When you run `my_requests.get()` method, and later use the object 

```python
from unittest.mock import Mock

my_requests = Mock()
my_response = my_requests.get("http://www.google.com")
my_requests.get.assert_called() is None
my_requests.get.assert_called_with("http://www.google.com") is None

"""
True
True
"""
```

We have just verified that the object `my_requests` with `get` method has been called, and it was called with correct arguments!

* A simpler example:
    Compare the following and try it yourself without mocking

    ```python
    json = Mock()
    json.dumps("this should dumb to a normal string")
    json.dumps.assert_called() is None
    ```

# Call(s) 

What about the call(s) methods under the `Mock` object?

```python
from unittest.mock import Mock

my_requests = Mock()
my_requests.get("something random")
my_requests.get("http://www.google.com", params=dict(q="pytest"))

my_requests.get.call_count # 2
my_requests.get.called # True
my_requests.get.call_args
my_requests.get.call_args_list

"""
2
True
call('http://www.google.com', params={'q': 'pytest'})

[call('something random'),
 call('http://www.google.com', params={'q': 'pytest'})]
"""
```

Can you start to see why this will be useful inverifying that your functions will be called correctly? (Will be even more obvious later on)

# Return value

What if you want to mock some values from a function or a method?

Observe:

```python
from unittest.mock import Mock

my_requests = Mock()
my_requests.get.return_value = "some dumb website"
my_requests.get("any dumb website") == "some dumb website"
"""
True
"""
```

Suppose you want to use the `my_request.get` method and return an object with `status_code` and `url`, you can define a return value with a `Mock` object:

```python
from unittest.mock import Mock

my_requests = Mock()
my_requests.get.return_value = Mock(**dict(status_code=200, url="some dumb website"))
my_response = my_requests.get("any website of my liking")
my_response.status_code == 200 
my_response.url == "some dumb website"
"""
True
True
"""
```

# Side effect

This is a little harder to explain, but first consider this "non mocked" example:

```python
import requests

# https://gorest.co.in/
def get_random_info():
    r = requests.get("https://gorest.co.in/public/v1/posts")
    if r.status_code == 200:
        return r.json()
    return None

get_random_info()

"""
{'meta': {'pagination': {'total': 1298,
   'pages': 65,
   'page': 1,
   'limit': 20,
   ...
   ...

"""
```

Now, suppose we want to mock a `ConnectionError` because we have no access to internet (or any other reasons):

```python
from requests.exceptions import ConnectionError
from unittest.mock import Mock
import pytest

requests = Mock()

requests.get.side_effect = ConnectionError

def get_random_info():
    r = requests.get("https://gorest.co.in/public/v1/posts")
    if r.status_code == 200:
        return r.json()
    return None

with pytest.raises(ConnectionError) as error_info:
    print("code triggered")
    assert error_info == get_random_info()
"""
code triggered
"""
```

## Side effect as a generator

Another good use case about side effect is when a list is provided, it provides an `iter` object:

```python
from unittest.mock import Mock
a = Mock()
a.side_effect = [1, 2, 3]
a(), a(), a()
"""
(1,2,3)
"""
```

This becomes useful when you want to mock a flow with multiple requests:

```python
from unittest.mock import Mock
from requests.exceptions import Timeout
import pytest

requests = Mock()


def get_random_info():
    r = requests.get("https://gorest.co.in/public/v1/posts")
    if r.status_code == 200:
        return r.json()
    return r


requests.get.side_effect = [
    Timeout,
    Mock(**{"status_code": 200, "json.return_value": "something random"}),
]

with pytest.raises(Timeout) as error_info:
    print("code triggered")
    assert error_info == get_random_info()
assert get_random_info() == "something random"
assert requests.get.call_count == 2
```

## Extra notes about side effect

When side effect and return value are both specified, side effect will take pirority. [Extra information here](https://stackoverflow.com/questions/56191199/what-happens-when-a-python-mock-has-both-a-return-value-and-a-list-of-side-effec)

# Spec calls

When using python, it might be common to use objects (classes), and when using `Mocking` typos might happen, observe:

```py
class MyClassObject:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def compute_product(self):
        return self.x * self.y


example = MyClassObject(10, 20)
example.compute_product() == 200 # True
```

Suppose you want to test the method `compute_product` but misspelt it with `compute_roduct`, with mocking, the following would still work:

```python
example = Mock()
example.compute_roduct.return_value = 200
example.compute_roduct() == 200
```

To prevent this from happening, we can make use of the `spec` argument:

```python
example = Mock(spec=["compute_product"])
example.compute_roduct.return_value == 200
"""
# AttributeError: Mock object has no attribute 'compute_roduct'

"""
```

## Configure mock

Sometimes it might not be possible to input the return value or side effect, in that case we can use the `configure_mock` method:

```python
from unittest.mock import Mock
temp=Mock()
temp.configure_mock(side_effect=None)
```

# MagicMock

There are also other types of mock, such as `MagicMock` and the new upcoming `AsyncMock` if you are using python async features.

In terms of MagicMock, it comes with some additional methods, to see all the methods available, 

```python
from unittest.mock import MagicMock
something = MagicMock()
dir(something)
```

You will notice that there are additional methods like `len` and `__iter__`:

```python
from unittest.mock import MagicMock

magic_example = MagicMock()
len(magic_example)

# another example
magic_example = MagicMock()
magic_example.__iter__.return_value = ["a", "b", "c"]
len(list(magic_example)) 
"""
0
3
"""
```

But if you only use the vanilla mock method:

```python
example = Mock()
len(example)
"""
TypeError: object of type 'Mock' has no len()
"""
```

# Final illustration!

With all the above learnings, lets come up with some sort of an "end-to-end" testing.

We create two scripts, `example.py` and `test_example.py` 

In `example.py`:

```python
import logging
import time

logger = logging.getLogger()
logger.setLevel(logging.INFO)

db_con = dict(a=1, b=2, c=3)


def db_get_data(key):
    # or any complex function
    time.sleep(3)
    return db_con.get(key)


def compute_function(a, b):
    time.sleep(3)
    return dict(v1=a, v2=b, p=a * b)


def send_external(param1: str, param2: int):
    # some external service
    logging.info(param1)
    logging.info(param2)


def very_slow_call(key, multiply):
    value = db_get_data(key)
    send_external(key, multiply)
    output = compute_function(value, multiply)
    output2 = compute_function(value, multiply)
    return output.get("p") * output2.get("p")

```

Take some time to understand what this is trying to do, we have:

* A database function that retrieves some attribute based on the key provided (like a no-sql db)
* A "complicated" function that takes 3 seconds to run 
* Some "external" service that sends data to external parties with some logging features 
* And lastly a function that takes into account of the above 3 methods into one big method. 

Suppose we run:

```python
time_start = time.time()
very_slow_call("a", 10)
print(time.time() - time_start)
"""
INFO:root:a
INFO:root:10
9.006908655166626
"""
```

Notice that it takes 9 seconds!

## Testing it!

This is our `test_example.py`:

```python
import example as eg
import pytest


def test_og():
    output = eg.very_slow_call("b", 10)
    assert output == 400


def test_db_get_data(mocker):
    mocker.patch("example.db_get_data", return_value=123)
    output = eg.db_get_data("a")
    return output == 123


def test_very_slow_call(mocker):
    mocker.patch("example.db_get_data", return_value=10)
    mock_compute = mocker.patch(
        "example.compute_function", side_effect=[dict(p=999), dict(p=100)]
    )
    ext = mocker.patch("example.send_external", mocker.Mock())
    output = eg.very_slow_call("z", 100)
    assert ext.call_count == 1
    assert ext.call_with_args("z", 100)
    assert mock_compute.call_count == 2
    assert mock_compute.assert_called_with(10, 100) is None
    assert output == 999 * 100
```
Lets see what is going on:

* `test_og` is just the orginial function that we are going to test, it should print out two `INFO` statements as well as the final output is `400` because we first takes the the value of `b` which is `2` and multiplies by `10` yielding 20. product. After that `very_slow_call` takes the squared which gives us `(2*10)*(2*10) == 400` 
* `test_db_get_data` is testing the function which is suppose to take 3 seconds and return a value of 1, but since we `patch` it now, it is suppose to return 123 almost instantly.
  
The last function is a little complicated (maybe?), lets disgest it:

* First, the `db_get_data` function returns us a value of `10` irregardless of what `keys` we use. 
* Second, the `compute_function` returns a generator, that returns `999` and `100` the second time, so `output` is `999` while output2 will be `100`. 
* Third, the `send_external` is being patched with a `Mock` object. 

Now, we run the test:

```bash
pytest --log-cli-level=INFO --durations=3 -vv
```

* The `--duration=3` shows the 3 slowests tests 
* `-vv` for verbose
* and `--log-cli-level=INFO` to show the logs 

Output:

```bash
platform linux -- Python 3.7.6, pytest-6.2.4, py-1.10.0, pluggy-0.13.1 -- /opt/conda/bin/python
cachedir: .pytest_cache
rootdir: /workspaces/mock
plugins: mock-3.6.1
collected 3 items                                          

test_example.py::test_og 
---------------------- live log call -----------------------
INFO     root:example.py:23 a
INFO     root:example.py:24 10
PASSED                                               [ 33%]
test_example.py::test_db_get_data PASSED             [ 66%]
test_example.py::test_very_slow_call PASSED          [100%]

=================== slowest 3 durations ====================
9.00s call     test_example.py::test_og
0.00s call     test_example.py::test_very_slow_call
0.00s call     test_example.py::test_db_get_data
==================== 3 passed in 9.13s =====================
```

If we remove the `test_og` from our code, this is the output:

```bash
==================== test session starts =====================
platform linux -- Python 3.7.6, pytest-6.2.4, py-1.10.0, pluggy-0.13.1 -- /opt/conda/bin/python
cachedir: .pytest_cache
rootdir: /workspaces/mock
plugins: mock-3.6.1
collected 2 items                                            

test_example.py::test_db_get_data PASSED               [ 50%]
test_example.py::test_very_slow_call PASSED            [100%]

==================== slowest 3 durations =====================
0.00s call     test_example.py::test_very_slow_call
0.00s call     test_example.py::test_db_get_data
0.00s setup    test_example.py::test_db_get_data
===================== 2 passed in 0.08s ======================
```

Notice that in `send_external` there is no `INFO` logs being recorded, and the database did not a "direct" hit to it, isolating our dependencies. In addition, we also "skipped" our complicated functions! 

Neat, right?

# Future Notes

`Stub` and `Spy` and `Async` test features seems interesting too! Look out for future posts about it! :smile:.

# References 

* Documentations:
    * [Official docs - unittest mock docs](https://docs.python.org/3/library/unittest.mock.html)
    * [Official docs - Pytest-mock](https://pypi.org/project/pytest-mock/)
* Examples:
    * [Examples on mocking environment with patching](https://adamj.eu/tech/2020/10/13/how-to-mock-environment-variables-with-pytest/)
    * [Python Mocking 101](https://www.fugue.co/blog/2016-02-11-python-mocking-101)
    * [Mocking Functions Part I](https://medium.com/analytics-vidhya/mocking-in-python-with-pytest-mock-part-i-6203c8ad3606)
* RealPython tutorials:
    * [Getting started with testing in python](https://realpython.com/python-testing/)
    * [Python Mock Library](https://realpython.com/python-mock-library/)
* Others
    * [Stackoverflow - Mock vs MagicMock](https://stackoverflow.com/questions/17181687/mock-vs-magicmock)
    * [Where to patch?](https://docs.python.org/3/library/unittest.mock.html#where-to-patch)