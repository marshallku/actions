# Reusable GitHub Actions and Workflows

This repository contains a collection of reusable GitHub Actions and Workflows designed to streamline and automate various aspects of your development and deployment processes.

## Actions / Workflows

- **send-notification**: A workflow to send notifications to a Discord channel.
- **check-spelling**: An action to check the spelling in your project's documentation or code.
- **create-tag-release**: An action to create tag and release.
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
jobs:
  notify:
    needs: [build]
    if: ${{ failure() }}
    uses: marshallku/actions/.github/workflows/send-notification.yml@master
    with:
      failed: ${{ contains(join(needs.*.result, ','), 'failure') }}
      message: 'Deployment successful'
    secrets:
      url: ${{ secrets.DISCORD_WEBHOOK_URL }}
```

#### check-spelling

This action checks for spelling errors in your project.

**Example usage:**

```yml
steps:
  - uses: actions/checkout@v4
  - uses: marshallku/actions/check-spelling@master
```

#### check-version

This action checks for version updates in the package.json file.

**Outputs:**

- `version`: Current version in the package.json file; it remains **empty** if no updates have occurred.

**Example usage:**

```yml
check-version:
    runs-on: ubuntu-latest
    steps:
        - uses: marshallku/actions/check-version@master
          id: check-version
        - run: echo "Version updated to ${VERSION}"
          env:
                VERSION: ${{ steps.check-version.outputs.version }}
          if: ${{ steps.check-version.outputs.version != '' }}
```

#### create-tag-release

Creates tag and release with given tag name.

```yml
steps:
    - uses: marshallku/actions/create-tag-release@master
      if: ${{ steps.check-version.outputs.version != '' }}
      with:
        tag: ${{ steps.check-version.outputs.version }}
```

**Inputs:**

- `tag`: Name of tag you want to create

**Outputs:**

- `tag-exists`: Whether tag exists

#### setup-pnpm

Sets up `pnpm` in your workflow and installs dependencies.

```yml
steps:
  - uses: actions/checkout@v4
  - uses: marshallku/actions/setup-pnpm@master
```

**Inputs:**

- `node-version`: Node.js version to use (Optional)
- `npm-registry`: NPM registry to use (Optional)
