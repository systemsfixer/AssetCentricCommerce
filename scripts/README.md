# Quick Commit Scripts

This directory contains automated scripts for quickly staging, committing, and pushing changes to the AssetCentricCommerce repository.

## Available Scripts

### Unix/Linux/macOS: `quick-commit.sh`
- **Location**: `scripts/quick-commit.sh`
- **Requirements**: Bash shell, Git
- **Executable**: Yes (automatically set)

### Windows: `quick-commit.bat`
- **Location**: `scripts/quick-commit.bat`
- **Requirements**: Windows Command Prompt, Git
- **Executable**: Yes (batch file)

## Usage

### With Commit Message
```bash
# Unix/Linux/macOS
./scripts/quick-commit.sh "Your commit message here"

# Windows
scripts\quick-commit.bat "Your commit message here"
```

### Interactive Mode (Prompt for Message)
```bash
# Unix/Linux/macOS
./scripts/quick-commit.sh

# Windows
scripts\quick-commit.bat
```

## What the Scripts Do

1. **Validation Checks**:
   - Verify you're in a git repository
   - Check repository name (AssetCentricCommerce or AssetCentricCommerce2)
   - Confirm current branch (warns if not on 'main')
   - Check for uncommitted changes

2. **Interactive Process**:
   - Show current git status
   - Get commit message (from parameter or prompt)
   - Confirm before proceeding
   - Display files to be committed

3. **Git Operations**:
   - Stage all changes (`git add .`)
   - Commit with provided message
   - Push to remote repository
   - Display success confirmation with commit hash

## Safety Features

- **Repository Validation**: Ensures you're in the correct project
- **Branch Warning**: Alerts if not on main branch (but allows override)
- **Change Detection**: Exits gracefully if no changes to commit
- **User Confirmation**: Requires explicit confirmation before pushing
- **Error Handling**: Stops execution on any git command failure

## Example Output

```
[INFO] Current git status:
M  force-app/main/default/classes/AssetProductController.cls
A  scripts/quick-commit.sh

[INFO] Commit message: 'Add quick commit automation scripts'

Proceed with staging, committing, and pushing? (Y/n): y

[INFO] Staging all changes...
[INFO] Files to be committed:
M       force-app/main/default/classes/AssetProductController.cls
A       scripts/quick-commit.sh

[INFO] Committing changes...
[INFO] Pushing to remote repository...
[SUCCESS] Successfully committed and pushed changes!
[SUCCESS] Commit: a1b2c3d - Add quick commit automation scripts
[INFO] Remote repository: https://github.com/systemsfixer/AssetCentricCommerce.git
```

## Error Scenarios

### Not in Git Repository
```
[ERROR] Not in a git repository!
```

### Wrong Repository
```
[WARNING] Repository name is 'SomeOtherRepo', expected 'AssetCentricCommerce' or 'AssetCentricCommerce2'
Continue anyway? (y/N):
```

### No Changes to Commit
```
[WARNING] No changes detected to commit
```

### Empty Commit Message
```
[ERROR] Commit message cannot be empty
```

## Integration with Development Workflow

These scripts are designed to streamline the development workflow:

1. **Make Changes**: Edit files in your IDE
2. **Quick Commit**: Run the script to stage, commit, and push
3. **Continue Development**: Repeat as needed

## Best Practices

- **Meaningful Messages**: Use descriptive commit messages
- **Frequent Commits**: Commit logical units of work
- **Review Changes**: Check the file list before confirming
- **Branch Awareness**: Be mindful of which branch you're on

## Troubleshooting

### Permission Denied (Unix/Linux/macOS)
If you get a permission denied error:
```bash
chmod +x scripts/quick-commit.sh
```

### Git Authentication Issues
Ensure you're authenticated with GitHub:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Remote Repository Issues
Verify your remote is set correctly:
```bash
git remote -v
```

## Customization

You can modify these scripts to:
- Change the target repository names
- Add additional validation checks
- Modify the commit message format
- Add pre-commit hooks
- Integrate with CI/CD pipelines

## Security Considerations

- Scripts only operate on the current repository
- No sensitive information is stored or transmitted
- User confirmation required before pushing
- All git operations use standard git commands

---

These scripts provide a fast, reliable way to commit changes while maintaining safety and visibility into what's being committed and pushed to the repository.
