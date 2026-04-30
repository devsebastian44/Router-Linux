# Contributing to Router-Linux

Thank you for your interest in contributing! This project follows professional standards to ensure high-quality, secure, and maintainable code.

## Workflow

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally.
3. **Create a branch** for your feature or fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Develop** your changes. Ensure you use the `--dry-run` mode for local testing if you don't have a dedicated lab environment.
5. **Lint and Test**:
   - Run `shellcheck` on your scripts.
   - Run `bash tests/syntax_check.sh`.
   - Run `bash src/setup.sh --dry-run` to verify logic.
6. **Commit** your changes using **Conventional Commits** (see below).
7. **Push** to your fork and **Open a Pull Request**.

## Commit Message Standards

We use [Conventional Commits](https://www.conventionalcommits.org/) for a clean and readable history:

- `feat:` for new features.
- `fix:` for bug fixes.
- `docs:` for documentation changes.
- `refactor:` for code changes that neither fix a bug nor add a feature.
- `test:` for adding missing tests or correcting existing tests.
- `ci:` for changes to CI configuration files and scripts.
- `security:` for security-related improvements.

Example:
`feat: add dry-run mode to setup script`

## Code Standards

- **Shell Scripting**: All scripts must be compatible with Bash 4+.
- **Modularity**: Use functions for logical blocks of code.
- **Safety**: Use `run_cmd` wrapper for any command that modifies the system to support `--dry-run`.
- **Naming**: Use clear, descriptive names for variables and functions (e.g., `obtener_adaptador_principal` instead of `get_if`).

## Ethical Guidelines

This project is for **educational and ethical cybersecurity purposes only**. Contributions that promote illegal activities or provide non-defensive tools will be rejected.
