# Simple Forge GitHub Actions

[![GitHub Release](https://img.shields.io/github/release/simple-container-com/forge-action.svg)](https://github.com/simple-container-com/forge-action/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Execute Claude-powered code generation workflows for GitHub issues with Simple Forge. This repository provides two GitHub Actions that integrate with the Simple Forge service to automate code generation, issue processing, and workflow orchestration.

## 🚀 Quick Start

### Docker Action (Recommended)

```yaml
- name: Run Simple Forge
  uses: simple-container-com/forge-action/.github/actions@v1
  with:
    job_id: ${{ inputs.job_id }}
    issue_id: ${{ inputs.issue_id }}
    service_url: 'https://forge.simple-container.com'
    model_name: 'claude-sonnet-4-5'
    branch: ${{ inputs.branch }}
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    simple_forge_api_key: ${{ secrets.SIMPLE_FORGE_API_KEY }}
    github_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
```

### Dockerless Action (For Docker-restricted environments)

```yaml
- name: Run Simple Forge (Dockerless)
  uses: simple-container-com/forge-action/.github/actions/dockerless@v1
  with:
    job_id: ${{ inputs.job_id }}
    issue_id: ${{ inputs.issue_id }}
    service_url: 'https://forge.simple-container.com'
    branch: ${{ inputs.branch }}
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    simple_forge_api_key: ${{ secrets.SIMPLE_FORGE_API_KEY }}
    github_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
    script_version: 'latest'
```

## 📋 Actions Overview

This repository provides two GitHub Actions:

| Action                | Path          | Use Case                         | Requirements                 |
|-----------------------|---------------|----------------------------------|------------------------------|
| **Docker Action**     | `/`           | Production use, faster execution | Docker support               |
| **Dockerless Action** | `/dockerless` | Docker-restricted environments   | Docker for script extraction |

## 🔧 Action Specifications

### Docker Action (`action.yml`)

The main action that runs in a pre-built Docker container with all dependencies included.

#### Inputs

| Input                  | Description                                        | Required | Default                              |
|------------------------|----------------------------------------------------|----------|--------------------------------------|
| `job_id`               | Job ID from the Simple Forge queue                 | ✅        | -                                    |
| `issue_id`             | GitHub issue ID to process                         | ✅        | -                                    |
| `service_url`          | Simple Forge service URL                           | ❌        | `https://forge.simple-container.com` |
| `model_name`           | Claude model to use for generation                 | ❌        | `claude-sonnet-4-5`                  |
| `branch`               | Target branch for changes                          | ✅        | -                                    |
| `anthropic_api_key`    | Anthropic API key for Claude                       | ✅        | -                                    |
| `simple_forge_api_key` | Simple Forge API key                               | ✅        | -                                    |
| `github_token`         | GitHub Personal Access Token for repository access | ✅        | -                                    |

#### Outputs

| Output         | Description                    |
|----------------|--------------------------------|
| `status`       | Workflow execution status      |
| `branch`       | Branch where changes were made |
| `workflow_url` | URL to the workflow run        |

### Dockerless Action (`dockerless/action.yml`)

A composite action that runs without Docker containers, extracting scripts from the Docker image at runtime.

#### Inputs

| Input                     | Description                                        | Required | Default                              |
|---------------------------|----------------------------------------------------|----------|--------------------------------------|
| `job_id`                  | Job ID from the Simple Forge queue                 | ✅        | -                                    |
| `issue_id`                | GitHub issue ID to process                         | ✅        | -                                    |
| `service_url`             | Simple Forge service URL                           | ❌        | `https://forge.simple-container.com` |
| `branch`                  | Target branch for changes                          | ✅        | -                                    |
| `anthropic_api_key`       | Anthropic API key for Claude                       | ✅        | -                                    |
| `simple_forge_api_key`    | Simple Forge API key                               | ✅        | -                                    |
| `github_token`            | GitHub Personal Access Token for repository access | ✅        | -                                    |
| `script_version`          | Version of scripts to use                          | ❌        | `latest`                             |
| `skip_dependency_install` | Skip automatic dependency installation             | ❌        | `false`                              |

#### Outputs

| Output         | Description                    |
|----------------|--------------------------------|
| `status`       | Workflow execution status      |
| `branch`       | Branch where changes were made |
| `workflow_url` | URL to the workflow run        |

## 📖 Complete Workflow Examples

### Basic Workflow with Docker Action

```yaml
name: Simple Forge Workflow
on:
  workflow_dispatch:
    inputs:
      job_id:
        description: 'Job ID from the queue'
        required: true
        type: string
      issue_id:
        description: 'GitHub issue ID'
        required: true
        type: string
      branch:
        description: 'Target branch for changes'
        required: true
        type: string

jobs:
  generate-code:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    
    steps:
    - name: Run Simple Forge
      uses: simple-container-com/forge-action/.github/actions@v1
      with:
        job_id: ${{ inputs.job_id }}
        issue_id: ${{ inputs.issue_id }}
        service_url: 'https://forge.simple-container.com'
        model_name: 'claude-sonnet-4-5'
        branch: ${{ inputs.branch }}
        anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
        simple_forge_api_key: ${{ secrets.SIMPLE_FORGE_API_KEY }}
        github_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
```

### Advanced Workflow with Dockerless Action

```yaml
name: Simple Forge Workflow (Dockerless)
on:
  workflow_dispatch:
    inputs:
      job_id:
        description: 'Job ID from the queue'
        required: true
        type: string
      issue_id:
        description: 'GitHub issue ID'
        required: true
        type: string
      branch:
        description: 'Target branch for changes'
        required: true
        type: string
      script_version:
        description: 'Script version to use'
        required: false
        type: string
        default: 'latest'

jobs:
  generate-code:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      with:
        token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
        fetch-depth: 0
        
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '22'
        
    - name: Setup Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.22'
        
    - name: Run Simple Forge (Dockerless)
      uses: simple-container-com/forge-action/.github/actions/dockerless@v1
      with:
        job_id: ${{ inputs.job_id }}
        issue_id: ${{ inputs.issue_id }}
        service_url: 'https://forge.simple-container.com'
        branch: ${{ inputs.branch }}
        anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
        simple_forge_api_key: ${{ secrets.SIMPLE_FORGE_API_KEY }}
        github_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
        script_version: ${{ inputs.script_version }}
        skip_dependency_install: 'false'
```

## 🔐 Required Secrets

Configure these secrets in your repository settings:

| Secret                  | Description                                         | Required For |
|-------------------------|-----------------------------------------------------|--------------|
| `ANTHROPIC_API_KEY`     | Your Anthropic API key for Claude access            | Both actions |
| `SIMPLE_FORGE_API_KEY`  | Your Simple Forge service API key                   | Both actions |
| `PERSONAL_ACCESS_TOKEN` | GitHub Personal Access Token with repository access | Both actions |

### Setting up Secrets

1. Go to your repository **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add each required secret with the appropriate value

## 🛠️ Setup Requirements

### For Docker Action
- GitHub Actions runner with Docker support
- No additional setup required

### For Dockerless Action
- GitHub Actions runner (any)
- Docker available for script extraction (temporary)
- Node.js and Go setup (if not using `skip_dependency_install`)

## 🎯 Use Cases

### When to Use Docker Action
- ✅ Production environments
- ✅ Faster execution (pre-built container)
- ✅ Consistent environment
- ✅ Minimal setup required

### When to Use Dockerless Action
- ✅ Docker-restricted environments
- ✅ Custom dependency management
- ✅ Debugging and development
- ✅ Environments with Docker limitations

## 🔄 Workflow Process

Both actions follow the same workflow process:

1. **Environment Setup** - Configure workspace and dependencies
2. **Branch Management** - Create or switch to target branch
3. **Context Fetching** - Retrieve job context from Simple Forge service
4. **Claude Setup** - Initialize Claude CLI and plugins
5. **Code Generation** - Execute Claude-powered code generation
6. **Response Processing** - Process and validate generated code
7. **Change Commitment** - Commit and push changes to repository
8. **Status Reporting** - Report completion status to Simple Forge service

## 📊 Monitoring and Debugging

### Action Outputs

Both actions provide structured outputs for monitoring:

```yaml
- name: Run Simple Forge
  id: forge
  uses: simple-container-com/forge-action/.github/actions@v1
  with:
    # ... inputs

- name: Check Results
  run: |
    echo "Status: ${{ steps.forge.outputs.status }}"
    echo "Branch: ${{ steps.forge.outputs.branch }}"
    echo "Workflow URL: ${{ steps.forge.outputs.workflow_url }}"
```

### Debug Mode

Enable debug logging by setting the `ACTIONS_STEP_DEBUG` secret to `true` in your repository.

## 🚨 Troubleshooting

### Common Issues

#### Authentication Errors
```
Error: API authentication failed
```
**Solution**: Verify your `SIMPLE_FORGE_API_KEY` and `ANTHROPIC_API_KEY` secrets are correctly set.

#### Branch Creation Failures
```
Error: Failed to create branch
```
**Solution**: Ensure your `PERSONAL_ACCESS_TOKEN` has sufficient permissions for the repository.

#### Docker Pull Failures (Dockerless Action)
```
Error: Failed to pull Docker image
```
**Solution**: Check Docker availability and network connectivity on the runner.

#### Script Extraction Failures (Dockerless Action)
```
Error: Critical scripts are missing
```
**Solution**: Verify the Docker image version and ensure script extraction completed successfully.

### Getting Help

1. Check the [workflow run logs](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/using-workflow-run-logs) for detailed error information
2. Verify all required secrets are properly configured
3. Ensure your Simple Forge service is accessible and responsive
4. Review the [Simple Forge documentation](https://docs.simple-container.com) for service-specific issues

## 🔗 Related Resources

- [Simple Forge Service Documentation](https://docs.simple-container.com)
- [Anthropic Claude API Documentation](https://docs.anthropic.com)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

---

**Simple Forge** - Automate your code generation workflows with Claude AI
