setlocal conceallevel=2

"syntax match CodeflowWindowHeader /\vFlows.*$/
"highlight default link CodeflowWindowHeader Statement

syntax match CodeflowCurrentFlowSelectCharacter /\v^\|/ contained conceal transparent contains=NONE
syntax match CodeflowCurrentFlow /\v^\|.*$/ contains=CodeflowCurrentFlowSelectCharacter
syntax match CodeflowCWD /\v^[</].*$/
syntax match CodeflowStep /\v^\d*\) .*$/
syntax match SelectedCodeflowStepChar /\v^\+/ contained conceal transparent contains=NONE
syntax match SelectedCodeflowStep /\v^\+\d*\) .*$/ display contains=SelectedCodeflowStepChar
highlight default link CodeflowCWD Statement
highlight default link CodeflowCurrentFlow Statement
highlight default link CodeflowStep Normal
highlight default link SelectedCodeflowStep Underlined
