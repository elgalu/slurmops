# Contributing code

Please read the [Code of Conduct](https://github.com/spulec/moto/blob/master/CODE_OF_CONDUCT.md), you
can expect to be treated with respect at all times when interacting with this project.

## Contributing Setup

Clone the project locally and simply run `curl -sL https://raw.github.com/elgalu/ensure/main/setup.sh | bash`

Then `source .venv/bin/activate`

If [contributor_setup](contributing/contributor_setup.sh) didn't work on your system you can do the setup
manually, step by step:

1. Clone the project locally
1. Install Docker, e.g. `curl -sSL https://get.docker.com/ | sh`
1. Install the corresponding [.python-version](./.python-version) using something
   like [pyenv](https://github.com/pyenv/pyenv)
1. Create a virtual environment named `.venv` with `python -m venv .venv`
1. Activate the virtual environment with `source .venv/bin/activate`
1. Install [poetry](https://poetry.eustace.io/docs/#installation)
1. Run `poetry install --no-root` (--no-root to install the dependencies only, not the project)
1. Install [invoke](https://www.pyinvoke.org/installing.html) with `pip install invoke`
1. Run `invoke setup`
1. Open the project, if possible, with Visual Studio Code: `code slurmops.code-workspace`

## Feature branches

This project uses [towncrier](https://github.com/twisted/towncrier) for CHANGELOG automation.
Start all your feature/bugs/other with:

```sh
towncrier create "initial_setup.add" # just an example feature name
#=> Created news fragment at .changelog.d/initial_setup.add
# Now edit the initial_setup.add file describing what you're doing.
# Then continue:
towncrier build --draft  # test first
towncrier build          # final
```

## Running the tests locally

Run `poetry run invoke tests`

## Running all checks (including tests)

Run `poetry run invoke hooks tests`

## Maintainers

Note the first version was bumped with `tbump init "0.0.0.1"`

### Creating a new version

If you want to bump the version locally, without creating a git tag use `tbump "0.0.0.1" --only-patch`

However the version bumping is currently automated in CI/CD via `tbump "0.0.0.1" --non-interactive`

### Build and publish the new version to PyPI

You'll need a PyPi account to release manually, see <https://pypi.org/project/slurmops>

Feel free to build the package for local testing via `poetry build` however package publishing is
currently automated in CI/CD via `poetry publish`