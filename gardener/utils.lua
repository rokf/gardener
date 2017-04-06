local lgi = require 'lgi'
local Gtk = lgi.Gtk

local utils = {}

function utils.update_lsbx(lsbx,data)
  lsbx:forall(function(element)
    lsbx:remove(element)
  end)

  for i,v in ipairs(data) do
    local row = Gtk.ListBoxRow {}
    local box = Gtk.Box {
      orientation = 'HORIZONTAL',
      Gtk.Label {
        margin = 5,
        label = v.name
      }
    }
    box:pack_end(Gtk.ToolButton {
      icon_name = 'edit-delete-symbolic',
      on_clicked = function (btn)
        local index = row:get_index()
        print(index)
        table.remove(data,index+1)
        lsbx:remove(row)
      end
    },false,false,0)
    row:add(box)
    lsbx:insert(row,-1)
    -- lsbx:insert(Gtk.Separator(),-1)
  end
end

return utils
