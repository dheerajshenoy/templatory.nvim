# templatory.nvim
A neovim plugin for managing and using file templates

# Table of Contents

# Introduction

## What are templates ?

Templates or skeleton files are files that contain boilerplate code. These are useful when you create a new file and want to skip writing the boilerplate code. Best example is the #include directives & main function of C++. Every program requires it, so just create a template file for it and templatory.nvim will do the rest. Sounds cool ? Let's get you started using this plugin then.

## Using templatory.nvim

### Installation

1. Install this plugin using your favourite neovim plugin manager.

2. Require this module somewhere in your neovim config.

```lua
require("templatory").setup()
```

The default behaviour of templatory is good and it is not necessary to change it. Some people might find it intrusive as the plugin prompts for adding template files. Check configuration section for changing the default behaviour

3. Configure

Add the following code snippet for changing the default behaviour

```lua
require("templatory").setup({

            skdir = "~/Gits/templatory.nvim/skeletons/", -- the skeleton directory
            goto_cursor_line = true, -- Goto the line with the `cursor_pattern` after inserting template (default: true)
            cursor_pattern = "$C", -- Pattern used to represent the cursor position after template insertion (default: $C)
            prompt = false, -- Prompt before adding the template (default: false)
            echo_no_file = true, -- Print message when no skeleton file is found for the current filetype (default: false)
            prompt_for_no_file = true, -- Prompt message asking to create a template when no file is found (default: false)
            auto_insert_template = true, -- Load the template to a file automagically without needing to call `:TemplatoryInject`

})
````
