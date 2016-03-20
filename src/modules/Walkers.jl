"""
Provides the [`walk`]({ref}) function.
"""
module Walkers

import ..Lapidary:

    Anchors,
    Builder,
    Documents,
    Expanders,
    Formats,
    Utilities

using Compat

"""
    walk(f, meta, element)

Calls `f` on `element` and any of its child elements. `meta` is a `Dict` containing metadata
such as current module.
"""
function walk end

# Change to the docstring's defining module if it has one. Change back afterwards.
function walk(f, meta, block::Markdown.MD)
    tmp = get(meta, :CurrentModule, nothing)
    mod = get(block.meta, :module, nothing)
    mod ≡ nothing || (meta[:CurrentModule] = mod)
    f(block) && walk(f, meta, block.content)
    tmp ≡ nothing ? delete!(meta, :CurrentModule) : (meta[:CurrentModule] = tmp)
    nothing
end

function walk(f, meta, block::Vector)
    for each in block
        f(each) && walk(f, meta, each)
    end
end

typealias MDContentElements Union{
    Markdown.BlockQuote,
    Markdown.Paragraph,
    Markdown.MD,
}
walk(f, meta, block::MDContentElements) = f(block) ? walk(f, meta, block.content) : nothing

walk(f, meta, block::Expanders.DocsNodes) = walk(f, meta, block.nodes)
walk(f, meta, block::Expanders.DocsNode)  = walk(f, meta, block.docstr)

walk(f, meta, block::Expanders.EvalNode) = walk(f, meta, block.result)

walk(f, meta, block::Expanders.MetaNode) = (merge!(meta, block.dict); nothing)

typealias MDTextElements Union{
    Markdown.Bold,
    Markdown.Header,
    Markdown.Italic,
}
walk(f, meta, block::MDTextElements) = f(block) ? walk(f, meta, block.text)  : nothing

if isdefined(Base.Markdown, :Footnote)
    walk(f, meta, block::Markdown.Footnote) = f(block) ? walk(f, meta, block.text) : nothing
end

walk(f, meta, block::Markdown.Image) = f(block) ? walk(f, meta, block.alt)   : nothing
walk(f, meta, block::Markdown.Table) = f(block) ? walk(f, meta, block.rows)  : nothing
walk(f, meta, block::Markdown.List)  = f(block) ? walk(f, meta, block.items) : nothing
walk(f, meta, block::Markdown.Link)  = f(block) ? walk(f, meta, block.text)  : nothing

walk(f, meta, block) = (f(block); nothing)

end
