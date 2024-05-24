# templatory.nvim
A neovim plugin for managing and using file templates

# Table of Contents

# Introduction

## What are templates ?

Templates or skeleton files are files that contain boilerplate code. These are useful when you create a new file and want to skip writing the boilerplate code. Best example is the #include directives & main function of C++. Every program requires it, so just create a template file for it and templatory.nvim will do the rest. Sounds cool ? Let's get you started using this plugin then.

## Using templatory.nvim

### Installation

1. Install this plugin using your favourite neovim plugin manager.

2. Require this module somewhere in your neovim config. NOTE:   

```lua
require("templatory").setup({


})
```

