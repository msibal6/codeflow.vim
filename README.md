# Codeflow.vim
A smooth way to navigate code 

## Installation
This should be plugabble using [vim-plug](https://github.com/junegunn/vim-plug).

## Usage

### Commands
All commands are actions for `:Codeflow` editor command
| Command                   | Description                                                                                      |
| -----------               | -----------                                                                                      |
| start                     | starts a new flow to record steps                                                                |
| save                      | saves the active flow                                                                            |
| close                     | closes the active flow                                                                           |
| open                      | opens a flow to replay                                                                           |
| openWindow                | opens the codeflow window                                                                        |
| closeWindow               | closes the codeflow window                                                                       |
| addStep                   | adds new step at the end of the current flow                                                     |
| insertStep                | inserts a new step after the current step                                                        |
| goToStep \<index\>        | go to step given at \<index\>                                                                    |
| prevStep                  | moves to the previous step                                                                       |
| nextStep                  | moves to the next step                                                                           |
| updateStep <shouldMoveOn> | updates the current step to new location <br>and moves to the next step if \<shouldMoveOn\> is 1 |
| deleteStep                | deletes current step                                                                             |

### Codeflow Window
The codeflow window is used to visually navigate between flows and steps in a
frictionless manner. When there is no active flow, all current flows for the
current working directory will be displayed. When there is an active flow, all 
steps will be displayed.

| Default Hotkeys | Description                                            |
| -----------     | -----------                                            |
| \<CR\>          | starts flow under cursor<br>goes to step under cursor  |
| \<o\>           | starts flow under cursor<br>goes to step under cursor  |
| \<d\>           | deletes flow under cursor<br>deletes step under cursor |

## Feature Roadmap
 - [ ] use J/K to move steps up and down
 - [ ] c to close current active flow
 - [ ] c to create new active flow when no flow aactive
