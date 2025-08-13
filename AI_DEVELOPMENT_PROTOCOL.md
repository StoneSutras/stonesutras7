# AI-Driven Development Protocol with Jules

This document outlines the protocol and guidelines for developing this project with the assistance of Jules, an AI software engineer. The goal is to establish a streamlined, AI-driven workflow that ensures high-quality code, thorough documentation, and efficient issue resolution.

## Core Principles

1.  **AI-First Development**: Jules is the primary developer for this project. Human developers should focus on high-level strategy, issue definition, and final review.
2.  **Thorough Documentation**: Every new feature, change, or bug fix must be accompanied by clear and comprehensive documentation. This includes in-code comments, detailed commit messages, and, where appropriate, updates to user-facing documentation.
3.  **Automated as a Goal**: The development process should be as automated as possible, from issue creation to final deployment.

## The AI Development Workflow

This workflow is designed to be iterative and collaborative, with clear roles for both Jules and human developers.

### 1. Issue Definition

All work begins with a well-defined issue. To ensure Jules can understand and address the issue effectively, every issue should include:

*   **A Clear, Descriptive Title**: Summarize the task or problem concisely.
*   **A Detailed Description**:
    *   Explain the "what" and "why" of the task.
    *   For bugs, include steps to reproduce, expected behavior, and actual behavior.
    *   For features, describe the new functionality from a user's perspective.
*   **Acceptance Criteria**: A checklist of what must be true for the issue to be considered "done."
*   **Relevant Resources**: Include links to any relevant documentation, screenshots, or specific files in the repository.

### 2. Assigning to Jules

Once an issue is created, it should be assigned to Jules. This can be done manually or, in the future, through automation (e.g., a GitHub Action that assigns issues with a specific label to Jules).

### 3. Planning

Upon receiving an issue, Jules will:
1.  **Explore the codebase** to understand the context of the request.
2.  **Formulate a step-by-step plan** to address the issue.
3.  **Present the plan for approval** using the `set_plan` tool.

Human developers should review the plan to ensure it is sound and aligns with the project's goals before giving approval.

### 4. Implementation

Once the plan is approved, Jules will begin implementation. This may involve:

*   Writing or modifying code.
*   Creating or updating files.
*   Running commands in the terminal (e.g., to install dependencies or run builds).

Jules will provide regular updates on its progress.

### 5. Documentation

Jules is responsible for documenting all changes. This includes:

*   **Code Comments**: Adding comments to new or complex code sections.
*   **Commit Messages**: Writing clear and descriptive commit messages that explain the "what" and "why" of the changes. The message should be git-agnostic.
*   **Updating Documentation**: If a change affects user-facing documentation (like a README or other guides), Jules will update it accordingly.

### 6. Testing

Quality assurance is critical. Jules will:

*   **Run existing tests** to ensure that no new changes have introduced regressions.
*   **Write new tests** for new features, where applicable.
*   **Debug any failing tests** until the entire test suite passes.

### 7. Code Review

Before submitting the final changes, Jules will use the `request_code_review()` tool to get an automated review of its work. This helps catch potential issues and ensures adherence to coding standards.

### 8. Submission and Human Review

After a successful code review, Jules will:
1.  **Submit the changes** with a descriptive title and a summary of the work done.
2.  **Request a final review from a human developer.**

The human developer's role is to perform a final check, ensuring the changes meet the project's standards and solve the issue effectively, and then merge the changes.

## The Human's Role

While Jules handles the bulk of the development work, human developers play a crucial role as:

*   **Strategists**: Defining the project roadmap, prioritizing features, and making high-level architectural decisions.
*   **Reviewers**: Ensuring the quality of Jules's work and providing feedback to improve its performance.
*   **Mentors**: Guiding Jules when it encounters complex problems or ambiguities.

## Automation Opportunities

To further streamline this process, we can explore automation for:

*   **Issue Assignment**: Automatically assign issues with a specific label (e.g., `jules-task`) to Jules.
*   **CI/CD Integration**: Integrate Jules into a Continuous Integration/Continuous Deployment pipeline to automate testing and deployment.
*   **Automated Issue Creation**: For certain types of predictable tasks or maintenance, scripts could be written to create issues automatically.

## Conclusion

By adhering to this protocol, we can create a powerful and efficient development process that leverages the strengths of both AI and human developers. This will allow us to build and maintain a high-quality, well-documented project.
