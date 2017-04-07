local lgi = require 'lgi'
local Gtk = lgi.Gtk
local Gdk = lgi.Gdk
local cairo = lgi.cairo
local serpent = require 'serpent'

local utils = require 'gardener.utils'

state = {
  ci = 0, -- current index
  cs = "full",
  cp = {}, -- click point
  rp = {} -- release point
}

local window, header, stack, canvas, cnvsw, surface
local gsbox, gbox, agbox, gswbox
local agentry
local glst
local sbbutton
local llbox, lbbox
local ltxv
local wentry, hentry, whbox
local cslab -- current section label

imagepath = os.getenv('HOME')..'/.config/gardener/images/'

local cfgpath = os.getenv('HOME')..'/.config/gardener/conf.lua'
data = dofile(cfgpath)

stack = Gtk.Stack {}

sbbutton = Gtk.ToolButton {
  icon_name = 'go-previous',
  sensitive = false,
  on_clicked = function (btn)
    stack:set_visible_child_name('gsbox')
    btn.sensitive = false
    window.title = "Gardener"
  end
}

header = Gtk.HeaderBar {
  title = 'Gardener',
  show_close_button = true
}

header:pack_start(sbbutton)

agentry = Gtk.Entry {
  expand = true,
  max_length = 32,
  placeholder_text = 'Patch'
}

wentry = Gtk.Entry {
  expand = true,
  max_length = 3,
  placeholder_text = 'Width',
  input_purpose = 'NUMBER',
}

hentry = Gtk.Entry {
  expand = true,
  max_length = 3,
  placeholder_text = 'Height',
  input_purpose = 'NUMBER',
}

whbox = Gtk.Box {
  orientation = 'HORIZONTAL',
  margin_bottom = 5,
  wentry,
  hentry,
}

local whbox_sc = whbox:get_style_context()
whbox_sc:add_class('linked')

agbox = Gtk.Box {
  orientation = 'HORIZONTAL',
  agentry,
  margin_bottom = 5,
  expand = true,
  Gtk.Button {
    on_clicked = function (btn)
      if agentry.text ~= '' then
        table.insert(data,{
          name = agentry.text,
          width = tonumber(wentry.text),
          height = tonumber(hentry.text),
        })
        utils.update_lsbx(glst,data)
        agentry.text = ''
        wentry.text = ''
        hentry.text = ''
        window:show_all()
      end
    end,
    Gtk.Image {
      icon_name = 'list-add'
    }
  }
}

local agbox_sc = agbox:get_style_context()
agbox_sc:add_class('linked')

glst = Gtk.ListBox {
  on_row_activated = function(lbx,row,udata)
    local index = row:get_index() + 1
    local name = row:get_children()[1]:get_children()[1].label
    print(name,index)
    state.ci = index
    stack:set_visible_child_name("gbox")
    canvas.width = data[state.ci].width * 20 + 40
    canvas.height = data[state.ci].height * 20 + 40
    print(data[state.ci].width * 20, data[state.ci].height * 20)
    -- cnvsw.width = data[state.ci].width * 10
    -- cnvsw.height = data[state.ci].height * 10
    sbbutton.sensitive = true
    window.title = name
    utils.update_log_lsbx(llbox,data[state.ci].log,state.cs)
  end,
}

utils.update_lsbx(glst,data)

gswbox = Gtk.Box {
  width_request = 300,
  orientation = 'VERTICAL',
  halign = 'CENTER',
  valign = 'CENTER',
  agbox,
  whbox,
  Gtk.ScrolledWindow {
    min_content_width=400,
    min_content_height=300,
    hscrollbar_policy = 'NEVER',
    Gtk.Frame {
      glst
    }
  }
}

gsbox = Gtk.Box {
  orientation = 'VERTICAL',
  gswbox,
}

canvas = Gtk.DrawingArea {
  width_request = 200,
  height_request = 200,
}

canvas:override_background_color(0, Gdk.RGBA { red = 1, green = 1, blue = 1, alpha = 1 })

function draw_rect(widget,x,y,w,h)
  local cr = cairo.Context(surface)
  -- cr:rectangle(Gdk.Rectangle {
  --   x,y,w,h
  -- })
  cr.line_width = 1
  cr:set_source_rgb(0,0,0)
  cr:rectangle(x,y,w,h)
  cr:stroke()
  -- widget:queue_draw()
end

function draw_sections()
  if data[state.ci].sections ~= nil then
    local cr = cairo.Context(surface)
    cr.line_width = 1
    cr:set_source_rgb(0,0,0)
    for k,v in pairs(data[state.ci].sections) do
      local rect = Gdk.Rectangle {
        x = v[1]*20+20,
        y = v[2]*20+20,
        width = (v[3]-v[1])*20,
        height = (v[4]-v[2])*20
      }
      cr:rectangle(rect)
      cr:stroke()
      cr:set_font_size(14)
      cr.font_face = cairo.ToyFontFace.create("Times New Roman", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
      local extents = cr:text_extents(k)
      local hpos = (rect.x + rect.width/2) - (extents.width/2 + extents.x_bearing)
      local vpos = rect.y + rect.height/2
      cr:move_to(hpos,vpos)
      cr:show_text(k)
    end
    -- canvas:queue_draw()
  end
end

function clear_surface()
  local cr = cairo.Context.create(surface)
  cr:set_source_rgb(1,1,1)
  cr:paint()
end

function canvas:on_configure_event(event)
  local allocation = self.allocation
  surface = self.window:create_similar_surface('COLOR', allocation.width, allocation.height)
  clear_surface()
  return true
end

function canvas:on_draw(cr)
  clear_surface()
  draw_rect(canvas, 20,20, data[state.ci].width * 20, data[state.ci].height * 20)
  draw_sections()
  cr:set_source_surface(surface,0,0)
  cr:paint()
  return true
end

function canvas:on_button_press_event(event)
  local x = math.floor(math.floor(event.x - 20) / 20)
  local y = math.floor(math.floor(event.y - 20) / 20)
  if event.button == Gdk.BUTTON_PRIMARY then
    print('click!',x,y)
    -- draw_rect(self,x*20+20,y*20+20,2,2)
    state.cp = {x,y}
  elseif event.button == Gdk.BUTTON_SECONDARY then
    if data[state.ci].sections ~= nil then
      local csec,popover
      for k,v in pairs(data[state.ci].sections) do
        if x > v[1] and y > v[2] and x < v[3] and y < v[4] then
          csec = k
          print('clicked inside:', k)
          break
        end
      end

      if csec ~= nil then
        local rect = Gdk.Rectangle {
          x = data[state.ci].sections[csec][1]*20+20,
          y = data[state.ci].sections[csec][2]*20+20,
          width = (data[state.ci].sections[csec][3]-data[state.ci].sections[csec][1])*20,
          height = (data[state.ci].sections[csec][4]-data[state.ci].sections[csec][2])*20
        }
        local pobox = Gtk.Box {
          orientation = 'VERTICAL',
          margin = 10,
          Gtk.Label { label = csec },
          Gtk.Button {
            label = 'Focus',
            on_clicked = function (btn)
              state.cs = csec
              cslab.label = csec
              utils.update_log_lsbx(llbox,data[state.ci].log,state.cs)
              popover:hide()
            end
          },
          Gtk.Button {
            label = 'Remove',
            on_clicked = function (btn)
              if csec ~= 'full' then
                data[state.ci].sections[csec] = nil
                clear_surface()
                draw_rect(canvas, 20,20, data[state.ci].width * 20, data[state.ci].height * 20)
                draw_sections()
              end
              popover:hide()
            end
          },
        }

        local pobox_sc = pobox:get_style_context()
        pobox_sc:add_class('linked')

        popover = Gtk.Popover {
          relative_to = canvas,
          pointing_to = rect,
          pobox
        }
        popover:show_all()
      else
        state.cs = 'full'
        cslab.label = 'full'
        utils.update_log_lsbx(llbox,data[state.ci].log,state.cs)
      end
    end
  end
  return true
end

function canvas:on_button_release_event(event)
  local x = math.floor(math.floor(event.x - 20) / 20)
  local y = math.floor(math.floor(event.y - 20) / 20)
  if event.button == Gdk.BUTTON_PRIMARY then
    state.rp = {x,y}
    print('release!',x,y)
    if state.cp[1] ~= state.rp[1] and state.cp[2] ~= state.rp[2] then
      local rect = Gdk.Rectangle {
        x = state.cp[1]*20+20,
        y = state.cp[2]*20+20,
        width = (state.rp[1]-state.cp[1])*20,
        height = (state.rp[2]-state.cp[2])*20
      }

      local popover, sece

      sece = Gtk.Entry { placeholder_text = 'Name' }
      local pobox = Gtk.Box {
        orientation = 'VERTICAL',
        margin = 10,
        sece,
        Gtk.Button {
          label = 'Create',
          on_clicked = function (btn)
            if data[state.ci].sections == nil then
              data[state.ci].sections = {}
            end
            data[state.ci].sections[sece.text] = { state.cp[1],state.cp[2],state.rp[1],state.rp[2] }
            sece.text = ''
            popover:hide()
          end
        },
      }

      local pobox_sc = pobox:get_style_context()
      pobox_sc:add_class('linked')

      popover = Gtk.Popover {
        relative_to = canvas,
        pointing_to = rect,
        pobox
      }
      popover:show_all()

      -- draw_rect(self,state.cp[1]*20+20,state.cp[2]*20+20,(state.rp[1]-state.cp[1])*20,(state.rp[1]-state.cp[1])*20)
    end
  end
  return true
end

canvas:add_events(Gdk.EventMask {
  'LEAVE_NOTIFY_MASK',
  'BUTTON_PRESS_MASK',
  'BUTTON_RELEASE_MASK',
  'POINTER_MOTION_MASK',
  'POINTER_MOTION_HINT_MASK'
})

llbox = Gtk.ListBox {
  width_request = 300
}

function add_log(category)
  local txt = ltxv.buffer.text
  if data[state.ci].log == nil then
    data[state.ci].log = {}
  end
  table.insert(data[state.ci].log, 1, {
    txt = txt,
    cat = category,
    scope = state.cs,
    date = os.date("%d.%m.%y %H:%M")
  })
  ltxv.buffer.text = ''
end

lbbox = Gtk.Box { -- LINKED BUTTONS
  margin_bottom = 5,
  margin_top = 5,
  Gtk.Button {
    label = 'Water',
    on_clicked = function (btn)
      add_log('Water')
      utils.update_log_lsbx(llbox,data[state.ci].log,state.cs)
    end
  },
  Gtk.Button {
    label = 'Plant',
    on_clicked = function (btn)
      add_log('Plant')
      utils.update_log_lsbx(llbox,data[state.ci].log,state.cs)
    end
  },
  Gtk.Button {
    label = 'Note',
    on_clicked = function (btn)
      add_log('Note')
      utils.update_log_lsbx(llbox,data[state.ci].log,state.cs)
    end
  },
}

cslab = Gtk.Label {
  label = 'full'
}

lbbox:pack_end(cslab, false, false, 0)

local lbbox_sc = lbbox:get_style_context()
lbbox_sc:add_class('linked')

ltxv = Gtk.TextView {
  top_margin = 5,
  bottom_margin = 5,
  left_margin = 5,
  right_margin = 5,
  height_request = 100,
  wrap_mode = 'WORD_CHAR'
}

-- smbox = Gtk.Box { -- section management box
--   orientation = 'HORIZONTAL',
--   margin_top = 5,
--   margin_bottom = 5,
--   Gtk.ComboBoxText {}
-- }

cnvsw = Gtk.ScrolledWindow {
  expand = true,
  canvas
}

gbox = Gtk.Box {
  orientation = 'VERTICAL',
  Gtk.Paned {
    orientation = 'HORIZONTAL',
    Gtk.Box {
      width_request = 300,
      margin = 20,
      orientation = 'VERTICAL',
      -- smbox,
      Gtk.Frame {
        cnvsw
      }
    },
    Gtk.Box {
      orientation = 'VERTICAL',
      Gtk.Box {
        margin_left = 20,
        margin_right = 20,
        orientation = 'VERTICAL',
        lbbox,
        Gtk.Frame {
          Gtk.ScrolledWindow {
            hscrollbar_policy = 'NEVER',
            min_content_height = 100,
            ltxv
          }
        }
      },
      Gtk.ScrolledWindow {
        -- halign = 'END',
        vexpand = true,
        -- hexpand = true,
        margin = 20,
        -- min_content_width=200,
        -- min_content_height=200,
        hscrollbar_policy = 'NEVER',
        Gtk.Frame { llbox }
      },
    }
  }
}

stack:add_titled(gsbox, "gsbox", "Garden Selection")
stack:add_titled(gbox, "gbox", "Garden")

window = Gtk.Window {
  default_width = 1024,
  default_height = 768,
  stack
}

window:set_titlebar(header)

function window:on_destroy()
  local file = io.open(cfgpath,"w")
  file:write(serpent.dump(data,{comment = false}))
  file:close()
  Gtk.main_quit()
end

window:show_all()
Gtk:main()
