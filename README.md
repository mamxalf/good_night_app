# Good Night App

Pre-Commit Hooks Configuration

```
#!/bin/sh

echo "Running pre-commit hooks..."

# Store the current Git branch
current_branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3)

# Store currently staged files
staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep ".rb$")

if [ "$staged_files" = "" ]; then
  echo "No Ruby files to check."
  exit 0
fi

echo "Running RuboCop..."
bundle exec rubocop --force-exclusion $staged_files
if [ $? -ne 0 ]; then
  echo "RuboCop failed! Fix the issues before committing."
  exit 1
fi

echo "Running Brakeman security scan..."
bundle exec brakeman -q -w2
if [ $? -ne 0 ]; then
  echo "Brakeman found security issues! Please fix them before committing."
  exit 1
fi

echo "Running RSpec..."
bundle exec rspec
if [ $? -ne 0 ]; then
  echo "Tests failed! Fix the failing tests before committing."
  exit 1
fi

echo "All pre-commit hooks passed! ✨"
exit 0
```
