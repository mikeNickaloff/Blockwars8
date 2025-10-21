# ADDITIONAL AGENT INSTRUCTIONS

## PLAN.md
- Maintain a PLAN.md file at the repository root as the authoritative record of work plans before any coding begins.
- Every planned change must be documented in PLAN.md and explicitly approved or revised before implementation work starts.
- Append new plans to the top of PLAN.md so reviewers can quickly locate the most recent proposal.
- PLAN.md entries must follow this format:
  ```
  # <Change #> - <Concise Plan Title>
  ## Status
  -  Pending/Approved/Needs Review/Needs information/Postponed/Scheduled/Complete
  ## Context
  - Brief bullets describing the motivation for the change.
  
  ## Proposed Changes
  - Step-by-step outline of the implementation approach.
  
  ## Questions / Comments
  - Outstanding considerations or decisions awaiting review.
  ```
- Until a plan is approved, leave the "Proposed Changes" section in draft form and update it based on reviewer feedback.
- When a specific Change # is approved its Status should be changed from Pending to Approved and the entire text of the change should be moved to the APPROVED_CHANGES.md file and taken  out of the PLAN.md file

## APPROVED_CHANGES.md
- Contains the original details of the change that was approved including implementation details and descriptions
- Will stay in this file until after  the Change has its status updated to "PRODUCTION"
- Each change's status will go from Approved to WIP  to Completed then either go to PRODUCTION if testing is successful or Roll Back  if the change broke something and was rolled back. After rolling the change back, comments should be added on what things need to be considered when making this change to avoid breaking the code.
- Update this file whenever the status of a Change # is updated. 

## WHEEL.MD
- Use WHEEL.md to quickly find functions and their purpose in project files without reading though every single file. 
- Always read the file WHEEL.md  to see what other things have already been invented in this project before creating implementation steps.
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
- Always reference WHEEL.md when writing code and utilize existing types or helpers when possible instead of creating new ones. Try to use base classes to decrease the amount of overall code paths in the application by reusing existing ones.


## TODO.md
- Maintain a file TODO.md which contains the active list of to do items,
- This list should come from APPROVED_CHANGES.md specifically the implementation steps part of every change in that file.
- TO DO items should be simple, direct, and targetted to serve specific purpose - avoid vague or tasks with huge scope of work.
- This TODO list is internal list for agents to utilize to know what changes are to be made to the project now.
- Read the TODO file and implement the items one at a time while reading WHEEL.md first to check for any updates and then adding new functions, properties and signals to WHEEL.md after you have finished creating them.
- Once an item is complte,remove it from the TODO.md file.
- Once all implementation steps are complete for a specific Change #, update the status of the Change # to Completed

## DEV_NOTES.md
- This file captures engineering rationale and guardrails for non-obvious behaviors (e.g., seeding without launches, launch timing/stagger, swap UX thresholds, defender fill gating, role‑swap stabilization, duplicate spawn prevention, and powerup occupancy/visuals).
- Consult DEV_NOTES.md before changing core flows or timings so that future work stays consistent with intended gameplay feel and avoids reintroducing previously fixed issues.

# CODING GUIDELINES

- Follow the guidelines by using PLAN.md, APPROVED_CHANGES.md, TODO.md and WHEEL.md to keep everything in a strict and controlled environment so we don't end up with a disaster. 
- Break down large problems into multiple simple specfic steps when creating Implementation steps.
