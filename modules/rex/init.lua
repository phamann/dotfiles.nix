-- Rex server config: key bindings and actions only. Fonts, theme and the
-- Option key are Mac app settings (com.superlogical.rex defaults), not Lua.
--
-- Bindings mirror the zellij Alt layer (modules/zellij/config.kdl) so the
-- same muscle memory works in both. Validate with `rex config check`;
-- activation runs `rex config reload` after each rebuild.

rex.bind("alt+t", "client.tab.new")

-- Zoom the focused pane, as tmux's prefix+z.
rex.bind("alt+z", "pane.zoom")
rex.bind("alt+x", "pane.zoom")

-- Without these, Alt+digit falls through to zsh as a repeat count.
for i = 1, 9 do
  rex.bind("alt+" .. i, "client.tab.goto", { index = i })
end

-- Raycast owns Alt+arrow system-wide for window snapping.
rex.bind("ctrl+alt+left", "pane.focus.left")
rex.bind("ctrl+alt+right", "pane.focus.right")
rex.bind("ctrl+alt+up", "pane.focus.up")
rex.bind("ctrl+alt+down", "pane.focus.down")

-- New floating shell, 80% of the window and centred.
rex.action({
  name = "float_shell",
  title = "New Floating Shell",
  category = "Pane",
  run = function()
    return rex.session.new_layer({
      bounds = { 0.1, 0.1, 0.8, 0.8 },
      layout = rex.layout.block({ flavor = "com.superlogical.terminal.shell" }),
      focus = true,
    })
  end,
})
rex.bind("alt+w", "float_shell")

-- New shell to the right of the focused pane, taking a third of its width.
-- `ratio` is the share kept by the left side. Unlike the app's pane.split,
-- new_split doesn't inherit the directory, so take the foreground process's
-- (the `pwd` method relies on OSC 7, which our shells don't send).
rex.action({
  name = "split_right_third",
  title = "Split Right (1/3)",
  category = "Pane",
  run = function(ctx)
    local options = {}
    local proc = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    if proc and proc.foreground and proc.foreground.cwd then
      options.cwd = proc.foreground.cwd
    end
    local r, err = rex.session.new_split({
      anchor_id = ctx.block_id,
      direction = "horizontal",
      side = "after",
      ratio = 2 / 3,
      layout = rex.layout.block({ flavor = "com.superlogical.terminal.shell", options = options }),
      focus = true,
    })
    if err ~= nil then
      error(err, 0)
    end
    return r
  end,
})
rex.bind("alt+v", "split_right_third")
