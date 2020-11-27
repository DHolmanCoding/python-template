# Python Template

Python boilerplate to kickstart your projects in style!

# Initializing Pre-Commit Hooks

This repository uses pre-commit hooks in order to assist you in maintaining a uniform and idiomatic code style.
If this is your first time using pre-commit hooks you can install the framework [here](https://pre-commit.com/#installation).
Once pre-commit is installed, all you need to do is execute the following command from the repository root:
```
pre-commit install
```

If you want to execute the pre-commit hooks at a time other than during the actual git commit, you can run:
```
pre-commit run --all-files
```

# TODO

1. Add additional pre-commit hooks that could be useful to users
2. Add documentation for each feature to help new users navigate the template better
3. Consider PyLint or flake8 and their compatibility with Black
4. Make a selection of circleci or github actions or both and add/test this feature
