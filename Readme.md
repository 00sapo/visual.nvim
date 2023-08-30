# Visual.nvim

**N.B. This is still in a very experimental stage and mappings will
suddenly change in the next few weeks.** 

### Serendipity

noun,  formal; _the fact of finding interesting or valuable things by chance_

## What is this
In nvim, you do `c3w`. Ah no! It was wrong, let's retry: `uc5w`... wooops! Sorry, it
is still wrong: `uc6w`!

In Kakoune (which inspired Helix), you do the opposite: `3w`. First select 3
words, then you see you still need three words, so `3w`. Then finally `d` for
deleting.

In `visual.nvim`, this actually becomes `3wv3wd`, with the `v` used for
"refining" selections. If you do not need to adjust the selection, `3wd` is all
you need. The magic here is that `visual.nvim` puts you in a special mode named
"serendipity" in which you can use some normal commands but also some visual commands.
This allows you to have a preview of what your edit command will modify, so that you
can occasionally change the selection by entering the visual mode.

First select, then edit. This should be the way.

If you have been tempted by Kakoune and Helix editors, this may be your new plugin!

## Features

* Selection first mode
* New "serendipity" mode: discover motion errors by chance!
* Surrounding commands (change, delete, add) that operate over selections
* Repeat motions
* Compatible with treesitter-textobjects

## Usage

Just install it using your preferred package manager.

* Lazy: `{ '00sapo/visual.nvim' }`
* Packer: `use { '00sapo/visual.nvim' }`

Further configuration examples [below](#example-config). The mappings can be fine-tuned at your will as well,
see [Keymaps](#keymaps)

### Usage

Motion commands such as `w`, `e`, `b`, `ge`, `f`, `t` and their punctuation-aware alternatives
`W`, `E`, `B`, `gE`, `F`, `T` behave the same as vim (or are supposed so), but also put you in
"serendipity" mode.

Once you are in serendipity mode, you can modify text (`c`, `x`, `i`, `a`) as if you were in normal mode. `d` and `y` will work as in visual mode. With `<A-,>`, you can repeat the last motion selection, while with `<A-.>` you can repeat the last edit applied in insert mode from serendipity or visual mode.

Serendipity mode is built around the nvim's visual mode, so you can use all
visual commands if they don't interfer with your config.
From serendipity mode, you can enter visual mode with `v`, `<S-v>`, `<C-v>`. You can
also switch between visual and serendipity mode with `-`. Moreover, `d` from normal mode
will be the same as `<S-v>`, followed by serendipity enter `-`.
From serendipity mode, `<esc>` will lead you to normal mode.

Note that motion commands in visual mode are different from normal mode.
Serendipity mode emulates normal mode for motion commands!

Remember using `o` to move the cursor to the other end of the visual/serendipity
selection when needed.

Selection of text objects is possible as in usual nvim with `i<text object>` and `a<text object>` in visual mode, thus becoming `va` and `vi` from normal mode, similarly to Helix's `mi` and `ma`. From serendipity mode, since `i` and `a` are mapped to `append` and `insert`, they become `I` and `A`, (or still `vi` and `va`). If you are a treesitter-textobjects user, simply set the `treesitter_textobjects` option to `true` for using them from serendipity mode.

Visual.nvim also offers surrounding commands with `sd`, `sc`, and `sa` (delete, change, add).

Finally, in serendipity mode, pressing `hjkl` will extend the selection. You can move to
normal mode with `<A-h>`, `<A-j>`, etc.

### Limitations

* Visual.nvim still does not support macros due to limitations in the lua API ([see
issue](https://github.com/00sapo/visual.nvim/issues/7)). For this reason, pressing `q` will disable
Visual.nvim mappings. You should re-enable them manually with `:VisualEnable` when you
have finished recording/running the macros.

* Dot-repeat are supported via `A-.` and `A-,`. Moreover, usual `.` works from normal
mode. This may create confusion in the workflow.

* The way movements work is still being fine-tuned. Help wanted!


### Example config

Configuration with some change to commands in order to make them compatible (needed by
NvChad):
```lua
{    
  '00sapo/visual.nvim',
  config = function()
    require('visual').setup({
    commands = {
      move_up_then_normal = { amend = true },
      move_down_then_normal = { amend = true },
      move_right_then_normal = { amend = true },
      move_left_then_normal = { amend = true },
    },
  } )
  end,
  event = "VeryLazy", -- this is for making sure our keymaps are applied after the others: we call the previous mapppings, but other plugins/configs usually not!
}
```

Example with Treesitter incremental selection
```lua
{
    '00sapo/visual.nvim',
    config = function ()
        require('nvim-treesitter.configs').setup { 
            incremental_selection = { 
                enable = true,
                keymaps = {
                    init_selection = "<c-.>",
                    node_incremental = "<c-.>",
                    scope_incremental = "<c-,>",
                    node_decremental = "<c-/>",
                }
            } 
        }
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = "VeryLazy"
}
```

Example with Treesitter text objects
```lua
{
    dir = "00sapo/visual.nvim",
    opts = { treesitter_textobjects = true },
    dependencies = { "nvim-treesitter", "nvim-treesitter-textobjects" },
},
{
    "nvim-treesitter/nvim-treesitter",
    --etc.
}
```

## Keymaps

The plugin is highly customizable. It maps commands to keymaps, and you can define new
commands or edit the existing ones. The following is the default set-up. Read the
comments to understand how to modify it.

Feel free to suggest new default keybindings in the issues!

See the [full default options](https://github.com/00sapo/visual.nvim/blob/71759886d3864bebe3edd7c00916925edd340256/lua/visual.lua#L90-L357
) with documentation in the comments: 

# Testing

* `curl https://raw.githubusercontent.com/00sapo/visual.nvim/main/test/init.lua -o /tmp/visual.nvim-test.lua`
* `nvim -u /tmp/visual.nvim-test.lua <file>`

# Developing

* Use `nvim -u test/init.lua test/init.lua` for testing
* Use `Vdbg(...)` from anywhere to debug lua objects
* Use `<A-d>u` to show the log of debugged objects and `<A-d>c` to clean the log

# TODO

* Experiment with `vim-visual-multi`
