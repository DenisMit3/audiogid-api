# Contribution Guidelines

Thank you for considering contributing to the **audiogid-api** project! To make the contribution process smooth and efficient, please follow these guidelines:

## Setup Instructions
1. **Fork the Repository**: Start by forking the repository on GitHub.
2. **Clone the Repo**: Clone your fork to your local machine:
   ```bash
   git clone https://github.com/YourUsername/audiogid-api.git
   cd audiogid-api
   ```
3. **Install Dependencies**: Install the required dependencies. Usually, this can be done using:
   ```bash
   npm install
   ``` 
4. **Run the Development Server**: You can start the development server with:
   ```bash
   npm start
   ```

## Code Style
- Follow the coding standards set for this project. You can run linters to ensure compliance.
- Use **4 spaces** for indentation. No tabs.
- Write clean and maintainable code.

## Commit Message Format
When committing your changes, please use the following format:
```
<type>(<scope>): <subject>

<body>

<footer>
```
- **type**: feat, fix, docs, style, refactor, perf, test, chore
- **scope**: A noun describing a section of the codebase, e.g., component, API
- **subject**: A short description of the change (max 72 characters)

## Pull Request Process
1. **Open a Pull Request**: Once you have completed your changes, open a pull request against the `master` branch of the original repository.
2. **Describe Your Changes**: In the pull request description, explain what you have done and why.
3. **Review**: One of the maintainers will review your pull request.
4. **Make Changes if Requested**: Be prepared to make changes if requested by the maintainers.

## Testing Requirements
- Ensure that you have written sufficient tests for your code changes.
- Run the tests before submitting your pull request to verify that everything is working:
   ```bash
   npm test
   ```

Thank you for contributing! We appreciate your efforts to help improve this project!