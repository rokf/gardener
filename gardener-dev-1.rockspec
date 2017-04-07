package = "gardener"
version = "dev-1"

source = {
  url = "git://github.com/rokf/gardener.git"
}

description = {
  summary = "Your gardening assistant",
  homepage = "https://github.com/rokf/gardener",
  maintainer = "Rok Fajfar <snewix7@gmail.com>",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lgi",
  "serpent"
}

build = {
  type = "builtin",
  modules = {
    ["gardener.main"] = "gardener/main.lua",
    ["gardener.utils"] = "gardener/utils.lua",
  },
  install = {
    bin = { "bin/gardener" }
  },
  copy_directories = { "images" }
}
