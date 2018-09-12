# QuickSPCR
QuickSPCR is a Ruby app which opens a message box whenever you close a
non-natively-supported Steam game, asking if you'd like to add a compatibility
report for the game on https://spcr.netlify.com.

## Usage
```
bundle install
ruby src/quickspcr.rb
```

## Roadmap
  - [X] Core functionality 
  - [ ] Button for "Don't ask again"
  - [ ] Don't prompt again if report made
  - [ ] Run on startup
  - [ ] Package for `apt`