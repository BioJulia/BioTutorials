import Literate
using Dates
using Literate
import Hyperscript as HS

node = HS.m

dfmt(d) = Dates.format(d, "U d, yyyy")

function hfun_dfmt(p::Vector{String})
    d = getlvar(Symbol(p[1]))
    return dfmt(d)
end

# ===============================================
# Tags
# ===============================================

function hfun_page_tags()
    tags = get_page_tags()
    base = globvar(:tags_prefix)
    return join(
        (
            node("span", class="tag",
                node("a", href="/$base/$id/", name)
            )
            for (id, name) in tags
        ),
        node("span", class="separator", "•")
    )
end

function hfun_taglist()
    tag = something(getlvar(:tag_name), "")
    return _render_posts(get_posts(tag, ""))
end

# ===============================================
# Post listing
#
# {{list_posts}}           — all posts across the whole site
# {{list_posts tag_name}}  — posts filtered by tag
# {{list_dir rosalind}}    — posts within a specific subdirectory (non-recursive)
# {{list_series}}          — one card per series (any subdir containing an index.md)
# ===============================================

hfun_list_posts() = _render_posts(get_posts("", ""))

function hfun_list_posts(args::Vector{String})
    tag = isempty(args) ? "" : args[1]
    return _render_posts(get_posts(tag, ""))
end

function hfun_list_dir(args::Vector{String})
    isempty(args) && return ""
    return _render_posts(get_posts("", args[1]))
end

function hfun_list_series()
    parts = String[]
    for entry in sort(readdir("."))
        isdir(entry) || continue
        startswith(entry, "_") && continue
        startswith(entry, ".") && continue
        index_path = joinpath(entry, "index.md")
        isfile(index_path) || continue

        title = something(getvarfrom(:title, index_path), titlecase(entry))
        desc_raw = getvarfrom(:rss_descr, index_path)
        desc = (desc_raw !== nothing && desc_raw isa String) ? desc_raw : ""
        n = length(get_posts("", entry))

        push!(parts, string(
            node("article", class="series-card",
                node("h2", node("a", href="/$entry/", title)),
                isempty(desc) ? "" : node("p", class="description", desc),
                node("p", class="post-meta", "$n tutorials")
            )
        ))
    end
    return join(parts, "\n")
end

# ===============================================
# Shared rendering
# ===============================================

function _render_posts(posts)
    parts = String[]
    for p in posts
        push!(parts, string(
            node("article", class="post-preview",
                node("h2", node("a", href=p.href, p.title)),
                isempty(p.description) ? "" : node("p", class="description", p.description),
                node("p", class="post-meta",
                    p.author,
                    " · ",
                    Dates.format(p.date, "u d, yyyy"),
                    " · ",
                    "$(p.read_time) min read"
                )
            )
        ))
    end
    return join(parts, "\n")
end

function estimate_read_time(filepath::String)
    content = read(filepath, String)
    m = match(r"^\+\+\+.*?\+\+\+"s, content)
    if m !== nothing
        content = content[length(m.match)+1:end]
    end
    content = replace(content, r"```.*?```"s => "")
    content = replace(content, r"~~~.*?~~~"s => "")
    content = replace(content, r"<[^>]+>" => "")
    words = length(split(content))
    return max(1, round(Int, words / 200))
end

# ===============================================
# Post discovery
#
# get_posts(tag, subdir):
#   tag    — filter by tag ("" = no filter)
#   subdir — restrict to one subdirectory ("" = whole site, recursive)
#            when set, only immediate .md files are returned (non-recursive)
# ===============================================

const EXCLUDED_FILES = ("index.md", "404.md", "config.md", "README.md", "CLAUDE.md", "Claude.md")

function get_posts(tag::String, subdir::String, basepath::String="./")
    searchpath = isempty(subdir) ? basepath : joinpath(basepath, subdir)
    paths = String[]
    for (root, dirs, files) in walkdir(searchpath)
        !isempty(subdir) && empty!(dirs)  # non-recursive when subdir is specified
        filter!(p -> endswith(p, ".md") && p ∉ EXCLUDED_FILES, files)
        append!(paths, joinpath.(root, files))
    end
    posts = [
        let rp_clean = String(lstrip(rp, ['.', '/']))
            rss_desc = getvarfrom(:rss_descr, rp_clean)
            desc = (rss_desc !== nothing && rss_desc isa String) ? rss_desc : ""
            (;
                date      = getvarfrom(:date, rp_clean),
                title     = getvarfrom(:title, rp_clean),
                author    = something(getvarfrom(:author, rp_clean), ""),
                description = desc,
                href      = "/$(splitext(rp_clean)[1])",
                tags      = get_page_tags(rp_clean),
                read_time = estimate_read_time(rp_clean)
            )
        end
        for rp in paths
    ]
    sort!(posts, by=x -> x.date, rev=true)
    if !isempty(tag)
        filter!(p -> tag in values(p.tags), posts)
    end
    return posts
end
