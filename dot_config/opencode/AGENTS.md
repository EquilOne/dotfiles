# AGENTS.md - OpenCode Repository Guidelines

This repository contains OpenCode CLI configuration and plugin setup. This file provides guidelines for agentic coding agents working in this repository.

## Project Structure

This is an OpenCode configuration repository (`~/.config/opencode`) that contains:
- OpenCode CLI configuration (`opencode.json`)
- Plugin dependencies (`package.json`)
- Node modules for OpenCode SDK and plugins

## Build/Lint/Test Commands

Since this is a configuration repository rather than a development project, there are no traditional build, lint, or test commands. The repository primarily uses:

- **Package Management**: Uses npm/pnpm for dependency management
- **Install Dependencies**: `npm install` or `pnpm install`
- **Update Dependencies**: `npm update` or `pnpm update`

No test framework is currently configured in this repository.

## Code Style Guidelines

### General Principles
- This is a configuration-first repository - minimal code should be added
- Configuration files should be kept simple and focused
- Follow JSON schema specifications for configuration files

### Configuration Files
- Use `opencode.json` for OpenCode CLI settings
- Follow the OpenCode configuration schema at `https://opencode.ai/config.json`
- Keep configuration minimal and focused on essential settings
- Theme should be set to "system" unless specifically required otherwise

### Package Management
- Use `package.json` for OpenCode plugin dependencies
- Pin dependency versions to ensure stability
- Only include necessary OpenCode-related dependencies
- Avoid adding unrelated development dependencies

### File Organization
- Keep configuration files at the root level
- Maintain clean separation between user config and generated files
- Don't modify files in `node_modules/` directory

### Naming Conventions
- Configuration files: kebab-case (e.g., `opencode.json`)
- Use descriptive but concise configuration keys
- Follow OpenCode documentation for specific field names

### Error Handling
- Configuration files should be valid JSON
- Use schema validation where available
- Provide meaningful error messages for configuration issues

## Working with OpenCode Plugins

When modifying plugin configurations:
1. Check the official OpenCode plugin documentation
2. Verify plugin compatibility with current OpenCode version
3. Test configuration changes with the OpenCode CLI
4. Keep plugin versions synchronized

## Security Considerations

- Never commit sensitive configuration data
- API keys and credentials should be managed through OpenCode's secure mechanisms
- Regular review of plugin dependencies for security updates

## Debugging Configuration Issues

When troubleshooting OpenCode configuration:
1. Validate JSON syntax of configuration files
2. Check plugin compatibility matrix
3. Verify OpenCode CLI version compatibility
4. Review OpenCode logs for configuration parsing errors

## Repository Maintenance

- Regularly update OpenCode plugin dependencies
- Test configuration changes with different OpenCode versions
- Keep configuration backups before major changes
- Document any custom configuration patterns

## Notes for Agents

- This is primarily a configuration repository, not a development project
- Most changes should be limited to configuration files
- Avoid adding source code files unless specifically required
- Test configuration changes with the actual OpenCode CLI before committing
- Consider the impact on OpenCode plugin ecosystem when making changes