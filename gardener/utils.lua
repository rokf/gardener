local lgi = require 'lgi'
local Gtk = lgi.Gtk

local utils = {}

function utils.update_lsbx(lsbx,data)
  lsbx:forall(function(element) lsbx:remove(element) end)
  for i,v in ipairs(data) do
    local row = Gtk.ListBoxRow {}
    local box = Gtk.Box {
      orientation = 'HORIZONTAL',
      Gtk.Label {
        margin = 5,
        label = v.name
      }
    }
    box:pack_end(Gtk.Button {
      relief = 'NONE',
      Gtk.Image {
        file = imagepath .. 'trash-2x.png'
      },
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
    lsbx:forall(function (element) lsbx:remove(element) end)
    for i,v in ipairs(log) do
      if filter ~= nil and (filter == "full" or v.scope == filter) then
        local row = Gtk.ListBoxRow {}
        local icon = Gtk.Image {
          margin_right = 5
        }

        if v.cat == "Water" then
          icon.file = imagepath .. 'droplet-2x.png'
        elseif v.cat == "Plant" then
          icon.file = imagepath .. 'arrow-bottom-2x.png'
        elseif v.cat == "Note" then
          icon.file = imagepath .. 'text-2x.png'
        end

        local box = Gtk.Box {
          orientation = 'HORIZONTAL',
          margin = 10,
          icon,
          Gtk.Label {
            label = v.date,
            margin_right = 10
          },
          Gtk.Label {
            label = v.scope
          }
        }

        box:pack_end(Gtk.Button {
          relief = 'NONE',
          Gtk.Image {
            file = imagepath .. 'trash-2x.png'
          },
          on_clicked = function (btn)
            print('remove-log-i:',i)
            table.remove(log,i)
            lsbx:remove(row)
            utils.update_log_lsbx(lsbx,log,filter) -- needs redraw because of the index i used here
          end
        },false,false,0)

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

function utils.ceilfloor(num)
  if (num - math.floor(num)) >= 0.5 then
    return math.ceil(num)
  else
    return math.floor(num)
  end
end

return utils
