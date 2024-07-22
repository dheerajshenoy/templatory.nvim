# templatory.nvim
A neovim plugin for managing and using file templates.

## Demo

https://github.com/dheerajshenoy/templatory.nvim/assets/21986384/abd3f33b-0752-4bcc-bd13-4646d252d477

https://github.com/user-attachments/assets/116e2fb0-ffc0-45e1-823b-83b7d6126e0f

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
- `inject` : inject the template file content to the current buffer, if template file exists for the current buffer filetype or if the current working directory of the file is a 'skeletal directory'.

These are specified like `:Templatory option_name` where `option_name` is one of the four options listed above.

### Workflow 1 (Skeletal files)

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

### Workflow 2 (Skeletal directories)

Skeletal directories are important when you have a directory and when any new file is created inside this directory, the boilerplate code for this will be the same regardless of the filetype or extension of the file. Best example is for a plugin manager directory, where you add files for each of the plugins you want to configure, and the code more or less remains the same for each of the files created in the directory.

1. Let's say I want to create a skeletal directory at some directory `A/B/C`. So that whenever I create any file within the directory, I would want some code which would be required for any files being created within this directory.

2. I navigate to that directory `A/B/C` and then call the `Templatory new` command. Templatory can guess based on the buffer, if it is a directory or a file, so that it can create these "skeletal directory" entries if it is indeed a directory. (*NOTE*: For users using NvimTree or oil.nvim or other plugins, the filetypes of directories will depend on these plugins and have to be manually added to the setup function of Templatory through `dir_filetypes` option. By default, oil.nvim and NvimTree and Netrw buffers will be detected by Templatory.). In this case, since we opened a directory, a buffer is created with the filename that might look weird (A|B|C). This format is used by the plugin to get the information about which directories are considered as Skeletal directories. (Under the hood, it converts these pipes into / in Linux when processing.)

3. Populate the file with the required code and then save.

4. Whenever new file is created in the directory which is a skeletal directory, code will be injected (if auto insert is enabled) or can be injected through `Templatory inject` command.

5. One thing to note here is that skeletal directories take precedence over skeletal files. So, if for example, a skeletal file exists for C++ files, and if a C++ file exists in a directory which also happens to be a skeletal directory, then the code from the skeletal directory will be injected and not the skeletal file code.



# TODO

- [x] Directory based templates: Based on blacklisted directories, create files with a specific content in them. For example, when creating files for plugins for the lazy package manager inside the plugins directory in the config directory, create a file with required contents which are boilerplate and put cursor where we can type the URL of the plugin directly.
