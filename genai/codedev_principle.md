# Code Development Design Principles

Generate code that follows these constraints and architectural principles. The goal is to produce modular, testable, and maintainable code.

## Requirements

### General Design Philosophy

- Follow idiomatic programming language patterns.
- Emphasize **low coupling** and **high cohesion** to clarify and control dependencies.
- Keep modules **composable** and **single-responsibility**.
- Clearly separate **I/O logic** (CLI, HTTP, file access) from **business logic**.
- Use **interfaces** (or language-equivalent abstraction mechanisms) to define clear boundaries between layers/modules.
- Interfaces should be **declarative**, describing "what" is done rather than "how".
- Avoid global state and implicit side-effects.
- Design with **constructor-based dependency injection** to make dependencies explicit.
- Keep each file/module single-responsibility and composable.
- Organize source code by responsibility (e.g., usecase, infra, cmd, domain, etc.) to encourage stability and modularity.
- Avoid tight coupling with third-party libraries, especially within business logic.

### Golang

- Use `context.Context` in all public-facing functions.
- Functions must return `(result, error)` or equivalent, with proper error wrapping.
- Prefer constructor functions for struct initialization (`NewXxx`)

## Testing

- Code must be fully testable at the unit and integration levels.
- Prefer **interface-based mocking** or stubbing for test isolation.
- Ensure minimal boilerplate for writing tests.
- Write **entry-point testable code**: design functions such that they can be invoked from `main` but are independently testable.
- Enable end-to-end verification via high-level entry functions that simulate real usage.

### Golang

- Design for easy use with `go test` and table-driven tests.

## Project Structure

- Follow modular design
- Avoid coupling CLI/input/output logic with business logic

### Golang

- Structure as usecase-driven design (e.g., cmd/, infra/, usecase/)

## Code Style

- Prefer standard library packages.
- Avoid third-party packages unless necessary anytime.
- Every function must include a top-level comment that clearly describes what the function does. This comment should be declarative, explaining the function's purpose and responsibility, not its implementation details.
- Do not include inline comments inside the function body if the logic is self-explanatory from the code itself. Only add inline comments when:
    - The logic is non-obvious or counterintuitive.
    - The code implements a workaround or external specification.
    - The reasoning behind a seemingly redundant operation needs clarification.
- Comments should support the reader's understanding of the "why", not repeat the "how" that is already evident in clean code.

