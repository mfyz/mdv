-- Custom ANSI writer for mdv
-- Provides colorful terminal output for markdown

-- ANSI escape codes
local ansi = {
  reset = "\027[0m",
  bold = "\027[1m",
  dim = "\027[2m",
  italic = "\027[3m",
  underline = "\027[4m",
  inverse = "\027[7m",

  -- Foreground colors (bright)
  red = "\027[91m",
  green = "\027[92m",
  yellow = "\027[93m",
  blue = "\027[94m",
  magenta = "\027[95m",
  cyan = "\027[96m",
  white = "\027[97m",
  orange = "\027[38;5;208m",

  -- Background colors
  bg_gray = "\027[48;5;236m",
  bg_dark = "\027[48;5;235m",
  bg_red = "\027[48;5;124m",
  bg_orange = "\027[48;5;166m",
  bg_blue1 = "\027[48;5;33m",
  bg_blue2 = "\027[48;5;26m",
  bg_blue3 = "\027[48;5;21m",
  bg_blue4 = "\027[48;5;18m",
  blue_text = "\027[38;5;39m",
}

-- Track list depth for indentation
local list_depth = 0

-- Helper to wrap text with ANSI codes
local function wrap(code, text)
  return code .. text .. ansi.reset
end

-- Writer functions
function Writer(doc, opts)
  local buffer = {}

  for _, block in ipairs(doc.blocks) do
    table.insert(buffer, render_block(block))
  end

  return table.concat(buffer, "\n\n")
end

function render_block(block)
  if block.t == "Header" then
    local level = block.level
    local hashes = string.rep("#", level) .. " "
    local text = render_inlines(block.content)

    if level == 1 then
      return wrap(ansi.bg_blue4 .. ansi.white .. ansi.bold, " " .. hashes .. text .. " ")
    elseif level == 2 then
      return wrap(ansi.bg_blue3 .. ansi.white .. ansi.bold, " " .. hashes .. text .. " ")
    elseif level == 3 then
      return wrap(ansi.bg_blue2 .. ansi.white .. ansi.bold, " " .. hashes .. text .. " ")
    elseif level == 4 then
      return wrap(ansi.bg_blue1 .. ansi.white .. ansi.bold, " " .. hashes .. text .. " ")
    else
      -- H5+: blue text with hashes
      return wrap(ansi.blue_text .. ansi.bold, hashes .. text)
    end

  elseif block.t == "Para" then
    return render_inlines(block.content)

  elseif block.t == "Plain" then
    return render_inlines(block.content)

  elseif block.t == "CodeBlock" then
    local lines = {}
    for line in block.text:gmatch("[^\n]*") do
      table.insert(lines, "  " .. wrap(ansi.bg_gray, " " .. line .. " "))
    end
    return table.concat(lines, "\n")

  elseif block.t == "BulletList" then
    local items = {}
    list_depth = list_depth + 1
    local indent = string.rep("  ", list_depth - 1)
    for _, item in ipairs(block.content) do
      local item_text = render_blocks(item)
      table.insert(items, indent .. "• " .. item_text)
    end
    list_depth = list_depth - 1
    return table.concat(items, "\n")

  elseif block.t == "OrderedList" then
    local items = {}
    list_depth = list_depth + 1
    local indent = string.rep("  ", list_depth - 1)
    for i, item in ipairs(block.content) do
      local item_text = render_blocks(item)
      table.insert(items, indent .. i .. ". " .. item_text)
    end
    list_depth = list_depth - 1
    return table.concat(items, "\n")

  elseif block.t == "BlockQuote" then
    local text = render_blocks(block.content)
    local lines = {}
    for line in text:gmatch("[^\n]+") do
      table.insert(lines, wrap(ansi.dim, "│ ") .. line)
    end
    return table.concat(lines, "\n")

  elseif block.t == "HorizontalRule" then
    return wrap(ansi.dim, string.rep("─", 40))

  elseif block.t == "LineBlock" then
    local lines = {}
    for _, line in ipairs(block.content) do
      table.insert(lines, render_inlines(line))
    end
    return table.concat(lines, "\n")

  elseif block.t == "Div" then
    return render_blocks(block.content)

  elseif block.t == "RawBlock" then
    return block.text

  else
    return ""
  end
end

function render_blocks(blocks)
  local result = {}
  for _, block in ipairs(blocks) do
    table.insert(result, render_block(block))
  end
  return table.concat(result, "\n")
end

function render_inlines(inlines)
  local result = {}

  for _, inline in ipairs(inlines) do
    if inline.t == "Str" then
      table.insert(result, inline.text)

    elseif inline.t == "Space" then
      table.insert(result, " ")

    elseif inline.t == "SoftBreak" then
      table.insert(result, " ")

    elseif inline.t == "LineBreak" then
      table.insert(result, "\n")

    elseif inline.t == "Strong" then
      table.insert(result, wrap(ansi.bold, render_inlines(inline.content)))

    elseif inline.t == "Emph" then
      table.insert(result, wrap(ansi.italic, render_inlines(inline.content)))

    elseif inline.t == "Strikeout" then
      table.insert(result, wrap(ansi.dim, render_inlines(inline.content)))

    elseif inline.t == "Code" then
      table.insert(result, wrap(ansi.bg_gray .. ansi.yellow, " " .. inline.text .. " "))

    elseif inline.t == "Link" then
      local text = render_inlines(inline.content)
      local url = inline.target
      -- Show link text in magenta, URL in cyan
      table.insert(result, wrap(ansi.magenta .. ansi.bold, text) .. " " .. wrap(ansi.cyan, url))

    elseif inline.t == "Image" then
      local alt = render_inlines(inline.caption)
      table.insert(result, wrap(ansi.dim, "[image: " .. alt .. "]"))

    elseif inline.t == "RawInline" then
      table.insert(result, inline.text)

    elseif inline.t == "Quoted" then
      local quote_char = inline.quotetype == "DoubleQuote" and '"' or "'"
      table.insert(result, quote_char .. render_inlines(inline.content) .. quote_char)

    elseif inline.t == "Span" then
      table.insert(result, render_inlines(inline.content))

    elseif inline.t == "Math" then
      table.insert(result, wrap(ansi.green, inline.text))

    end
  end

  return table.concat(result)
end

-- Required metadata
function Template()
  return "$body$"
end
