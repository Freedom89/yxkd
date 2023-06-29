---
title: Multiple Docker running with Docker Compose
date: 2021-01-12 0000:00:00 +0800
categories: [Knowledge, Engineering]
tags: [engineering, reproducibility, docker]     # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---

## Introduction

As a data scientist/analyst:

* You probably interact with databases to read/write data.
* Require/Prefer a local environment to work locally to quicky tests some functionality/ 
* Mocking something before deploying to production. 

This is where docker compose will come into play! By the end of this article, you should be able to deploy an ipython environment connected to a database (postgres) with docker. 

## Pre-req

As usual, the following prerequisites are assumed:

* [Docker](../docker)
* [Makefile](../makefile)
* Understanding of python
* Using the terminal

Extra notes - if you are using mac, `docker-compose` comes installed with `docker-desktop`. For other OS, please refer to the [installation instructions](https://docs.docker.com/compose/install/).

## Psql with Docker

We will run through the following steps:

* Generate a dummy csv with the iris dataset.
* Create Dockerfile with postgres
* Prepare the sql script to trigger when building the postgres image 
* Access the postgres 

After you are done with this section, you should have the following structure: 


```tree
.
├── Dockerfile-pg
├── Makefile
├── data
│   └── iris.csv
├── generate_iris.py
├── localpg.py
└── setup.sql

1 directory, 6 files
```

### Generate Dataset (csv)

We will use the [iris dataset](https://archive.ics.uci.edu/ml/datasets/iris) and we will download it via [sklearn datasets](https://scikit-learn.org/stable/datasets/toy_dataset.html). To do this, we first create a script named `generate_iris.py` with the following code:

```python
import numpy as np
import pandas as pd
from sklearn.datasets import load_iris

iris = load_iris()
##iris.keys()


df= pd.DataFrame(data= np.c_[iris['data'], iris['target']],
                columns= iris['feature_names'] + ['target'])

df['species'] = pd.Categorical.from_codes(iris.target, iris.target_names)
df.columns = ["sl","sw","pl","wl","target","species"]
df["id"] = df.index
df = df.drop(["target"],axis=1)
df.to_csv("data/iris.csv",index=False)
```

Then we:

* create a folder named `data`.
* run the python script to generate the csv dataset.

```bash
mkdir data 
python -B generate_iris.py
```

### Dockerfile

Next, we create a dockerfile named `Dockerfile-pg`, we first start with the FROM statement:

```Dockerfile
FROM postgres:alpine
```

### setup sql script

Under the [postgres documentation from docker](https://hub.docker.com/_/postgres/){target_blank}, if we want to load the sql script during run time, we need to create a sql script and put it in the `/docker-entrypoint-initdb.d` directory. 

Here is the official block from the docs: 

> If you would like to do additional initialization in an image derived from this one, add one or more `*.sql`, `*.sql.gz`, or `*.sh` scripts under /docker-entrypoint-initdb.d (creating the directory if necessary). After the entrypoint calls initdb to create the default postgres user and database, it will run any `*.sql` files, run any executable `*.sh` scripts, and source any non-executable `*.sh` scripts found in that directory to do further initialization before starting the service.
{: .prompt-info }

so, we first create our SQL script named `setup.sql`

```sql
--Note, u can set up multiple scripts ; run in alphabetical order
CREATE TABLE iris (
  sl NUMERIC,
  sw NUMERIC,
  pl NUMERIC,
  wl NUMERIC,
  species TEXT,
  id INT PRIMARY KEY
);
COPY iris FROM '/data/iris.csv' DELIMITER ',' CSV HEADER;
```

Special notes:

* You must import all columns in the csv file in order in setup.py
* The columns must also be in order. 

### Updating Dockerfile

Next we update `Dockerfile-pg` to reflect the required changes as well as exposing a port:

```Dockerfile
FROM postgres:alpine
COPY *.sql /docker-entrypoint-initdb.d/
ADD setup.sql /docker-entrypoint-initdb.d
EXPOSE 6666
```

### Running PSQL with Docker!

The following is my `Makefile` configuration:

```make
DOCKER_IMAGE_NAME=pgsql
CONTAINER_DB_NAME=mydb
build:
	docker build -t $(DOCKER_IMAGE_NAME) --file Dockerfile-pg .
normalrun: build
normalrun:
	docker run --rm --name $(CONTAINER_DB_NAME) \
	-v $(shell pwd)/data:/data \
	-e POSTGRES_PASSWORD=1234   \
	-e POSTGRES_DB=your_database \
	-p 6666:5432 $(DOCKER_IMAGE_NAME)
```

```bash
❯ make normalrun
docker build -t pgsql --file Dockerfile-pg .
Sending build context to Docker daemon  11.26kB
Step 1/4 : FROM postgres:alpine
....
....
docker run --rm --name mydb \
	-v /Users/yixiang.low/Desktop/learning/dr_dc/data:/data \
	-e POSTGRES_PASSWORD=1234   \
	-e POSTGRES_DB=your_database \
	-p 6666:5432 pgsql
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.
....
....
2021-07-31 16:54:40.674 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2021-07-31 16:54:40.680 UTC [50] LOG:  database system was shut down at 2021-07-31 16:54:40 UTC
2021-07-31 16:54:40.685 UTC [1] LOG:  database system is ready to accept connections

```

### Accessing from terminal

Open another terminal, add the following commands to makefile and run `make access_bash`:

```make
access_bash:
	docker exec -it $(CONTAINER_DB_NAME) bash
```

```bash
❯ make access_bash
docker exec -it mydb bash
bash-5.1#
```

To access postgres, 

```bash
bash-5.1# psql -U postgres -d your_database
psql (13.3)
Type "help" for help.

your_database=#
```

To show that your table is loaded: 

```bash
your_database=# \dt
        List of relations
 Schema | Name | Type  |  Owner
--------+------+-------+----------
 public | iris | table | postgres
(1 row)

your_database=# select count(*) from iris;
 count
-------
   150
(1 row)

your_database=# select species, count(1) from iris group by species;
  species   | count
------------+-------
 setosa     |    50
 virginica  |    50
 versicolor |    50
(3 rows)
```

### Direct access to psql 

That might still be a hassle to access the bash and running the database, instead we can directly cmd docker to do so for us: 


Add the following to `Makefile` and run it: 
```make
access_pg:
	docker exec -it $(CONTAINER_DB_NAME) psql -U postgres -d your_database
```

```bash
❯ make access_pg
docker exec -it mydb psql -U postgres -d your_database
psql (13.3)
Type "help" for help.
your_database=#
```

### Connect with Python

Install [psycopg2-binary](https://pypi.org/project/psycopg2-binary/) with pip and in your local ipython or via script run the following code:

```python
import psycopg2
conn = psycopg2.connect(host="0.0.0.0",port = 6666, database="your_database", user="postgres", password="1234")
cur = conn.cursor()
cur.execute("""SELECT * FROM iris limit 5""")
query_results = cur.fetchall()
print(query_results)
cur.close()
conn.close()
```

output:

```bash
❯ python localpg.py
[(Decimal('5.1'), Decimal('3.5'), Decimal('1.4'), Decimal('0.2'), 'setosa', 0), (Decimal('4.9'), Decimal('3.0'), Decimal('1.4'), Decimal('0.2'), 'setosa', 1), (Decimal('4.7'), Decimal('3.2'), Decimal('1.3'), Decimal('0.2'), 'setosa', 2), (Decimal('4.6'), Decimal('3.1'), Decimal('1.5'), Decimal('0.2'), 'setosa', 3), (Decimal('5.0'), Decimal('3.6'), Decimal('1.4'), Decimal('0.2'), 'setosa', 4)]
```

### Persist changes (TIY)

In the above examples, whenever you rebuild the images and re-run the containers, whatever data that is written into the postgres database will not persist. 

In certain cases, this might not be the desired behaviour you need, in that case you can sync the postgres volume with your local machine through the docker volume mount `/var/lib/postgresql/data`:

```make
syncrun: build
syncrun:
	docker run --rm --name $(CONTAINER_DB_NAME) \
	-v $(shell pwd)/tmp/pgdata:/var/lib/postgresql/data \
	-v $(shell pwd)/data:/data \
	-e POSTGRES_PASSWORD=1234 \
	-e POSTGRES_DB=your_database \
	-p 6666:5432 $(DOCKER_IMAGE_NAME)
```

```bash
make syncrun
```

In your directory you will see a new folder tmp and your directory will look like this:

```bash
.
├── Dockerfile-pg
├── Makefile
├── data
│   └── iris.csv
├── generate_iris.py
├── localpg.py
├── setup.sql
└── tmp
    └── pgdata
        ├── PG_VERSION
        ├── base
        ├── global
        ├── pg_commit_ts
        ├── pg_dynshmem
        ├── pg_hba.conf
        ├── pg_ident.conf
        ├── pg_logical
        ├── pg_multixact
        ├── pg_notify
        ├── pg_replslot
        ├── pg_serial
        ├── pg_snapshots
        ├── pg_stat
        ├── pg_stat_tmp
        ├── pg_subtrans
        ├── pg_tblspc
        ├── pg_twophase
        ├── pg_wal
        ├── pg_xact
        ├── postgresql.auto.conf
        ├── postgresql.conf
        ├── postmaster.opts
        └── postmaster.pid

20 directories, 13 files
```

Now the next time you run this command, docker postgres will detects that an existing postgres volume exists, it will **not** run the initialization. 

```bash
PostgreSQL Database directory appears to contain a database; Skipping initialization
```

(Note, I deleted the tmp folder afterwards!)

# Switching to Compose

We are now ready to proceed with our next steps:

* switching the dockerfile to docker-compose
* running the postgres db with docker-compose 

At the end of the section this should be your structure:

```bash
.
├── Dockerfile-pg
├── Makefile # edited
├── data
│   └── iris.csv
├── docker-compose.yml # new
├── generate_iris.py
├── localpg.py
└── setup.sql

1 directory, 7 files
```

When we are running with docker, this was the command in makefile:

```make
normalrun: build
normalrun:
	docker run --rm --name $(CONTAINER_DB_NAME) \
    -v $(shell pwd)/data:/data \
    -e POSTGRES_PASSWORD=1234   \
    -e POSTGRES_DB=your_database \
    -p 6666:5432 $(DOCKER_IMAGE_NAME)
```

To do the same with docker-compose, we create a file named `docker-compose.yml` (you can customize the file name as well):

```yml
version: '3.8'

services:

  db:
    build:
      context: .
      dockerfile: Dockerfile-pg
    container_name: mydb
    volumes:
      - ./data:/data
    ports:
      - 6666:5432
    environment:
      - POSTGRES_PASSWORD=1234
      - POSTGRES_DB=your_database
```

Notice the 1-1 mapping of 

* environment variables
* container name
* context/dokcerfile location
* volume mounts 

### Psql with compose

Now we do the exact same thing with docker, by adding these commands to makefile

```make
dc_build:
	docker-compose build
	
dc_up:
	docker-compose up

dc_down:
	docker-compose down

dc_up_build:
	docker-compose up -d --build
```

### The build step

This is the equivalent of docker build step previously by running `docker-compose build` :

```bash
❯ make dc_build
docker-compose build
Building db
Step 1/4 : FROM postgres:alpine
 ---> d3a70afcf848
Step 2/4 : COPY *.sql /docker-entrypoint-initdb.d/
 ---> 8c5216077e04
Step 3/4 : ADD setup.sql /docker-entrypoint-initdb.d
 ---> 89028eb02381
Step 4/4 : EXPOSE 6666
 ---> Running in dc0f2a146af3
Removing intermediate container dc0f2a146af3
 ---> 9a4d2f4931d5

Successfully built 9a4d2f4931d5
Successfully tagged dr_dc_db:latest
```

### The run step

Followed by the run step with `docker-compose up`: 

```bash
❯ make dc_up
docker-compose up
Creating network "dr_dc_default" with the default driver
Creating mydb ... done
Attaching to mydb
....
....
mydb  | 2021-07-31 18:49:21.245 UTC [50] LOG:  database system was shut down at 2021-07-31 18:49:21 UTC
mydb  | 2021-07-31 18:49:21.251 UTC [1] LOG:  database system is ready to accept connections
```

If we explore the docker containers running with docker ps:

```bash
❯ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                              NAMES
f22b5895471b        dr_dc_db            "docker-entrypoint.s…"   49 seconds ago      Up 48 seconds       6666/tcp, 0.0.0.0:6666->5432/tcp   mydb
```

We can then access the same container `mydb` with the same `make access_pg` command:

```bash
❯ make access_pg
docker exec -it mydb psql -U postgres -d your_database
psql (13.3)
Type "help" for help.

your_database=#
```

Finally to stop the run, we can use `docker-compose down`:

```bash
❯ docker-compose down
Stopping mydb ... done
Removing mydb ... done
Removing network dr_dc_default
```

## Compose commands

If you refer to the [documentation of docker-compose up](https://docs.docker.com/compose/reference/up/) you can run docker-compose in detach mode as well as combining build and run step together with `docker-compose up -d --build`:

```bash
❯ make dc_up_build
docker-compose up -d --build
Creating network "dr_dc_default" with the default driver
Building db
....
....
Successfully built 9a4d2f4931d5
Successfully tagged dr_dc_db:latest
Creating mydb ... done
```

You can verify that the containers are running with `docker ps` (this means your terminal is able to run the next commands). Similarily, stop the containers from running with `make dc_down`.

## Python with compose 

The next part of the section is to run our [docker](knowledge:docker) python example with docker compose instead.

I suggest you to give it a try without reading on! You might encounter two error / difficulty:

* exit with code 0 
* unsure how to access interactive mode in docker compose 

If so, jump to the [references section](#references)!

Structure:

```bash
    .
├── Dockerfile-pg
├── Dockerfile-py # new
├── Makefile # edited
├── data
│   └── iris.csv
├── docker-compose.yml # edited
├── generate_iris.py
├── localpg.py
├── requirements.txt # new
├── setup.sql
└── src

2 directories, 9 files
```

### Create Dockerfile-py

Similarly we create Dockerfile:

```Dockerfile
FROM continuumio/miniconda3:4.10.3
EXPOSE 8888

RUN apt-get update -y && apt-get install -y build-essential && apt-get install -y make \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $HOME/src

COPY requirements.txt $HOME/src
RUN pip install -r requirements.txt
```

as well as creating the directory `src`:

```bash
mkdir src
```

and `requirements.txt`:

```bash
numpy==1.19.2
pandas==1.1.3
jupyter==1.0.0
pytest==6.2.4
psycopg2-binary==2.9.1
```

Recall that if we were to build & run this with Docker, we will use the following command:

```bash
docker build -t py_docker --file Dockerfile-py .

docker run --rm -it -p 8888:8888 \
-v $(pwd)/src:/src \
--entrypoint bash \
py_docker
```

### Py with compose 

We now need to map each step of docker run to compose as follows:

```yml
version: '3.8'

services:

  py:
    build:
      context: .
      dockerfile: Dockerfile-py
    entrypoint: "/bin/bash"
    container_name: py
    ports:
      - 8888:8888
    volumes:
      - ./src:/src
    tty: true # docker run -t
    stdin_open: true # docker run -i
```

Notice the `tty` which corresponds to `-t` and `stdin_open` correspond to `-i` from docker run! 

### Running py with compose

We can now can run it with the same command `make dc_up_build`:

```bash
❯ make dc_up_build
docker-compose up -d --build
Creating network "dr_dc_default" with the default driver
Building py
....
....
Successfully built bb3a397d9d8a
Successfully tagged dr_dc_py:latest
Starting py ... done
```

Check that the `py` container exists with `docker ps`. 

To access the `py` container:

```bash
❯ docker exec -it py bash
(base) root@d7cc556e12e4:/src#
```

Or we can also do so with:

```bash
❯ docker-compose exec py bash
(base) root@d7cc556e12e4:/src#
```

Try running jupyter notebook:

```bash
jupyter notebook --ip 0.0.0.0 --port 8888 --no-browser --allow-root
```

output:

```bash

(base) root@d7cc556e12e4:/src# jupyter notebook --ip 0.0.0.0 --port 8888 --no-browser --allow-root

[I 20:06:53.036 NotebookApp] Writing notebook server cookie secret to /root/.local/share/jupyter/runtime/notebook_cookie_secret
[I 20:06:53.535 NotebookApp] Serving notebooks from local directory: /src
....
....
     or http://127.0.0.1:8888/?token=219c4e046902289455daf0b2f14b10de4616e36d5e22bc0c
```

### Linking PG and PY

We are now ready to combine both docker containers to run together, while communicating with each other.

Structure:

```bash
.
├── Dockerfile-pg
├── Dockerfile-py
├── Makefile # edited
├── data
│   └── iris.csv
├── docker-compose.yml # edited
├── generate_iris.py
├── localpg.py
├── requirements.txt
├── setup.sql
└── src
    └── run.py # new

2 directories, 10 files
```
        
### Combined Compose


We first combine the two yml files together while specifiying that the `py` service depends on the `db` service and `db` to expose port `5432` like so: 

```yml
version: '3.8'

services:

  py:
    build:
      context: .
      dockerfile: Dockerfile-py
    entrypoint: "/bin/bash"
    container_name: py
    ports:
      - 8888:8888
    volumes:
      - ./src:/src
    tty: true # docker run -t
    stdin_open: true # docker run -i
    depends_on: # new 
      - db # new
  db:
    build:
      context: .
      dockerfile: Dockerfile-pg
    container_name: mydb
    volumes:
      - ./data:/data
    expose:
      - 5432 # new
    environment:
      - POSTGRES_PASSWORD=1234
      - POSTGRES_DB=your_database
```

### Creating py script 

In the earlier example above when using local python, our `host` is `0.0.0.0` and `port = 6666`. However, since we are in docker compose is now within the same "network" environment, the `host` is `mydb` which is the container name and `port` will be `5432`! 

We create a new python script in the `src` folder named `run.py`: 

```python
import psycopg2

conn = psycopg2.connect(host="mydb",
	port = 5432, database="your_database",
	 user="postgres", password="1234")

cur = conn.cursor()

cur.execute("""SELECT count(*) FROM iris""")
query_results = cur.fetchall()
print(query_results)
cur.close()
conn.close()
```

### Accessing Compose

We are now ready to run our docker compose with multiple containers and we start by `make dc_up_build` to build the images and running it in detach mode:

```bash
❯ make dc_up_build
docker-compose up -d --build
Building db
...
Successfully tagged dr_dc_db:latest
Building py
...

Creating mydb ... done
Recreating py ... done
```

and we can check that it is successful with `docker ps`: 

```bash
> docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                    NAMES
5ac38e2ed1e6        dr_dc_py            "/bin/bash"              About a minute ago   Up About a minute   0.0.0.0:8888->8888/tcp   py
2daeb8230108        dr_dc_db            "docker-entrypoint.s…"   About a minute ago   Up About a minute   5432/tcp, 6666/tcp       mydb
```

### Compose access bash

Add the following to Makefile:

```make
dc_bash_run:
	  docker-compose run --rm py
```

Access bash as follows:

```bash
❯ docker-compose run --rm py
Creating dr_dc_py_run ... done
(base) root@dca091461d81:/src# ls
run.py
(base) root@dca091461d81:/src#
```

Followed by running the python script:

```bash
(base) root@dca091461d81:/src# python run.py
[(150,)]
```

Note, you can also launch jupyter notebook in bash! 

Type `exit` to get out of shell followed by `make dc_down`. 

```bash
❯ make dc_down
docker-compose down
Stopping py   ... done
Stopping mydb ... done
Removing py   ... done
Removing mydb ... done
Removing network dr_dc_default
```

### Compose run script

We can also run compose in one build + execute step, add this to Makefile:

```make
dc_py_run: dc_up_build
dc_py_run:
	sleep 5
	docker-compose exec py python run.py
```

The purpose of `sleep 5` is for the images to get synced up before triggering the python script. 

```bash
❯ make dc_py_run
docker-compose up -d --build
....
docker-compose exec py python run.py
[(150,)]
```

> :smile:
> Congrats! We have now mocked an end to end python workflow with a dummy database with docker compose!
{: .prompt-info }

## Vscode DevContainer

Similarity to the docker post on [remote development IDE](knowledge:docker#remotedevelopmentIDE) there is an equivalent for docker compose where you can develop in an IDE with a postgres db running in the background.

I created a `requirements-test.txt` in `/src` with the following as post installation:

```txt
black==19.10b0
flake8==3.8.3
pytest==5.4.3
pytest-mock==3.3.0
pylint==2.5.3
mypy==0.782
jupyter==1.0.0
ipykernel
```

### Devcontainer json

This is my json file for my `.devcontainer/devcontainer.json`:

```json
// For format details, see https://aka.ms/vscode-remote/devcontainer.json or this file's README at:
{
  "name": "Existing Dockerfile",
  // Sets the run context to one level up instead of the .devcontainer folder.
  "context": "..",
  // The optional 'workspaceFolder' property is the path VS Code should open by default when
  // connected. This is typically a volume mount in .devcontainer/docker-compose.yml
  "dockerComposeFile": "../docker-compose.yml",
  "workspaceFolder": "/",
  // Best to put this pythonpath to be same as your workspace
  "remoteEnv": { "PYTHONPATH": "/src" },
  // The 'service' property is the name of the service for the container that VS Code should
  // use. Update this value and .devcontainer/docker-compose.yml to the real service name.
  "service": "py",
  // Set *default* container specific settings.json values on container create.
  "settings": {
    "terminal.integrated.shell.linux": null,
    "python.pythonPath": "/opt/conda/bin/python",
    "python.testing.unittestEnabled": false,
    "python.testing.nosetestsEnabled": false,
    "python.testing.pytestEnabled": true,
    "python.testing.pytestArgs": ["."],
    "editor.formatOnSave": true,
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "editor.tabCompletion": "on",
    "python.sendSelectionToInteractiveWindow": true,
    "python.formatting.provider": "black",
    "workbench.colorTheme": "Default Dark+",
    "python.linting.mypyEnabled": true,
    "python.linting.flake8Args": ["--max-line-length=88"],
    "python.linting.pylintEnabled": true,
    "python.linting.pylintUseMinimalCheckers": false,
    "cSpell.enabled": true
  },
  // Add the IDs of extensions you want installed when the container is created.
  "extensions": [
    "ms-python.python",
    "ms-toolsai.jupyter",
    "VisualStudioExptTeam.vscodeintellicode",
    "njpwerner.autodocstring",
    "ms-python.vscode-pylance",
    "streetsidesoftware.code-spell-checker"
  ],
  // Use 'forwardPorts' to make a list of ports inside the container available locally.
  "forwardPorts": [8888],
  // "postCreateCommand": "apt-get update && apt-get install -y curl",
  "postCreateCommand": "pip install -r requirements-test.txt",
  // Uncomment to connect as a non-root user. See https://aka.ms/vscode-remote/containers/non-root.
  // "remoteUser": "vscode"
  "shutdownAction": "stopContainer"
}

```

There are a few key changes in arguments or things to take note, such as:

* `dockerComposeFile` - specify which dockerfile to use
* `remoteEnv` - you only can use `remoteEnv` and no longer `containerEnv`
* `service` - which docker container to use as the "front" layer in vscode
* `workspaceFolder` - which folder to mount in vscode. Make sure that the workspaceFolder is also specified as a volume in your docker compose file!!

For more information please refer to the [advance container section](#vscode).

### Vscode Structure

This is how the final structure should look like if you wish to use remote development with vscode:

```bash
.
├── .devcontainer
│   └── devcontainer.json
├── Dockerfile-pg
├── Dockerfile-py
├── Makefile
├── data
│   └── iris.csv
├── docker-compose.yml
├── generate_iris.py
├── localpg.py
├── requirements.txt
├── setup.sql
└── src
    ├── requirements-test.txt
    └── run.py

3 directories, 12 files
```

### Running it

The next steps is exactly the same with docker,

* Open command palette
* Select `Remote-Containers: Rebuild and Reopen in Container` 

Here is a screenshot to demostrate the capability as well as the layout:

![image](../../../assets/posts/docker/vscode-compose.png)

## References

### Official documentation

* [Overview of docker compose](https://docs.docker.com/compose/)
* [Compose file version 3 reference](https://docs.docker.com/compose/compose-file/compose-file-v3/)

### Other examples

* [Full stack data scientist - practical introduction to docker](https://medium.com/applied-data-science/the-full-stack-data-scientist-part-2-a-practical-introduction-to-docker-1ea932c89b57)
* [Import csv into docker-postgres](https://sherryhsu.medium.com/how-to-import-csv-into-docker-postgresql-database-22d56e2a1117)

### Interactive compose

* [Stackoverflow - exited with code 0](https://stackoverflow.com/questions/44884719/exited-with-code-0-docker)
* [Stackoverflow - Interactive shell with docker compose](https://stackoverflow.com/questions/36249744/interactive-shell-using-docker-compose)

### Compose up options

* [Docker compose up documentation](https://docs.docker.com/compose/reference/up/)
* [Stackoverflow - Comparision with various docker-compose up steps](https://stackoverflow.com/questions/39988844/docker-compose-up-vs-docker-compose-up-build-vs-docker-compose-build-no-cach)

### Initialize postgressql with docker

* [Multiple sql init script with docker postgres](https://gist.github.com/onjin/2dd3cc52ef79069de1faa2dfd456c945)
* [Docker hub postgres documentation](https://hub.docker.com/_/postgres)
* [Different methods to load testdata to PostgresSQL](https://gitlab.com/tangram-vision-oss/tangram-visions-blog/-/tree/main/2021.04.28_LoadingTestDataIntoPostgreSQL)


### Vscode

* [Remote development with docker compose](https://code.visualstudio.com/docs/remote/create-dev-container#_use-docker-compose)
* [Advance container configuration](https://code.visualstudio.com/docs/remote/containers-advanced)