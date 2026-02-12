--- flextable-qmd : resout les spans data-qmd-base64 dans les RawBlocks
--- HTML/LaTeX/OOXML produits par flextable.
---
--- Ce filtre Quarto s'execute APRES les filtres internes de Quarto :
---
--- Quarto offre les lua comme moyen de bosser sur les contenus. La plus importante
--- des features qu'on veut c'est de pouvoir gerer les cross-ref. Vu que c quarto
--- qui gere cela, on va poser dans un tableau fake toutes les expressions qui viennent
--- de as_qmd et paf plus la peine de les traduire mais juste de les rebouger au
--- bon endroit. C'est moche mais moins que les alternatives boiteuses. Cette
--- solution a le merite de fonctionner.
---
--- 1. Construit une table de correspondance des references croisees
---    a partir des Links resolus dans le corps du document et des
---    entrees FloatRefTarget internes de Quarto.
--- 2. Trouve les marqueurs encodes dans les RawBlocks HTML, LaTeX
---    ou OpenXML, les decode, les parse en markdown, resout les
---    refs croisees, rend dans le format cible et reinjecte.
--- 3. Gere aussi les elements Span (cas de repli quand Pandoc
---    parse le HTML).

-- Decodage base64 (Lua pur) ------------------------------------------------
local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64_decode(data)
  data = data:gsub("[^" .. b64 .. "=]", "")
  return (data:gsub(".", function(x)
    if x == "=" then return "" end
    local r, f = "", (b64:find(x) - 1)
    for i = 6, 1, -1 do
      r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return r
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
    if #x ~= 8 then return "" end
    local c = 0
    for i = 1, 8 do
      c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
    end
    return string.char(c)
  end))
end

-- Echappement des motifs Lua ------------------------------------------------
--- permet le string literal matching, on veut remplacer la chaîne exacte, pas un pattern.
--- et il faut proteger les caracteres spéciaux Lua
local function escape_pattern(s)
  return s:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
end

-- Echappement des entites XML pour le contenu texte OOXML -------------------
local function xml_escape(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- Construit le XML w:rPr a partir d'une table de proprietes -----------------
local function build_rpr(props)
  if not props or next(props) == nil then return "" end
  local parts = {"<w:rPr>"}
  if props.style then
    table.insert(parts, '<w:rStyle w:val="' .. props.style .. '"/>')
  end
  if props.monospace then
    table.insert(parts, '<w:rFonts w:ascii="Courier New" w:hAnsi="Courier New"/>')
  end
  if props.bold then table.insert(parts, "<w:b/>") end
  if props.italic then table.insert(parts, "<w:i/>") end
  if props.underline then table.insert(parts, '<w:u w:val="single"/>') end
  if props.strike then table.insert(parts, "<w:strike/>") end
  if props.superscript then
    table.insert(parts, '<w:vertAlign w:val="superscript"/>')
  end
  if props.subscript then
    table.insert(parts, '<w:vertAlign w:val="subscript"/>')
  end
  if props.smallcaps then table.insert(parts, "<w:smallCaps/>") end
  table.insert(parts, "</w:rPr>")
  return table.concat(parts)
end

-- Fusionne deux tables de proprietes ----------------------------------------
local function merge_props(base, extra)
  local result = {}
  if base then for k, v in pairs(base) do result[k] = v end end
  if extra then for k, v in pairs(extra) do result[k] = v end end
  return result
end

-- Convertit des Inlines Pandoc en chaine OOXML ------------------------------
local function inlines_to_ooxml(inls, props)
  local parts = {}
  for _, el in ipairs(inls) do
    if el.t == "Str" then
      local rpr = build_rpr(props)
      table.insert(parts,
        '<w:r>' .. rpr .. '<w:t xml:space="preserve">'
        .. xml_escape(el.text) .. '</w:t></w:r>')
    elseif el.t == "Space" or el.t == "SoftBreak" then
      local rpr = build_rpr(props)
      table.insert(parts,
        '<w:r>' .. rpr .. '<w:t xml:space="preserve"> </w:t></w:r>')
    elseif el.t == "LineBreak" then
      table.insert(parts, '<w:r><w:br/></w:r>')
    elseif el.t == "Strong" then
      table.insert(parts,
        inlines_to_ooxml(el.content, merge_props(props, {bold = true})))
    elseif el.t == "Emph" then
      table.insert(parts,
        inlines_to_ooxml(el.content, merge_props(props, {italic = true})))
    elseif el.t == "Underline" then
      table.insert(parts,
        inlines_to_ooxml(el.content, merge_props(props, {underline = true})))
    elseif el.t == "Strikeout" then
      table.insert(parts,
        inlines_to_ooxml(el.content, merge_props(props, {strike = true})))
    elseif el.t == "Superscript" then
      table.insert(parts,
        inlines_to_ooxml(el.content, merge_props(props, {superscript = true})))
    elseif el.t == "Subscript" then
      table.insert(parts,
        inlines_to_ooxml(el.content, merge_props(props, {subscript = true})))
    elseif el.t == "SmallCaps" then
      table.insert(parts,
        inlines_to_ooxml(el.content, merge_props(props, {smallcaps = true})))
    elseif el.t == "Code" then
      local rpr = build_rpr(merge_props(props, {monospace = true}))
      table.insert(parts,
        '<w:r>' .. rpr .. '<w:t xml:space="preserve">'
        .. xml_escape(el.text) .. '</w:t></w:r>')
    elseif el.t == "Link" then
      local target = el.target
      if target:sub(1, 1) == "#" then
        -- Lien interne (signet)
        local anchor = target:sub(2)
        local lprops = merge_props(props, {style = "Hyperlink"})
        table.insert(parts,
          '<w:hyperlink w:anchor="' .. xml_escape(anchor) .. '">'
          .. inlines_to_ooxml(el.content, lprops)
          .. '</w:hyperlink>')
      else
        -- Lien externe via champ HYPERLINK (pas de relation necessaire)
        table.insert(parts,
          '<w:r><w:fldChar w:fldCharType="begin"/></w:r>')
        table.insert(parts,
          '<w:r><w:instrText xml:space="preserve">'
          .. ' HYPERLINK "' .. xml_escape(target) .. '" '
          .. '</w:instrText></w:r>')
        table.insert(parts,
          '<w:r><w:fldChar w:fldCharType="separate"/></w:r>')
        local lprops = merge_props(props, {style = "Hyperlink"})
        table.insert(parts, inlines_to_ooxml(el.content, lprops))
        table.insert(parts,
          '<w:r><w:fldChar w:fldCharType="end"/></w:r>')
      end
    elseif el.t == "Math" then
      -- Repli : rend les maths en texte italique
      local rpr = build_rpr(merge_props(props, {italic = true}))
      table.insert(parts,
        '<w:r>' .. rpr .. '<w:t xml:space="preserve">'
        .. xml_escape(el.text) .. '</w:t></w:r>')
    elseif el.t == "Quoted" then
      local q  = el.quotetype == "DoubleQuote" and "\u{201c}" or "\u{2018}"
      local qe = el.quotetype == "DoubleQuote" and "\u{201d}" or "\u{2019}"
      local rpr = build_rpr(props)
      table.insert(parts,
        '<w:r>' .. rpr .. '<w:t xml:space="preserve">'
        .. q .. '</w:t></w:r>')
      table.insert(parts, inlines_to_ooxml(el.content, props))
      table.insert(parts,
        '<w:r>' .. rpr .. '<w:t xml:space="preserve">'
        .. qe .. '</w:t></w:r>')
    elseif el.t == "RawInline" and el.format == "openxml" then
      table.insert(parts, el.text)
    end
  end
  return table.concat(parts)
end

-- Extrait les inlines depuis une liste de blocs Para/Plain ----------------
local function extract_inlines(blocks)
  local inlines = pandoc.Inlines({})
  for _, block in ipairs(blocks) do
    if block.t == "Para" or block.t == "Plain" then
      if #inlines > 0 then inlines:insert(pandoc.Space()) end
      inlines:extend(block.content)
    end
  end
  return inlines
end

-- Detecte la presence d'images dans des inlines ---------------------------
local function has_images(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Image" then return true end
  end
  return false
end

-- Convertit des inlines en mix RawInline OOXML + Image Pandoc natif -------
local function inlines_to_mixed_ooxml(inls)
  local result = pandoc.Inlines({})
  local text_buf = pandoc.Inlines({})

  local function flush()
    if #text_buf > 0 then
      local xml = inlines_to_ooxml(text_buf)
      if xml ~= "" then
        result:insert(pandoc.RawInline("openxml", xml))
      end
      text_buf = pandoc.Inlines({})
    end
  end

  for _, el in ipairs(inls) do
    if el.t == "Image" then
      flush()
      result:insert(el)
    else
      text_buf:insert(el)
    end
  end
  flush()
  return result
end

-- Trouve les bornes <w:p>...</w:p> autour d'un marqueur ------------------
local function find_p_bounds(xml, marker_start, marker_end)
  local before = xml:sub(1, marker_start - 1)
  local p_open = nil
  for pos in before:gmatch("()<w:p[%s>]") do
    p_open = pos
  end
  if not p_open then return nil end
  local _, p_close = xml:find("</w:p>", marker_end + 1)
  if not p_close then return nil end
  return p_open, p_close
end

-- Extrait le type de ref croisee depuis l'identifiant : "fig-scatter" -> "fig"
local function ref_type(id)
  return id:match("^([^%-]+)")
end

-- Table des refs croisees : id -> {text=..., target=...} --------------------
local xref = {}

-- Passe 1 : construit la table des refs croisees depuis plusieurs sources ---
local function build_xref_map(doc)
  -- Source 1 : parcourt les Links resolus dans le corps du document
  -- (Quarto transforme @fig-xxx -> Link("Figure 1", "#fig-xxx") dans le texte)
  for _, block in ipairs(doc.blocks) do
    pandoc.walk_block(block, {
      Link = function(el)
        local t = el.target
        if t:sub(1, 1) == "#" then
          local id = t:sub(2)
          if not xref[id] then
            local html = pandoc.write(
              pandoc.Pandoc({ pandoc.Plain(el.content) }), "html"
            ):gsub("^%s*<p>(.+)</p>%s*$", "%1"):gsub("%s+$", "")
            xref[id] = { text = html, target = t }
          end
        end
      end
    })
  end

  -- Source 2 : construit depuis les noeuds FloatRefTarget de Quarto
  -- La table globale `crossref` fournit les prefixes de categorie
  -- (Figure, Table, ...) et custom_node_data les identifiants des floats.
  local cr = rawget(_G, "crossref")
  local cnd = quarto and quarto._quarto and quarto._quarto.ast
    and quarto._quarto.ast.custom_node_data

  if cr and cr.categories and cnd then
    -- Collecte les entrees FloatRefTarget triees par cle (ordre du document)
    local floats = {}
    for k, v in pairs(cnd) do
      if type(v) == "table" and v.t == "FloatRefTarget" and v.identifier then
        table.insert(floats, { key = k, id = v.identifier, ftype = v.type })
      end
    end
    table.sort(floats, function(a, b) return a.key < b.key end)

    -- Compte par type de ref et attribue les numeros
    local counters = {}
    for _, f in ipairs(floats) do
      local rt = ref_type(f.id)
      if rt and not xref[f.id] then
        counters[rt] = (counters[rt] or 0) + 1
        -- Cherche le prefixe de categorie (ex. "Figure", "Table")
        local cat = cr.categories.by_ref_type[rt]
        local prefix = cat and (cat.prefix or cat.name) or rt
        local label = prefix .. "\u{a0}" .. tostring(counters[rt])
        xref[f.id] = { text = label, target = "#" .. f.id }
      end
    end
  end

  return nil -- ne modifie pas le document
end

-- Resout les elements Cite via la table des refs croisees -------------------
local function resolve_cites(blocks)
  local new_blocks = {}
  for _, block in ipairs(blocks) do
    local resolved = pandoc.walk_block(block, {
      Cite = function(el)
        local id = el.citations[1].id
        if xref[id] then
          return pandoc.Link(
            pandoc.read(xref[id].text, "html").blocks[1].content,
            xref[id].target
          )
        end
        -- Repli : conserve le texte de la citation tel quel
        return el.content
      end
    })
    table.insert(new_blocks, resolved)
  end
  return new_blocks
end

-- Rend les blocs resolus en chaine inline pour un format donne --------------
local function blocks_to_output(blocks, fmt)
  local resolved = resolve_cites(blocks)
  local out = pandoc.write(pandoc.Pandoc(resolved), fmt)
  -- supprime le <p> englobant (HTML) ou les retours a la ligne finaux
  if fmt == "html" then
    out = out:gsub("^%s*<p>%s*(.-)%s*</p>%s*$", "%1")
  end
  out = out:gsub("%s+$", "")
  return out
end

-- Passe 2a : traite les RawBlocks HTML (sortie knitr {=html}) ---------------
local function process_html_raw(html)
  local modified = false

  -- spans data-qmd-base64
  local work = html
  for full, encoded in work:gmatch(
    '(<span[^>]- data%-qmd%-base64="([^"]-)"[^>]*>[^<]-</span>)'
  ) do
    local decoded = base64_decode(encoded)
    local doc = pandoc.read(decoded, "markdown-implicit_figures")
    local rendered = blocks_to_output(doc.blocks, "html")

    local safe = rendered:gsub("%%", "%%%%")
    html = html:gsub(escape_pattern(full), safe, 1)
    modified = true
  end

  -- spans data-qmd (non base64)
  work = html
  for full, raw_qmd in work:gmatch(
    '(<span[^>]- data%-qmd="([^"]-)"[^>]*>[^<]-</span>)'
  ) do
    local doc = pandoc.read(raw_qmd, "markdown-implicit_figures")
    local rendered = blocks_to_output(doc.blocks, "html")

    local safe = rendered:gsub("%%", "%%%%")
    html = html:gsub(escape_pattern(full), safe, 1)
    modified = true
  end

  return html, modified
end

-- Passe 2b : traite les RawBlocks LaTeX (marqueurs \tblqmd{base64}) ---------
local function process_latex_raw(tex)
  local modified = false

  local work = tex
  for full, encoded in work:gmatch("(\\tblqmd{([^}]+)})") do
    local decoded = base64_decode(encoded)
    local doc = pandoc.read(decoded, "markdown-implicit_figures")
    local rendered = blocks_to_output(doc.blocks, "latex")

    local safe = rendered:gsub("%%", "%%%%")
    tex = tex:gsub(escape_pattern(full), safe, 1)
    modified = true
  end

  return tex, modified
end

-- Passe 2c : traite les RawBlocks OpenXML (marqueurs <!--TBLQMD:base64-->) --
-- Retourne : nil | RawBlock | {Block...} (liste si images detectees)
local function process_openxml_raw(xml)
  local modified = false

  -- Passe A : remplace les marqueurs SANS images (substitution de chaine)
  local work = xml
  for full, encoded in work:gmatch("(<!%-%-TBLQMD:([^%-]+)%-%->)") do
    local decoded = base64_decode(encoded)
    local doc = pandoc.read(decoded, "markdown-implicit_figures")
    local resolved = resolve_cites(doc.blocks)
    local inlines = extract_inlines(resolved)

    if not has_images(inlines) then
      local ooxml = inlines_to_ooxml(inlines)
      local safe = ooxml:gsub("%%", "%%%%")
      xml = xml:gsub(escape_pattern(full), safe, 1)
      modified = true
    end
  end

  -- Passe B : collecte les marqueurs restants (AVEC images)
  local image_markers = {}
  local search_start = 1
  while true do
    local ms, me = xml:find("<!%-%-TBLQMD:([^%-]+)%-%->", search_start)
    if not ms then break end
    local encoded = xml:match("<!%-%-TBLQMD:([^%-]+)%-%->", ms)
    table.insert(image_markers, { ms = ms, me = me, encoded = encoded })
    search_start = me + 1
  end

  if #image_markers == 0 then
    if modified then return pandoc.RawBlock("openxml", xml) end
    return nil
  end

  -- Decoupage du XML autour des marqueurs avec images
  local blocks = {}
  local pos = 1

  for _, m in ipairs(image_markers) do
    local decoded = base64_decode(m.encoded)
    local doc = pandoc.read(decoded, "markdown-implicit_figures")
    local resolved = resolve_cites(doc.blocks)
    local inlines = extract_inlines(resolved)

    local p_open, p_close = find_p_bounds(xml, m.ms, m.me)
    if p_open and p_close and p_open >= pos then
      -- XML avant le <w:p> contenant le marqueur
      local before = xml:sub(pos, p_open - 1)
      if before ~= "" then
        table.insert(blocks, pandoc.RawBlock("openxml", before))
      end
      -- Para natif avec inlines mixtes (RawInline OOXML + Image Pandoc)
      local mixed = inlines_to_mixed_ooxml(inlines)
      table.insert(blocks, pandoc.Para(mixed))
      pos = p_close + 1
    else
      -- Repli : remplacement du marqueur par du texte OOXML (images perdues)
      local before = xml:sub(pos, m.ms - 1)
      local ooxml = inlines_to_ooxml(inlines)
      table.insert(blocks, pandoc.RawBlock("openxml", before .. ooxml))
      pos = m.me + 1
    end
  end

  -- XML restant apres le dernier marqueur avec image
  local rest = xml:sub(pos)
  if rest ~= "" then
    table.insert(blocks, pandoc.RawBlock("openxml", rest))
  end

  return blocks
end

-- Traitement unifie des RawBlocks -------------------------------------------
local function process_raw_block(el)
  if el.format == "html" then
    if not el.text:find("data%-qmd") then return nil end
    local result, modified = process_html_raw(el.text)
    if modified then return pandoc.RawBlock("html", result) end

  elseif el.format == "latex" then
    if not el.text:find("\\tblqmd") then return nil end
    local result, modified = process_latex_raw(el.text)
    if modified then return pandoc.RawBlock("latex", result) end

  elseif el.format == "openxml" then
    if not el.text:find("TBLQMD") then return nil end
    return process_openxml_raw(el.text)
  end

  return nil
end

-- Traitement des elements Span (repli si Pandoc parse le HTML) --------------
local function process_span(el)
  local encoded = el.attributes["data-qmd-base64"]
  local raw_qmd = el.attributes["data-qmd"]

  local qmd_text
  if encoded then
    qmd_text = base64_decode(encoded)
  elseif raw_qmd then
    qmd_text = raw_qmd
  else
    return nil
  end

  local doc = pandoc.read(qmd_text, "markdown-implicit_figures")
  local resolved = resolve_cites(doc.blocks)
  local inlines = extract_inlines(resolved)

  if #inlines > 0 then return inlines end
  return nil
end

-- Definition du filtre : deux parcours dans l'ordre -------------------------
return {
  { Pandoc = build_xref_map },                       -- passe 1
  { RawBlock = process_raw_block, Span = process_span } -- passe 2
}
