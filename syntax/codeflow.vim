setlocal conceallevel=2

syntax match CodeflowWindowHeader /\vFlows.*$/
highlight default link CodeflowWindowHeader Statement

syntax match CodeflowStep /\v^\d*\) .*$/
highlight default link CodeflowStep Normal
syntax match SelectedCodeflowStepChar /\v^\+/ contained conceal transparent contains=NONE
syntax match SelectedCodeflowStep /\v^\+\d*\) .*$/ display contains=SelectedCodeflowStepChar
highlight default link SelectedCodeflowStep Underlined
