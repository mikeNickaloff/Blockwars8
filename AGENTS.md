# ADDITIONAL AGENT INSTRUCTIONS

## PLAN.md
- Maintain a PLAN.md file at the repository root as the authoritative record of work plans before any coding begins.
- Every planned change must be documented in PLAN.md and explicitly approved or revised before implementation work starts.
- Append new plans to the top of PLAN.md so reviewers can quickly locate the most recent proposal.
- PLAN.md entries must follow this format:
  ```
  # <Concise Plan Title>
  ## Context
  - Brief bullets describing the motivation for the change.
  
  ## Proposed Changes
  - Step-by-step outline of the implementation approach.
  
  ## Open Questions
  - Outstanding considerations or decisions awaiting review.
  ```
- Until a plan is approved, leave the "Proposed Changes" section in draft form and update it based on reviewer feedback.

## WHEEL.MD
- Always read the file WHEEL.md  to see what other things have already been invented in this project
- WHEEL.md is to be updated with a list of every file and every function/property available in each file in the project along with a quick one sentence explainer as to what it does.
- WHEEL.md should use this format
```
  # PowerupLibraryView.qml
  ## File details
  This file provides the viewing container class which transforms a PowerupRepository.qml Component into a formatted listView with information about each item from the PowerupRepository.

  ## Functions
  ###  _formatCells(cells) -- formats an array of cells into a more easily viewed format

  ## Properties
  ### repository -- reference pointer to PowerupRepository.qml instance

  ## signals
  ### editRequested(var entry) -- signal is emitted whenever the edit button is clicked for a specific item form the ListView in this component.
```
- Always reference WHEEL.md when writing code and utilize existing types or helpers when possible instead of creating new ones. Try to use base classes to decrease the amount of overall code paths in the application be reusing existing ones.


## TODO.md
- Maintain a file TODO.md which contains the active list of to do items, which from time to time may have to be modified when the user requests a change in some feature or code practice.
- This TODO list is internal list for agents to utilize to keep the current state of the project organized and on task.
- Read the TODO file and implement the items one at a time and only start the next item after one is 100% completed.

## DEV_NOTES.md
- This file captures engineering rationale and guardrails for non-obvious behaviors (e.g., seeding without launches, launch timing/stagger, swap UX thresholds, defender fill gating, role‑swap stabilization, duplicate spawn prevention, and powerup occupancy/visuals).
- Consult DEV_NOTES.md before changing core flows or timings so that future work stays consistent with intended gameplay feel and avoids reintroducing previously fixed issues.

# CODING GUIDELINES

- Use TODO.md and PLAN.md to determine what needs to be done and how to approach it before touching code.
- Use WHEEL.md to document all functions, signals, and properties for each .qml and .cpp/.h  file in the project
- Set yourself up for success. Write code so that it will be compatible and portable even when other components change
- Break down large problems into multiple QML files, and use OOP style integration to keep them from being overly dependent
- Encapsulate code to manipulate and control other QML files as functions and properties with generic purposes - avoid being too specific and instead use relative values (parent.implicitWidth * 0.60) instead of 650
- Leave room everywhere to be able to tie in additional bells and whistles by connecting animations to events and then connecting events to their destinations so i can make things have little animated experiences as they transition through states
- Use states to control what interactive types are allowed to do and what role they play.
- GameGrid should have many many states
- Blocks should have many states
- Powerups should have a number of states from dead to onboard, to fully charged, to charging, to (possibly more so leave room) and make it all clean and easy to follow by a human who is lazy
