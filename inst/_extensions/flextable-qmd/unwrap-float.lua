--- unwrap-float : retire le tableau wrapper de Quarto autour des flextables
---
--- S'execute au post-render (apres la resolution des refs croisees et
--- le rendu des floats). A ce stade, le FloatRefTarget de Quarto a ete
--- converti en un Table Pandoc contenant : la caption (en tant que Para
--- dans un Div de cellule) + le flextable (en tant que RawBlock openxml).
--- On va detecter ces Tables wrapper a cellule unique et les remplace
--- par leur contenu (caption + table), ne supprimant que l'enveloppe
--- Pandoc tout en preservant tout ce qu'il y a a l'interieur. Sauf si
--- deux tableaux qui est une limitation.
---
--- Structure attendue au post-render :
---
---   tbl-cap-location: top (defaut)     tbl-cap-location: bottom
---
---   Div.cell                           Div.cell
---     CodeBlock                          CodeBlock
---     Table (wrapper 1x1)                Table (wrapper 1x1)
---       Cell                               Cell
---         Div.cell                           Div.cell
---           Para  <- caption                   RawBlock(openxml) <- flextable
---           RawBlock(openxml) <- flextable     Para <- caption
---
--- L'ordre Para/RawBlock dans la cellule reflete `tbl-cap-location`.
--- Le filtre preserve cet ordre lors de l'aplatissement (unwrap_content).
---
--- Hypotheses / pre-requis :
---
--- 1. Timing : doit etre declare avec `at: post-render` dans le YAML
---    du document (pas dans _extension.yml). A ce stade les FloatRefTarget
---    ont deja ete convertis en Table Pandoc par Quarto.
---
--- 2. Format : ne s'active que pour la sortie docx (FORMAT:match("docx")).
---
--- 3. Un seul flextable par wrapper : chaque chunk avec `tbl-cap`
---    doit produire un seul Table wrapper contenant un seul RawBlock <w:tbl>.
---    Si un chunk produit plusieurs flextables (ex. layout-ncol: 2), le
---    filtre leve une erreur et suggere d'utiliser officer::block_section().
---    TODO: founir un exemple.
---
--- 4. Label en `tbl-` : le chunk doit avoir un label avec le prefixe
---    `tbl-` (ex. `tbl-ft`) pour que Quarto cree le float avec caption.
---    Avec un autre prefixe (ex. `tab-`), Quarto ne genere pas de
---    wrapper Table et la caption est absente.
---
--- 5. Detection par `<w:tbl` : tout Table Pandoc dont les cellules
---    contiennent un RawBlock(openxml) avec `<w:tbl` est considere
---    comme un wrapper Quarto et sera desemballe. Si une vrai Table
---    Pandoc (multi-cellules) contenait du raw OOXML avec `<w:tbl`,
---    il serait desemballe a tort. Il serait bien sur preferable
---    d'etre en mesure d'identifier les sorties provenant de flextable
---    mais je ne vois pas comment on pourrait faire sans rendre le code lua
---    vraiment difficile a maintenir. TODO: tester l'ajout d'un flag dans le OOXML
---    et voir si on peut faire un 'if' avec cela.
---
--- 6. Aplatissement des Div : les Div intermediaires dans les cellules
---    du wrapper sont aplatis (leur contenu est extrait). Les attributs
---    de ces Div (id, classes) sont perdus. Au post-render, ces Div
---    ne sont que des enveloppes structurelles sans semantique propre.

-- Compte recursivement les RawBlock flextable (<w:tbl) dans des blocs
local function count_raw_tables(blocks)
  local n = 0
  for _, block in ipairs(blocks) do
    if block.t == "RawBlock" and block.format == "openxml"
       and block.text:find("<w:tbl") then
      n = n + 1
    elseif block.t == "Div" then
      n = n + count_raw_tables(block.content)
    end
  end
  return n
end

-- Aplatit le contenu des cellules : retire les conteneurs Div, garde le reste
local function unwrap_content(blocks)
  local result = pandoc.Blocks({})
  for _, block in ipairs(blocks) do
    if block.t == "Div" then
      result:extend(unwrap_content(block.content))
    else
      result:insert(block)
    end
  end
  return result
end

-- Extrait tous les blocs des cellules d'un Table Pandoc (head + body)
local function table_cell_blocks(tbl)
  local all_blocks = pandoc.Blocks({})
  if tbl.head and tbl.head.rows then
    for _, row in ipairs(tbl.head.rows) do
      for _, cell in ipairs(row.cells) do
        all_blocks:extend(cell.contents)
      end
    end
  end
  for _, body in ipairs(tbl.bodies or {}) do
    for _, row in ipairs(body.body) do
      for _, cell in ipairs(row.cells) do
        all_blocks:extend(cell.contents)
      end
    end
  end
  return all_blocks
end

-- Traite un Table wrapper : unwrap si 1 flextable, erreur si > 1
local function process_table(tbl)
  local cell_blocks = table_cell_blocks(tbl)
  local n = count_raw_tables(cell_blocks)
  if n > 1 then
    error(
      "[unwrap-float] The wrapper Table contains " .. n .. " raw OpenXML tables.\n" ..
      "This filter is designed for flextable and only supports one table per\n" ..
      "captioned chunk. It may produce unexpected results with other embedded\n" ..
      "OpenXML tables. layout-ncol with multiple tables is not supported in docx.\n" ..
      "Use one chunk per table, or officer::block_section() to arrange\n" ..
      "multiple tables in columns."
    )
  elseif n == 1 then
    return unwrap_content(cell_blocks), true
  end
  return pandoc.Blocks({tbl}), false
end

-- Parcour d'une liste de blocs en recursif, traite les Tables et descend dans les Div
local function process_blocks(blocks)
  local result = pandoc.Blocks({})
  local changed = false
  for _, block in ipairs(blocks) do
    if block.t == "Table" then
      local content, did_unwrap = process_table(block)
      result:extend(content)
      if did_unwrap then changed = true end
    elseif block.t == "Div" then
      local inner, inner_changed = process_blocks(block.content)
      if inner_changed then
        block.content = inner
        changed = true
      end
      result:insert(block)
    else
      result:insert(block)
    end
  end
  return result, changed
end

function Pandoc(doc)
  if not FORMAT:match("docx") then return nil end

  local new_blocks, changed = process_blocks(doc.blocks)
  if changed then
    doc.blocks = new_blocks
    return doc
  end
  return nil
end
