---
title: Typed Python
date: 2021-03-01 0000:00:00 +0800
categories: [Knowledge, Engineering]
tags: [engineering, testing, pydantic, python]   # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---

## Problem Intro

As a (DS) data Scientist, 80% of our work is dealing with messy data. Our problems are not limited to:

* Database id being referenced as `_id` 
* Empty values can be referenced as `NA`, `None`, `"None"`, `"EMPTY"`...
* Data being passed to you during production requests are wrong

As a DS working with other DS, or as a en engineer working with DS,

* Reassigning a variable name multiple times. 
* Hard to track variables naming convention. 
* Code are usually contextual heavy (e.g why did the DS divide this number by that aggregation?)


Small Note: pylint/flake8 are also useful to address the above problems. 

##  Pre-req / Setup!



Assuming you are using [anaconda](https://www.anaconda.com/) distribution with mac/linux/docker etc,  


* `requirements.txt`
  
    ```text
    pydantic==1.7
    mypy==0.790
    jupyter==1.0.0
    ```

```bash
conda create -n typedpy python=3.8
conda activate typedpy
pip install -r requirements.txt
```

## Hello World!

Introducing Typed Python! Here is a simple example using native python and the [mypy package](https://pypi.org/project/mypy/). 

```python
def add(x:int, y:int) -> int:
    """[Simple addition function]

    Args:
        x ([int]): [An integer]
        y ([int]): [An integer]
    """
    return x+y

```

Suppose a DS decides to use this function for another purpose in a python script,

```python
add("hello, ", "how are you")
"""
output
hello,how are you'
"""
```

By using mypy in your terminal where the script exists: 

```bash
mypy typed_eg1.py
```

output:

```
typed_eg1.py:10: error: Argument 1 to "add" has incompatible type "str"; expected "int"
typed_eg1.py:10: error: Argument 2 to "add" has incompatible type "str"; expected "int"
Found 2 errors in 1 file (checked 1 source file)
```

However, the downside of this is the code still runs, and it does not warn the user of doing something unintended! 

## Pydantic

Introducing [Pydantic](https://pydantic-docs.helpmanual.io/)!

Everything starts with a `BaseModel`, like so:

```python
from pydantic import BaseModel 

class InputNumbers(BaseModel):
    """
    This is where the doc string usually goes
    """
    a:int
    b:int

mynumbers = InputNumbers(a=10,b=100)
```

And you can define your function as follows:

```python
def addition(input: InputNumbers) -> int:
    return input.a + input.b

input = InputNumbers(a=10,b=100)
input
# InputNumbers(a=10, b=100)

"""
Or you can use dictionary inputs
     - useful in handling json requests
"""
input_dict = dict(a=11,b=101)
input2 = InputNumbers(**input_dict)
input2
# InputNumbers(a=11,b=101)

addition(input)

```

Using the similar example, suppose the user tries to do string addition:

```python
InputNumbers(a='I am so stupid',b=100)

"""
ValidationError: 1 validation error for InputNumbers
a
  value is not a valid integer (type=type_error.integer)
"""
```

Or the user forgets to input certain values:

```python
InputNumbers(a=10) # b is missing

"""
ValidationError: 1 validation error for InputNumbers
b
  field required (type=value_error.missing)
"""
```

---

<span style='color:red'>__Warning!__</span> if python allows for the conversion, then pydantic _will not_ warn you. [Do note that this behavior is intended](https://pydantic-docs.helpmanual.io/usage/models/#data-conversion
)!

For example, in python it is acceptable to `str(1)` or `int("1")`

```python
class Example(BaseModel):
    a: int
    b: float
    c: int
    d: str

input_dict = dict(a=1.1, b=1.2, c='4', d=100)

Example(**input_dict)
"""
Example(a=1, b=1.2, c=4, d='100')
"""
```

### Autocomplete

Because we are using python classes and declaring types in the functions, it enables auto complete when developing the functions, speeding up your workflow! 

If you are using IDE,

  * in Pycharm you have a plugin specific for pydantic [here](https://plugins.jetbrains.com/plugin/12861-pydantic)

  * while for vscode, you can download the [python extension](https://github.com/Microsoft/vscode-python), along with the [pylance extension](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance). 
    * To read more:
      * [Pylance annoucement](https://devblogs.microsoft.com/python/announcing-pylance-fast-feature-rich-language-support-for-python-in-visual-studio-code/)
      * [Possible pydantic extension](https://github.com/microsoft/python-language-server/issues/1898)
  

### Outputs

You can also define outputs with pydantic:

```python
from pydantic import BaseModel


class ExampleIn(BaseModel):
    a: int
    b: int


class ExampleOut(BaseModel):
    addition: int
    multiplication: int
    division: float


def compute_features(input: ExampleIn) -> ExampleOut:
    add: int = input.a + input.b
    multi: int = input.a * input.b
    div: float = input.a / input.b
    return ExampleOut(addition=add, multiplication=multi, division=div)


In = ExampleIn(a=10,b=100)
compute_features(In)

"""
ExampleOut(addition=110, multiplication=1000, division=0.1)
"""
```

## Types

The [full list of types available can be found in the docs](https://pydantic-docs.helpmanual.io/usage/types/), I will go through the most commonly used in my experience. 

We will be making use of the [Typing library](https://docs.python.org/3/library/typing.html) for certain cases. The reason will be explained further [below](./#list-dict-any).

### Default Values

```python
from pydantic import BaseModel
from typing import Optional

class Example(BaseModel):
    required: int # no value specified
    default_val: str = 10
    optional_val: Optional[int]

Example(required=1)
# Example(required=1, default_val=10, optional_val=None)

Example(required=2,default_val=10)
# Example(required=2, default_val='10', optional_val=None)
```

### Optional Values

```python
from pydantic import BaseModel
from typing import Optional

class Example(BaseModel):
    required: int # no value specified
    default_val: str = 10
    optional_val: Optional[int]


Example(required=3,default_val=20,optional_val=100 )
# Example(required=3, default_val='20', optional_val=100)

```

### Union

```python

from pydantic import BaseModel
from typing import Optional

class Example(BaseModel):
    required: int # no value specified
    default_val: str = 10
    optional_val: Union[int,None]
    optiona_val2: Union[int,str,float]

```

Aside: `Optional` is actually `Union[..., None]`

### List, Dict, Any

* What if you want to use certain python structures?
* Unsure of what data type to use? 

```python
from typing import List, Dict, Any

# This will throw an error
var: list[float]

# this will not:
var: List[float]
var2: Dict[str, float]
var3: List[Any]
```

### Enum / IntEnum

You use `Enum` generally when you want a variable to take in a set of categorical values. 

```python
from enum import Enum, IntEnum

class Animal(str,Enum):
    DOG: str = 'DOG'
    CAT: str = 'CAT'


class Action(int,Enum):
    JUMP = 1
    SIT = 2 
    LIEDOWN = 3
    PAW = 4    
```

You can use these classes as follows:

```python
Animal.DOG
Animal.DOG.value
Animal["DOG"].value
```

## Complex Models

You can then define models/classes like this:

```python
from typing import List, Dict, Set
from pydantic import BaseModel
from enum import Enum, IntEnum


class Animal(str, Enum):
    DOG: str = "DOG"
    CAT: str = "CAT"


class Action(IntEnum):
    JUMP = 1
    SIT = 2
    LIEDOWN = 3
    PAW = 4


class Pet(BaseModel):
    category: Animal
    tricks: List[Action]


class Attributes(BaseModel):
    age: int
    country: str


class House(BaseModel):
    Pets: List[Pet]
    attributes: Attributes


pet1 = Pet(category=Animal.DOG, tricks=[Action.JUMP, Action.SIT])
pet2 = Pet(category=Animal.CAT, tricks=[Action.LIEDOWN, Action.PAW])
House(Pets=[pet1, pet2], attributes=dict(age=10, country="Singapore"))

"""
House(Pets=[Pet(category=<Animal.DOG: 'DOG'>, 
tricks=[<Action.JUMP: 1>, <Action.SIT: 2>]), 
Pet(category=<Animal.CAT: 'CAT'>, tricks=[<Action.LIEDOWN: 3>,
 <Action.PAW: 4>])], attributes=Attributes(age=10, country='Singapore'))
"""
```

## Validators

This section is largely similar to the [docs here](https://pydantic-docs.helpmanual.io/usage/validators/) and the documentation is pretty good. 

Instead, i will highlight some specific notes/details that is tend to be overlooked. 

In summary, this is what a typical validator looks like:

```python
from pydantic import BaseModel, validator
from datetime import datetime
from time import time


class Account(BaseModel):
    account_id: int
    date_join: datetime

    @validator("date_join")
    def time_must_be_before_today(cls, v):
        if v > datetime.now():
            raise ValueError("Are you from the future?")
        return v


Account(account_id=123, date_join=datetime(3000, 12, 1))


"""
ValidationError: 1 validation error for Account
date_join
  Are you from the future? (type=value_error)
"""
```

The way to go about understanding the validator declarator, is that it is a class method, and v represents the attribute `date_join` as specified above. 

__Also, at the validator, you can choose to edit the variable.__

Example:

```python
class Example(BaseModel):
    even_num: int

    @validator('even_num')
    def make_it_even(cls,v):
        if v % 2 == 0:
            return v
        else:
            return v+1

Example(even_num=51)
"""
Example(even_num=52)
"""
```

### Handling messy data

Now, suppose your upstream has messy data values, rather than defining a function,you can just let pydantic  do the job for you.

```python
class CleanData(BaseModel):
    value: str

    @validator("value")
    def change_all(cls,v):
        if v in ["empty","NA","NONE","EMPTY","INVALID"]:
            v = "not supplied"
        return v
```

This also allows for cleaner scripts and faster workflow. It also isolates the data cleaning in each step of the process. 

## Exporting

Sometimes you are expected to return the data in json format, and certain data types in python is not supported natively. 

For example:

```python
import json
json.dumps(set([1,2,3]))

"""
TypeError: Object of type set is not JSON serializable
"""

class SpecialSet(BaseModel):
    myset: set

example = SpecialSet(myset=set([1,2,3]))
example.json()
"""
'{"myset": [1, 2, 3]}'
"""
```

If you are returning in dictionary, with the earlier example:

```python

house = House(Pets=[pet1, pet2], attributes=dict(age=10, country="Singapore"))

house.dict()

"""
house.dict()
{'Pets': [{'category': <Animal.DOG: 'DOG'>,
   'tricks': [<Action.JUMP: 1>, <Action.SIT: 2>]},
  {'category': <Animal.CAT: 'CAT'>,
   'tricks': [<Action.LIEDOWN: 3>, <Action.PAW: 4>]}],
 'attributes': {'age': 10, 'country': 'Singapore'}}
"""

house.json()
"""
'{"Pets": [{"category": "DOG", "tricks": [1, 2]}, {"category": "CAT", "tricks": [3, 4]}], "attributes": {"age": 10, "country": "Singapore"}}'
"""
```

Note: full docs found [here](https://pydantic-docs.helpmanual.io/usage/exporting_models/). It is worth while taking a look and understand the other methods available, specifically the `exclude/include` methods. 

## Using Fields 

Sometimes, your upstream / downstream:

*  reference a schema with a different name,
*  or is prone to schema changes, 
*  or has a different perspective of CamelCase or snake_case. 

This is where [Field customisation](https://pydantic-docs.helpmanual.io/usage/schema/#field-customisation) becomes very useful. 

Here are two examples:

### Alias

```python
from pydantic import BaseModel, Field

class Example(BaseModel):
    booking_id: int = Field(..., alias="_id", description="This is the booking_id")


example = Example(_id=123)
"""
Example(booking_id=123)
"""
example.json()
"""
'{"booking_id": 123}'
"""
example.json(by_alias=True)
"""
'{"_id": 123}'
"""
```

By using alias, you are able have cleaner code as your application code will be independent of your inputs/outputs as per your requirements docs. 

## Alias Generators

Suppose you prefer snake_case, but your upstream sends in CamelCase,

```python
from pydantic import BaseModel


def to_camel(string: str) -> str:
    return ''.join(word.capitalize() for word in string.split('_'))


class Example(BaseModel):
    i_love_camel_case: str
    yes_i_really_do: str

    class Config:
        alias_generator = to_camel

eg = Example(ILoveCamelCase = "TRUE", YesIReallyDo ="YES, REALLY")        

```

[official docs here](https://pydantic-docs.helpmanual.io/usage/model_config/#alias-generator)

## Summary

We have seen that with pydantic classes:

* How you can code your application logic that is independent of your upstream/downstream by using alias.
* Different values can be imputed or values can be checked with validators
  * variables can also be adjusted within the pydantic class
* Validating data types are correct before proceeding 
* Objects are clean with clear attributes, being functions being statically typed with 0 ambiguous inputs and outputs. This will also make testing easier.
* Objects can be documented (versus typical code blocks that is usually done as an after thought) with the help of class doc strings and Fields descriptions. 

## Additional Readings

The below readings are useful / helped to better appreciate static typing. I recommend you to read them, first by skimming and then in details!

[Alternative guide by fastapi](https://fastapi.tiangolo.com/python-types/)

[Real python - why should you care about type hints?](https://realpython.com/lessons/pros-and-cons-type-hints/)

[Python type checking - guide](https://realpython.com/python-type-checking/)

[Introduction to pep8](https://realpython.com/python-pep8/)




