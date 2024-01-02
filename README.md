# Reusable GitHub Actions and Workflows

This repository contains a collection of reusable GitHub Actions and Workflows designed to streamline and automate various aspects of your development and deployment processes.

## Actions / Workflows

- **send-notification**: A workflow to send notifications to a Discord channel.
- **check-spelling**: An action to check the spelling in your project's documentation or code.
- **setup-pnpm**: An action for setting up `pnpm` and installing dependencies in your GitHub Actions workflow.

### Usage

#### send-notification

This workflow sends a notification to a specified Discord channel when triggered.

**Inputs:**

- `succeed`: Boolean indicating the status of the job.
- `message`: Custom message to be sent. (Optional)
- `color`: Color of the notification embed. (Optional)

**Secrets:**

- `url`: The Discord webhook URL.

**Example usage:**

```yml
# In your .github/workflows file
jobs:
  notify:
    needs: [build]
    if: ${{ failure() }}
    uses: marshallku/actions/.github/workflows/send-notification.yml@master
    with:
      succeed: ${{ contains(join(needs.*.result, ','), 'false') }}
      message: 'Deployment successful'
    secrets:
      url: ${{ secrets.DISCORD_WEBHOOK_URL }}
```

#### check-spelling

This action checks for spelling errors in your project.

**Example usage:**

```yml
# In your .github/workflows file
steps:
  - uses: actions/checkout@v4
  - uses: marshallku/actions/check-spelling@master
```

#### setup-pnpm

Sets up `pnpm` in your workflow and installs dependencies.

```yml
# In your .github/workflows file
steps:
  - uses: actions/checkout@v4
  - uses: marshallku/actions/setup-pnpm@master
```

**Inputs:**

- `node-version`: Node.js version to use (Optional)
- `npm-registry`: NPM registry to use (Optional)
