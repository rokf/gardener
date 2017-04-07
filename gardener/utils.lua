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

function utils.update_log_lsbx(lsbx,log,filter)
  if log ~= nil then
    lsbx:forall(function (element)
      lsbx:remove(element)
    end)
    for i,v in ipairs(log) do

      if filter ~= nil and (filter == "full" or v.scope == filter) then
        local row = Gtk.ListBoxRow {}
        local box = Gtk.Box {
          orientation = 'HORIZONTAL',
          Gtk.Label {
            label = v.date
          },
          Gtk.Label {
            label = v.cat
          },
          Gtk.Label {
            label = v.scope
          }
        }

        if #v.txt > 0 then
          local txtview = Gtk.TextView {}
          txtview.buffer.text = v.txt
          box:pack_end(txtview,false,false,0)
        end

        row:add(box)
        lsbx:insert(row,-1)
      end
    end
  end
  lsbx:show_all()
end

return utils
