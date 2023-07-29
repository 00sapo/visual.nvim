---
name: Bug report
about: Create a report to help us improve
title: ''
labels: bug
assignees: ''

---

### Describe the bug
A clear and concise description of what the bug is.

### To Reproduce

**Minimal config**
1. Using the minimal configuration generates the error (yes/no).

> Download [this](https://raw.githubusercontent.com/00sapo/visual.nvim/main/test/init.lua) configuration and launch nvim with `-u <test_config.lua>`. In Linux/Mac, here is a one-line command that you can you use in your shell:
> 
> `curl https://raw.githubusercontent.com/00sapo/visual.nvim/main/test/init.lua -o /tmp/visual.nvim-test.lua; nvim -u /tmp/visual.nvim-test.lua <file>`


2. Minimal configuration to reproduce the issue or list of installed plugins:
```lua
configuration
code
```

**Steps to reproduce the behavior:**
1. Install plugin '...'
2. Open file  '....'
3. Type '....'
4. See the following error:
```
stack trace
```

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Desktop (please complete the following information):**
 - OS: [e.g. Linux Manjaro 6.31]
 - Neovim [e.g. 0.9.1]
 - Other relevant plugins [e.g. 22]

**Additional context**
Add any other context about the problem here.
