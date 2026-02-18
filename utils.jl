import Literate
using Dates
using Literate
import Hyperscript as HS

node = HS.m

# March 5, 2019
dfmt(d) = Dates.format(d, "U d, yyyy")

function hfun_dfmt(p::Vector{String})
    d = getlvar(Symbol(p[1]))
    return dfmt(d)
end

# ===============================================
# Logic to show the list of tags for a page
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

# ===============================================
# Logic to show the list of tags for a page
# ===============================================

function hfun_taglist()
    return hfun_list_posts(getlvar(:tag_name))
end

# ===============================================
# Logic to retrieve posts in posts/ and display
# them as a list sorted by anti-chronological
# order.
#
# Assumes that 'date' and 'title' are defined for
# all posts.
# ===============================================

function hfun_list_posts(t::String)
    posts = get_posts(t)
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
hfun_list_posts() = hfun_list_posts("")

function estimate_read_time(filepath::String)
    content = read(filepath, String)
    # Remove frontmatter
    m = match(r"^\+\+\+.*?\+\+\+"s, content)
    if m !== nothing
        content = content[length(m.match)+1:end]
    end
    # Remove code blocks and HTML for word count
    content = replace(content, r"```.*?```"s => "")
    content = replace(content, r"~~~.*?~~~"s => "")
    content = replace(content, r"<[^>]+>" => "")
    words = length(split(content))
    # Assume 200 words per minute reading speed
    return max(1, round(Int, words / 200))
end

function get_posts(t::String, basepath::String="./")
    # find all valid "posts/xxx.md" files, exclude the index which is where
    # the post-list gets placed
    paths = String[]
    for (root, dirs, files) in walkdir(basepath)
        filter!(p -> endswith(p, ".md") && p ∉ ("index.md","404.md","config.md","README.md","CLAUDE.md"), files)
        append!(paths, joinpath.(root, files))
    end
    # for each of those posts, retrieve date and title, both are expected
    # to be there
    posts = [
        let rp_clean = String(lstrip(rp, ['.', '/']))
            rss_desc = getvarfrom(:rss_descr, rp_clean)
            desc = (rss_desc !== nothing && rss_desc isa String) ? rss_desc : ""
            (;
                date  = getvarfrom(:date, rp_clean),
                title = getvarfrom(:title, rp_clean),
                author = something(getvarfrom(:author, rp_clean), ""),
                description = desc,
                href  = "/$(splitext(rp_clean)[1])",
                tags  = get_page_tags(rp_clean),
                read_time = estimate_read_time(rp_clean)
            )
        end
        for rp in paths
    ]
    sort!(posts, by = x -> x.date, rev=true)
    if !isempty(t)
        filter!(
            p -> t in values(p.tags),
            posts
        )
    end
    return posts
end
