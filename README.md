# templatory.nvim
A neovim plugin for managing and using file templates.

## What are templates ?

Templates or skeleton files are files that contain boilerplate code. These are useful when you create a new file and want to skip writing the boilerplate code. Best example is the #include directives & main function of C++. Every program requires it, so just create a template file for it and templatory.nvim will do the rest. Sounds cool ? Let's get you started using this plugin then.

## Using templatory.nvim

### Installation

1. Install this plugin using your favourite neovim plugin manager. I use [lazy](https://github.com/folke/lazy.nvim) plugin manager, so I include something like this in my neovim config file.

```lua
{
    "dheerajshenoy/templatory.nvim",
    event = "VeryLazy",
    config = function ()
        require("templatory").setup({
            templates_dir = "~/Gits/templatory.nvim/skeletons/",
            cursor_pattern = "$C",
            goto_cursor_line = true,
            prompt = false,
            echo_no_file = false,
            prompt_for_no_file = true,
            auto_insert_template = true,
        })
    end
}
```

2. Require this module somewhere in your neovim config.

```lua
require("templatory").setup()
```

The default behaviour of templatory is good and it is not necessary to change it. Some people might find it intrusive as the plugin prompts for adding template files. Check configuration section for changing the default behaviour

3. Configure

Add the following code snippet for changing the default behaviour

```lua
require("templatory").setup({
            templates_dir = "~/Gits/templatory.nvim/skeletons/", -- the skeleton directory (default: ~/.config/nvim/templates)
            goto_cursor_line = true, -- Goto the line with the `cursor_pattern` after inserting template (default: true)
            cursor_pattern = "$C", -- Pattern used to represent the cursor position after template insertion (default: $C)
            prompt = false, -- Prompt before adding the template (default: false)
            echo_no_file = true, -- Print message when no skeleton file is found for the current filetype (default: false)
            prompt_for_no_file = true, -- Prompt message asking to create a template when no file is found (default: false)
            auto_insert_template = true, -- Load the template to a file automagically without needing to call `:TemplatoryInject`
})
````

4. Commands

The plugin creates a user command `Templatory` which has 4 options:

- `new` : opens an empty file in the templates directory
- `visit_file` : open the template file for the current opened buffer filetype
- `visit_dir` : open the templates directory 
- `inject` : inject the template file content to the current buffer, if template file exists for the current buffer filetype

These are specified like `:Templatory option_name` where `option_name` is one of the four options listed above.

### Workflow

1. Let's say I want to create a template file for C++ boilerplate code. I create a new template file using `:Templatory new` and hen save it with some filename (filenames don't matter, only the extensions do!), let's say `sk.cpp` with the following contents and save the file.

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main(int argc, char* argv[])
{
    //$C

    return 0;
}

```

**NOTE**: *Notice the line //$C. This is where the cursor will be positioned once the templates are injected to the buffer*


2. I open a new .cpp file, then based on the configuration of the plugin, I will be prompted to add the template code. If accepted, the code will be injected to the buffer.

3. Now, I create another template file called `sk2.cpp` with the following contents and save it.


```cpp
#include <iostream>
#include <vector>

using namespace std;

//$C
class HelloWorld
{

public:
    HelloWorld();
    ~HelloWorld();

private:
    void templatoryDemoFunc();

}

int main(int argc, char* argv[])
{

    return 0;

}
```

4. Now, when I open a non-existent .cpp file, I'll be prompted to select which of the two template file to inject into the buffer.

![templatory-nvim-select-menu](https://github.com/dheerajshenoy/templatory.nvim/assets/21986384/b9bc60a9-8e95-4cc5-8e13-3246fe44f5ee)

### Demo

https://github.com/dheerajshenoy/templatory.nvim/assets/21986384/abd3f33b-0752-4bcc-bd13-4646d252d477

# TODO

- [ ] Directory based templates: Based on blacklisted directories, create files with a specific content in them. For example, when creating files for plugins for the lazy package manager inside the plugins directory in the config directory, create a file with required contents which are boilerplate and put cursor where we can type the URL of the plugin directly.
